;;; tc ffi.ss
(define-syntax define-ftype-allocator
  ;; 用于scheme构造ftype对象,会将对象加入垃圾回收
  (lambda (x)
    (syntax-case x () 
      [(_ name type) 
       #'(define (name)
	   (sdl-guard-pointer (make-ftype-pointer type (foreign-alloc (ftype-sizeof type)))))]))) 

(define-syntax define-sdl-func1
  ;; chez-sdl的ftype.ss中,并没有进行反驼峰,为了实现chez-sdl之封装,嫁接于thunder之根,对thunder进行修改.
  ;; chez-sdl使用chez的foreign-procedure,导致无法被补全和获得参数
  ;; 这种简洁方式会导致SDL_GetMemoryFunctions当中的函数指针参数无用(* SDL_malloc_func) 2024年4月17日21:25:29
  (lambda (x)
    (syntax-case x ()
      [(_ ret-type name ((arg-name arg-type) ...) c-name)
       #`(begin
	   #,(case (syntax->datum #'ret-type)
	       [(string)
		#'(define (name arg-name ...)  
		    ((foreign-procedure c-name (arg-type ...) ret-type)
		     arg-name ...)
		    )]
	       [else
		#'(define (name arg-name ...) 
		    ((foreign-procedure __collect_safe c-name (arg-type ...) ret-type)
		     arg-name ...)
		    )]))])))

