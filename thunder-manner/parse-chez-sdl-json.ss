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

;;thx for Aldo Nicolas Bruno; this file has been changed a little by me 2023-4-9 13:26:17

;;(library-directory "xxxx") 需要将thunder 和 srfi 加入库文件路径
;;you should use (library-directory "xxxx") here


(import(scheme)
       (json)
       (only (thunder-utils) string-replace string-split) 
       (only (srfi s13 strings) string-contains string-drop string-downcase string-prefix? string-suffix? string-delete)
       (only (srfi s1 lists) fold)
       (srfi s14 char-sets))


(define (anti-camel x)
  (let* ([x (string-replace x #\_ #\-)]
	 [len (string-length x)]
	 [f (lambda (s len)
	      (list->string
	       (reverse
		(fold (lambda (i acc) 
			(let ([a (string-ref s i)] 
			      [next (if (< (+ 1 i) len) (string-ref s (+ 1 i)) #f)]
			      [prev (if (> i 0) (string-ref s (- i 1)) #f)])
			  (if (and (char-upper-case? a)  next prev
				   (not 
				    (or (char=? a #\-) (char=? prev #\-) (char=? next #\-)
					(and (char-upper-case? next) (char-upper-case? prev)))))
			      (cons (char-downcase a) (cons #\- acc))
			      (cons (char-downcase a) acc)))) '() (iota len)))))])
    (define tbl '(("SDL-RWops" "sdl-rw-ops")
		  ("UDPpacket" "udp-packet") ("TCPsocket" "tcp-socket")
		  ("IPaddress" "ip-address") ("UDPsocket" "udp-socket")))
    (cond
     [(string-prefix? "SDL-GL-" x)
      (string-append "sdl-gl-" (f (string-drop x 7) (- len 7)))]
     [(string-prefix? "SDL-GL" x)
      (string-append "sdl-gl-" (f (string-drop x 6) (- len 6)))]
     [(assoc x tbl) => (lambda (y) (cadr y))]
     [else (f x len)])))

(define (add-t x)
  (let ([xd (string-downcase x)])
    (if (and (string-prefix? "sdl-" xd) 
	     (not  (or (string-suffix? "*" x) (string-suffix? "-t" x))))
	(string-append x "-t")
	x)))

(define (add-* x)
  (string-append x "*"))

(define (decode-type t)
  (if t
      (let-json-object t (tag type)
		       (let ([tag* (if (string? tag) (string->symbol tag) tag)])
			 (case tag*
			   [:function-pointer 'void*]
			   [:int 'int]
			   [:unsigned-int 'unsigned-int]
			   [:unsigned-long-long 'unsigned-long-long]
			   [:unsigned-long 'unsigned-long]
			   [:long 'long]
			   [:double 'double]
			   [:long-double 'long-double]
			   [:float 'float]
			   [:pointer (let ([pt (decode-type type)])
				       ;; 对tag是:pointer的处理,
				       (case pt
					 (char 'string)
					 (string 'void*)
					 (void 'void*)
					 (else
					  (if (and (pair? pt ) (eq? (car pt) '*))
					      pt ;; DOUBLE STAR SEEMS NOT SUPPORTED ON CHEZ
					      `(* ,pt))
					  #;(string->symbol 
					  (add-*
					  (symbol->string pt))))))]
			   [:void 'void]
			   [:char 'char]
			   [else (if (symbol? tag*)
				     tag*
				     ;; 下面这部分应该是对ftype的类型名进行反驼峰并在后面加-t的  2023年2月20日22:21:05
				   
				     (string->symbol 
				      ;; (add-t
				      ;;  (anti-camel 
				      ;; 	(symbol->string
				      tag*
				      ;; )))
				      )
				     )])))
      #f))
(define (decode-param p n)
  (let-json-object p (tag name type)
		   (if (equal? name "") 
		       (list (string-append "arg-" (number->string n)) (decode-type type))
		       (list name (decode-type type)))))


;;; 这个黑名单会导致下面这几个过程吧,在parse之后bind到#f
;;; 只是因为这几个过程使用了结构体作为参数,而不是指针
;;; 而chez-sdl (define SDL_JoystickInstanceID  (sdl-procedure "SDL_JoystickInstanceID" (SDL_Joystick) integer-32))
;;; 如果缺少这几个过程不知道会怎样,先试一下不拉黑名单  2023年2月25日22:10:50
;; (define blacklist '(sdl-joystick-instance-id 
;; 		    sdl-joystick-get-device-guid
;; 		    sdl-joystick-get-guid 
;; 		    sdl-joystick-get-guid-string 
;; 		    sdl-joystick-get-guid-from-string
;; 		    sdl-game-controller-mapping-for-guid))
(define blacklist '())


(define (parse-json-function x m)
  (let-json-object x (tag name location return-type parameters)
		   ;; (测试输出 (list tag name location))
		   (if (and
			;; (or (string-contains location m)
			;;     ;; 这应该是对sdl函数分模块匹配parse的
			;;     ;; 注释掉确实成功导出到一个文件了  2023年2月19日22:13:19
			;;     ;; 如果map在多个m上,会对应生成多个文件,但如果这段的固定string不对,会导致parse出来的代码冗余或者缺失  2023年3月2日21:55:49
			;;     ;; 对sdl2以外的lib...总之不需要对sdl2单独测试文件路径了 因为不用拆分了,m就是路径信息  2023年3月2日22:15:29
			;;     ;; 不行,sdl的部分会缺几乎全部  2023年3月2日22:15:42
			;;     ;; (and (equal? "sdl2" m) (string-contains location "SDL.h"))
			;;     )
			;; 按理说上面全部注释了就OK了,但是不知道为什么image里面会混进sdl的全部  2023年3月2日23:05:21
			;; 暂时就这样了,不是关键问题,凑合用  2023年3月9日20:25:02
			(equal? tag "function")
			(or (string-prefix? "SDL_" name)
			    (string-prefix? "SDLNet_" name)
			    (string-prefix? "IMG_" name)
			    (string-prefix? "STTF_" name)
			    (string-prefix? "TTF_" name)
			    (string-prefix? "Mix_" name)))
		       (cond
			[(memq (string->symbol (anti-camel name)) blacklist)
			 (printf ";;blacklisted probably because it uses a struct as value.\n(define ~d #f)\n" (anti-camel name))]
			[else
			 (printf "(define-sdl-func ~d ~d ~d \"~d\")\n"
				 ;; 返回值
				 (decode-type return-type)
				 ;; 下面这段保证了define-sdl-func 的函数名是anti-camel的,注释掉之后先嫁接一下试试  2023年2月20日20:46:26
				 ;; (case name
				 ;;   ("SDL_log" "sdl-logn")
				 ;;   (else (anti-camel name)))
				 name
				 ;; 参数列表
				 (map (lambda (p n) (decode-param p n)) 
				      (vector->list parameters) 
				      (iota (vector-length parameters)))
				 ;; 接口名称
				 name)]))))

;; (define sdl2-modules-func
;;; 其实不改这里也不是不行,直接自动构造库文件需要import的文件就ok了.  2023年2月19日21:42:19
;;   '(assert atomic audio clipboard
;;     cpuinfo endian error events 
;;     filesystem hints joystick
;;     keyboard loadso log main messagebox
;;     mouse mutex pixels platform power
;;     rect render rwops surface system
;;     thread timer touch version video gamecontroller gesture sdl))

(define sdl2-modules-func
  '(SDL))

(define sdl-json-text (read-file "sdl2.json"))
(define sdl-json (string->json sdl-json-text))

(with-output-to-file "sdl2.sexp" (lambda () (pretty-print sdl-json)) 'truncate)

(for-each (lambda (m) 
	    (with-output-to-file (string-append m "-functions.ss")
	      (lambda () 
		(vector-for-each 
		 (lambda (x) 
		   (parse-json-function x m)) ;parse-json-function 这个会接受 sdl-modules-func作为参数
		 sdl-json))
	      'truncate)) (map symbol->string sdl2-modules-func)) ;目前返回的文件总是空的,应该是和这个parse-json-function有很大关系  2023年2月19日22:04:08

(define sdlnet-json-text (read-file "sdl2-net.json"))
(define sdlnet-json (string->json sdlnet-json-text))

(with-output-to-file "sdl2-net.sexp" (lambda () (pretty-print sdlnet-json)) 'truncate)

(for-each (lambda (m) 
	    (with-output-to-file (string-append m "-functions.ss")
	      (lambda () 
		(vector-for-each 
		 (lambda (x)
		   (parse-json-function x m))
		 sdlnet-json))
	      'truncate)) '("net"))

(define sdlimage-json-text (read-file "sdl2-image.json"))
(define sdlimage-json (string->json sdlimage-json-text))

(with-output-to-file "sdl2-image.sexp" (lambda () (pretty-print sdlimage-json))
		     'truncate)

(for-each (lambda (m)
	    ;; 这里出来的不对,还含着sdl的 不知道哪里出问题了  2023年3月2日21:48:26
	    (with-output-to-file (string-append m "-functions.ss")
	      (lambda ()
		(vector-for-each
		 (lambda (x)
		   (parse-json-function x m))
		 sdlimage-json))
	      'truncate)) '("image"))


(define sdlttfs-json-text (read-file "ttf-shim.json"))
(define sdlttfs-json (string->json sdlttfs-json-text))

(with-output-to-file "ttf-shim.sexp" (lambda () (pretty-print sdlttfs-json))
		     'truncate)

(for-each (lambda (m)
	    (with-output-to-file (string-append m "-functions.ss")
	      (lambda ()
		(vector-for-each
		 (lambda (x)
		   (parse-json-function x m))
		 sdlttfs-json))
	      'truncate)) '("sttf"))

(define sdlttf-json-text (read-file "sdl2-ttf.json"))
(define sdlttf-json (string->json sdlttf-json-text))

(with-output-to-file "sdl2-ttf-real.sexp" (lambda () (pretty-print sdlttf-json))
		     'truncate)

(for-each (lambda (m)
	    (with-output-to-file (string-append m "-functions.ss")
	      (lambda ()
		(vector-for-each
		 (lambda (x)
		   (parse-json-function x m))
		 sdlttf-json))
	      'truncate)) '("ttf"))

;;;;TODO Seriously this should be one function because this
;;;;is a pain in the butt

(define sdlmixer-json-text (read-file "sdl2-mixer.json"))
(define sdlmixer-json (string->json sdlmixer-json-text))

(with-output-to-file "sdl2-mixer.sexp" (lambda () (pretty-print sdlmixer-json))
		     'truncate)

(for-each (lambda (m)
	    (with-output-to-file (string-append m "-functions.ss")
	      (lambda ()
		(vector-for-each
		 (lambda (x)
		   (parse-json-function x m))
		 sdlmixer-json))
	      'truncate)) '("mix"))
