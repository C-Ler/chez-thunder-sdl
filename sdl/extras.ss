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
