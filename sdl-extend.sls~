;;; tc ffi.ss
(define-syntax define-ftype-allocator 
  (lambda (x)
    (syntax-case x () 
      [(_ name type) 
       #'(define (name)
	   (sdl-guard-pointer (make-ftype-pointer type (foreign-alloc (ftype-sizeof type)))))])))

(trace-define-syntax define-sdl-func
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
	     (define (name arg-name ...) 
	       (define-ftype function-ftype (function (renamed-type ...) renamed-ret)) ;竟然还专门构造了ffun类型而且还声明了指向函数的指针...
	       (let* ([function-fptr  (make-ftype-pointer function-ftype c-name)] ;c-name提供了入口.
		      [function       (ftype-ref function-ftype () function-fptr)]
		      [arg-name arg-convert] ...)
		 (let ([result (function arg-name ...)])
		   #,(case (syntax->datum #'ret-type)
		       [(int%)             #'(if (< result 0) (raise (make-sdl2-condition (sdl-get-error result))))]
		       [((* sdl-texture-t)
			 (* sdl-surface-t)
			 (* sdl-cursor-t)
			 (* sdl-pixel-format-t)
			 (* sdl-palette-t)
			 (* sdl-rw-ops-t)
			 (* sdl-mutex-t)
			 (* sdl-window-t)
			 (* sdl-sem-t)
			 (* sdl-cond-t)
			 (* sdl-renderer-t))  #'(sdl-guard-pointer result)]
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

;;; tc base-types.ss ,因为 ffi 的 define-sdl-func需要
;;; 为了嫁接,干掉了驼峰标记,这类型映射也要对应修改  2023年2月21日20:46:47
;;; 即便改成了下面这样,依然在load后报错了 invalid function-ftype argument type specifier Uint8 --  2023年2月22日21:31:33
;;; 在repl对下面这些ftype定义求值之后,再运行sdl就正常了....
;;; 和include的顺序有很大关系,必要的情况下需要分拆文件,就像thunder 那样... -- 2023年2月22日22:44:42
(define-ftype SDL_bool boolean)	;chez-sdl没有的类型
(define-ftype Uint8 unsigned-8)
(define-ftype Uint16 unsigned-16)
(define-ftype Sint16 integer-16)
(define-ftype Uint32 unsigned-32)
(define-ftype Sint32 integer-32)
(define-ftype Sint64 integer-64)
(define-ftype Uint64 integer-64)
(define-ftype size_t Uint32)
(define-ftype va_list void*)
(define-ftype int% int)
(define-ftype file (struct))

(define-ftype sdl-iconv-t void*)

 ;; Conditions
(define-record-type (&sdl2 make-sdl2-condition $sdl2-condition?)
  (parent &condition)
  (fields (immutable status $sdl2-condition-status)))

(define rtd (record-type-descriptor &sdl2))
(define sdl2-condition? (condition-predicate rtd))
(define sdl2-status (condition-accessor rtd $sdl2-condition-status))

;;; tc guardian.ss
;;
;; Copyright 2016 Aldo Nicolas Bruno
;;
;; Licensed under the Apache License, Version 2.0 (the "License");
;; you may not use this file except in compliance with the License.
;; You may obtain a copy of the License at
;;
;;     http://www.apache.org/licenses/LICENSE-2.0
;;
;; Unless required by applicable law or agreed to in writing, software
;; distributed under the License is distributed on an "AS IS" BASIS,
;; WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
;; See the License for the specific language governing permissions and
;; limitations under the License.
(define sdl-guardian (make-guardian))	;make-guardian见CSUG,用于内存管理,垃圾回收

(define (sdl-guard-pointer obj) 
  (sdl-free-garbage) 
  (sdl-guardian obj) 
  obj)

(define sdl-free-garbage-func (lambda () (if #f #f)))
(define (sdl-free-garbage-set-func f) (set! sdl-free-garbage-func f))
(define (sdl-free-garbage) (sdl-free-garbage-func))


;;; tc init.ss

;; (define (sdl-library-init . l)  
;;   ;; 这一手内存管理很强,值得借鉴,从init到退出后的全周期管理
;;   #;(import (only (sdl2 video) sdl-window-t sdl-destroy-window)
;;   (only (sdl2 surface) sdl-surface-t sdl-free-surface)
;;   (only (sdl2 render) sdl-texture-t sdl-destroy-texture sdl-renderer-t sdl-destroy-renderer)
;;   (only (sdl2 mutex) sdl-mutex-t sdl-destroy-mutex sdl-cond-t sdl-destroy-cond)
;;   (only (sdl2 mouse) sdl-cursor-t sdl-free-cursor)
;;   (only (sdl2 pixels) sdl-pixel-format-t sdl-free-format sdl-palette-t sdl-free-palette)
;;   (only (sdl2 rwops) sdl-rw-ops-t sdl-free-rw)	   
;;   (only (sdl2 guardian) sdl-guardian sdl-free-garbage))
;;   (load-shared-object (if (null? l) "libSDL2.so" (car l)))
;;   (sdl-free-garbage-set-func
;;    (lambda ()
;;      (let loop ([p (sdl-guardian)])
;;        (when p
;; 	 (when (ftype-pointer? p)
;; 					;(printf "sdl-free-garbage: freeing memory at ~x\n" p)
;; 	   ;;[(ftype-pointer? usb-device*-array p)
;; 	   (cond 
;; 	    [(ftype-pointer? sdl-window-t p) (sdl-destroy-window p)]
;; 	    [(ftype-pointer? sdl-surface-t p) (sdl-free-surface p)]
;; 	    [(ftype-pointer? sdl-texture-t p) (sdl-destroy-texture p)]
;; 	    [(ftype-pointer? sdl-renderer-t p) (sdl-destroy-renderer p)]
;; 	    [(ftype-pointer? sdl-mutex-t p) (sdl-destroy-mutex p)]			 
;; 	    [(ftype-pointer? sdl-sem-t p) (sdl-destroy-semaphore p)]

;; 	    [(ftype-pointer? sdl-cond-t p) (sdl-destroy-cond p)]
;; 	    [(ftype-pointer? sdl-cursor-t p) (sdl-free-cursor p)]
;; 	    [(ftype-pointer? sdl-pixel-format-t p) (sdl-free-format p)]
;; 	    [(ftype-pointer? sdl-palette-t p) (sdl-free-palette p)]
;; 	    [(ftype-pointer? sdl-rw-ops-t p) (sdl-free-rw p)]
;; 	    [else
;; 	     (foreign-free (ftype-pointer-address p))]
;; 	    ))
;; 	 (loop (sdl-guardian)))))))


;;; tc extras.ss
;;; 和事件循环有关,因为涉及类型嵌套,原chez-sdl已经抽象封装 -- 2023年2月19日20:14:06
;; (define (sdl-event-keyboard-keysym-sym e)
;;   (let* ([keyboard (ftype-&ref SDL_Event (key) e)]
;; 	 [keysym (ftype-&ref SDL_KeyboardEvent (keysym) keyboard)]
;; 	 [sym (ftype-ref sdl-keysym-t (sym) keysym)])
;;     sym))

;; (define (sdl-event-keyboard-keysym-mod e)
;;   (let* ([keyboard (ftype-&ref SDL_Event (key) e)]
;; 	 [keysym (ftype-&ref SDL_KeyboardEvent (keysym) keyboard)]
;; 	 [mod (ftype-ref sdl-keysym-t (mod) keysym)])
;;     mod))
;; (define (sdl-event-mouse-button e)
;;   (let* ([button (ftype-&ref SDL_Event (button) e)]
;; 	 [button* (ftype-ref sdl-mouse-button-event-t (button) button)])
;;     button*))

;;; 文本输入的事件封装
;; (define-ftype char-array (array 0 char))

;; (define (char*-array->string ptr max)
;;   (let loop ([i 0] [r '()])
;;     (let ([x (ftype-ref char-array (i) 
;; 			(make-ftype-pointer char-array 
;; 					    (ftype-pointer-address ptr)))])
;;       (if (or (eqv? x #\nul) (>= i max))
;; 	  (utf8->string (u8-list->bytevector (reverse r)))
;; 	  (loop (+ i 1) (cons (char->integer x) r))))))
