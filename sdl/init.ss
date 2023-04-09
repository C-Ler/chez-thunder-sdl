;;; tc init.ss

(define (sdl-library-init . l)  
  ;; 这一手内存管理很强,值得借鉴,从init到退出后的全周期管理
  #;(import (only (sdl2 video) sdl-window-t sdl-destroy-window)
  (only (sdl2 surface) sdl-surface-t sdl-free-surface)
  (only (sdl2 render) sdl-texture-t sdl-destroy-texture sdl-renderer-t sdl-destroy-renderer)
  (only (sdl2 mutex) sdl-mutex-t sdl-destroy-mutex sdl-cond-t sdl-destroy-cond)
  (only (sdl2 mouse) sdl-cursor-t sdl-free-cursor)
  (only (sdl2 pixels) sdl-pixel-format-t sdl-free-format sdl-palette-t sdl-free-palette)
  (only (sdl2 rwops) sdl-rw-ops-t sdl-free-rw)	   
  (only (sdl2 guardian) sdl-guardian sdl-free-garbage))
  
  (load-shared-object
   (if (null? l)
       ;; 替换了thunder兼容性低的部分  2023年3月2日21:33:16
       (case (machine-type)
	 ((i3nt  ti3nt  a6nt  ta6nt)  "SDL2.dll")
	 ((i3le  ti3le  a6le  ta6le)  "libSDL2.so")
	 ((i3osx ti3osx a6osx ta6osx) "libSDL2.dylib"))
       (car l)))
  
  (sdl-free-garbage-set-func
   (lambda ()
     (let loop ([p (sdl-guardian)])
       (when p
	 (when (ftype-pointer? p)
	   (printf "sdl-free-garbage: freeing memory at ~x\n" p) ;没调用部分free代码后,没见到这东西工作,似乎没用  2023年3月27日20:05:20
	   ;;[(ftype-pointer? usb-device*-array p)
	   (cond 
	    [(ftype-pointer? SDL_Window p) (sdl-destroy-window p)]
	    [(ftype-pointer? SDL_Surface p) (sdl-free-surface p)]
	    [(ftype-pointer? SDL_Texture p) (sdl-destroy-texture p)]
	    [(ftype-pointer? SDL_Renderer p) (sdl-destroy-renderer p)]
	    ;; [(ftype-pointer? sdl-mutex-t p) (sdl-destroy-mutex p)]			 
	    ;; [(ftype-pointer? sdl-sem-t p) (sdl-destroy-semaphore p)]

	    ;; [(ftype-pointer? sdl-cond-t p) (sdl-destroy-cond p)]
	    [(ftype-pointer? SDL_Cursor p) (sdl-free-cursor p)]
	    [(ftype-pointer? SDL_PixelFormat p) (sdl-free-format p)]
	    [(ftype-pointer? SDL_Palette p) (sdl-free-palette p)]
	    ;; [(ftype-pointer? sdl-rw-ops-t p) (sdl-free-rw p)]
	    [else
	     (foreign-free (ftype-pointer-address p))]
	    ))
	 (loop (sdl-guardian))))))
  )