(define-syntax define-sdl-func
  (lambda (x)
    ;; chez-sdl的ftype.ss中,并没有进行反驼峰,为了实现chez-sdl之封装,嫁接于thunder之根,对thunder进行修改.
    (define (anti-camel x)
      ;; 反驼峰法,将_变-,连续大写XXX变-xxx-
      (let* ([x (string-replace x #\_ #\-)]
	     [len (string-length x)]
	     [s (list->string
		 (reverse
		  (fold (lambda (i acc) 
			  (let ([a (string-ref x i)] 
				[b (if (< (+ 1 i) len) (string-ref x (+ 1 i)) #f)]
				[c (if (> i 0) (string-ref x (- i 1)) #f)])
			    (if (and (char-upper-case? a) 
				     b (not (char-upper-case? b)) c (not (char-upper-case? c)))
				(cons (char-downcase a) (if (and c (char=? c #\-)) acc (cons #\- acc)))
				(cons (char-downcase a) acc)))) '() (iota len))))])
	s))
    
    (define (rename-scheme->c type)
      ;; 如果type是未知词法标识符的话,就对去除词法外衣后的datum使用=>的lambda,将其转化为原type一层的词法标识符
      ;; 被用于将define-sdl-func 参数中的ftype 转化为词法标识符
      (cond [(case (syntax->datum type)
	       [(unknown) 'unknown]
	       [else #f])
	     => (lambda (t)
		  (datum->syntax type t))]
	    [else type]))

    (define (convert-scheme->c function-name name type)
      name)

    (define (datum->string x)
      (symbol->string (syntax->datum x)))

    (define (string->datum t x)
      (datum->syntax t (string->symbol x)))

    ;; 关键部分 maintain
    (syntax-case x ()
      [(_ ret-type name ((arg-name arg-type) ...) c-name)
       ;; 原作把下面注释掉了,可能古早版本没name,只有c-name
       (with-syntax (;[name/string (datum->string #'name)]
					;[name (string->datum #'name (anti-camel (datum->string #'name)))]
		     [(renamed-type ...) (map rename-scheme->c #'(arg-type ...))] ;将参数类型词法标识符转化
		     [renamed-ret (rename-scheme->c #'ret-type)] ;将返回值类型词法标识符进行条件下转化
		     [function-ftype (datum->syntax #'name (string->symbol (string-append (symbol->string (syntax->datum #'name)) "-ft")))] ;将namedatum后进行后面续-ft的加工,再转回原层级的syntax
		     [((arg-name arg-convert) ...) (map (lambda (n t) 
							  (list n (convert-scheme->c #'name n t))) 
							#'(arg-name ...) #'(arg-type ...))])
	 ;; #'是syntax的语法糖,用来返回syntax对象,作为syntax-case的返回值
	 #`(begin
	     (define (name arg-name ...)  ;这个主要是可
	       (define-ftype function-ftype (function (renamed-type ...) renamed-ret)) ;竟然还专门构造了ffun类型而且还声明了指向函数的指针...,完全没用到chez自带的foreign-procedure
	       (let* ([function-fptr  (make-ftype-pointer function-ftype c-name)] ;c-name提供了入口.
		      [function       (ftype-ref function-ftype () function-fptr)]
		      [arg-name arg-convert] ...)
		 (let ([result (function arg-name ...)])
		   ;; 将f过程返回的对象加入垃圾回收
		   #,(case (syntax->datum #'ret-type) ;这一部分会根据返回类型展开成不同的形式 2024年4月17日19:59:28
		       [(int%)             #'(if (< result 0) (raise (make-sdl2-condition (sdl-get-error result))))]
		       [(
			 (* SDL_Surface) 
			 (* SDL_Texture)
			 (* SDL_Cursor)
			 (* SDL_PixelFormat)
			 (* SDL_Palette)
			 (* SDL_RWops)
			 (* SDL_mutex)
			 (* SDL_Window)
			 (* SDL_sem)
			 (* SDL_cond)
			 (* SDL_Renderer)
			 ;; 应该将SDL2以外的其它几个lib中,所有作为返回值的ftype均加入,可以通过写个代码,遍历xx-ftype.xls文件中的s-exp来实现.
			 ;; 但不确定如果不load image.dll会怎样  2023年8月16日20:29:07
			 
			 ;; Here should add such as (* TTF_Font) ex to support other libs except SDL2.dll.But what will happen is unknown while
			 ;; while SDL2_ttf.dll is not loaded cause I didn't test.
			 (* Mix_Chunk)
			 (* Mix_Music)

			 (* TTF_Font)

			 (* IPaddress)
			 (* UDPpacket)
			 )
			#'(sdl-guard-pointer result)]
		       [else #'result]))))))])))

(define-syntax new-struct
  (lambda (x)
    (syntax-case x ()
      [(_ ftype-name (field value) ... )
       #'(let ([object (make-ftype-pointer 
			ftype-name
			(foreign-alloc (ftype-sizeof ftype-name)))])
	   (ftype-set! ftype-name (field) object value) ...
	   (sdl-guard-pointer object))])))


;; This is useful if the c function returns values by reference (pointers)
;; the macro automatically allocates the variables and references the values after the call.
;;
(define-syntax sdl-let-ref-call
  (lambda (x)
    (syntax-case x ()
      [(k func (param ...) result body ...) 
       (with-syntax ([((var val) ...) (map (lambda (p)
					     (let ([p* (syntax->datum p)])
					       (if (pair? p*)
						   (list (datum->syntax #'k (car p*)) 
							 #`(sdl-guard-pointer 
							    (make-ftype-pointer 
							     #,(datum->syntax #'k (cadr p*))
							     (foreign-alloc 
							      (ftype-sizeof #,(datum->syntax #'k (cadr p*)))))))
						   (list p p)))) #'(param ...))])
	 (with-syntax
	     ([(val2 ...) (map (lambda (p v)
				 (let ([p* (syntax->datum p)])
				   (if (pair? p*)
				       (if (memq '& p*)
					   #`(ftype-&ref
					      #,(datum->syntax #'k (cadr p*))
					      ()
					      #,v)
					   #`(ftype-ref 
					      #,(datum->syntax #'k (cadr p*))
					      ()
					      #,v))
				       p))) #'(param ...) #'(var ...) )])
	   #'(let ([var val] ...)
	       (let ([result (func var ...)])
		 (let ((var val2) ...)
		   body ...)))))])))

