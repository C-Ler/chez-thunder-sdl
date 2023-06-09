;;;; -*- mode: Scheme; -*-
;;; 
(define (ttf-render ttf-render-foreign-fun ttf-font string sdl-color)
  ;; ttf-render-foreign-fun应当是 ttf-render-xx
  ;; 有些ttf-render可以接受fg和bg,需要进一步实现  2023年3月23日21:59:33
  ;; 返回一个surface
  (let* ((fcolor (if (sdl-color? sdl-color)
		     (sdl-color->ftype sdl-color)
		     (make-ftype-pointer SDL_Color 0)))
	 (return (ttf-render-foreign-fun ttf-font string fcolor)))
    (foreign-free (ftype-pointer-address fcolor))
    return))


(define ttf-linked-version TTF_Linked_Version)
(define ttf-byte-swapped-unicode TTF_ByteSwappedUNICODE)
(define ttf-init TTF_Init)
(define ttf-open-font TTF_OpenFont)
(define ttf-open-font-index TTF_OpenFontIndex)
(define ttf-open-font-rw TTF_OpenFontRW)
(define ttf-open-font-index-rw TTF_OpenFontIndexRW)
(define ttf-get-font-style TTF_GetFontStyle)
(define ttf-set-font-style TTF_SetFontStyle)
(define ttf-get-font-outline TTF_GetFontOutline)
(define ttf-set-font-outline TTF_SetFontOutline)
(define ttf-get-font-hinting TTF_GetFontHinting)
(define ttf-set-font-hinting TTF_SetFontHinting)
(define ttf-font-height TTF_FontHeight)
(define ttf-font-ascent TTF_FontAscent)
(define ttf-font-descent TTF_FontDescent)
(define ttf-font-line-skip TTF_FontLineSkip)
(define ttf-get-font-kerning TTF_GetFontKerning)
(define ttf-set-font-kerning TTF_SetFontKerning)
(define ttf-font-faces TTF_FontFaces)
(define ttf-font-face-is-fixed-width
  TTF_FontFaceIsFixedWidth)
(define ttf-font-face-family-name TTF_FontFaceFamilyName)
(define ttf-font-face-style-name TTF_FontFaceStyleName)
(define ttf-glyph-is-provided TTF_GlyphIsProvided)
(define ttf-glyph-metrics TTF_GlyphMetrics)
(define ttf-size-text TTF_SizeText)
(define ttf-size-utf8 TTF_SizeUTF8)
(define ttf-size-unicode TTF_SizeUNICODE)

(define ttf-render-text-solid TTF_RenderText_Solid)
(define ttf-render-utf8-solid TTF_RenderUTF8_Solid)
(define ttf-render-unicode-solid TTF_RenderUNICODE_Solid)
(define ttf-render-glyph-solid TTF_RenderGlyph_Solid)
(define ttf-render-text-shaded TTF_RenderText_Shaded)
(define ttf-render-utf8-shaded TTF_RenderUTF8_Shaded)
(define ttf-render-unicode-shaded TTF_RenderUNICODE_Shaded)
(define ttf-render-glyph-shaded TTF_RenderGlyph_Shaded)
(define ttf-render-text-blended TTF_RenderText_Blended)
(define ttf-render-utf8-blended TTF_RenderUTF8_Blended)
(define ttf-render-unicode-blended
  TTF_RenderUNICODE_Blended)
(define ttf-render-text-blended-wrapped
  TTF_RenderText_Blended_Wrapped)
(define ttf-render-utf8-blended-wrapped
  TTF_RenderUTF8_Blended_Wrapped)
(define ttf-render-unicode-blended-wrapped
  TTF_RenderUNICODE_Blended_Wrapped)
(define ttf-render-glyph-blended TTF_RenderGlyph_Blended)

(define ttf-close-font TTF_CloseFont)
(define ttf-quit TTF_Quit) (define ttf-was-init TTF_WasInit)
(define ttf-get-font-kerning-size TTF_GetFontKerningSize)
(define ttf-get-font-kerning-size-glyphs
  TTF_GetFontKerningSizeGlyphs)

(define (sdl-ttf-library-init . l)
  (load-shared-object
   (if (null? l)
       ;; 替换了thunder兼容性低的部分  2023年3月2日21:33:16
       (case (machine-type)
	 ((i3nt  ti3nt  a6nt  ta6nt)  "SDL2_ttf.dll")
	 ((i3le  ti3le  a6le  ta6le)  "SDL2_ttf.so")
	 ((i3osx ti3osx a6osx ta6osx) "SDL2_ttf.dylib"))
       (car l)))
  ;; (sdl-free-garbage-set-func
  ;;  (lambda ()
  ;;    (let loop ([p (sdl-guardian)])
  ;;      (when p
  ;; 	 (when (ftype-pointer? p)
  ;; 					;(printf "sdl-free-garbage: freeing memory at ~x\n" p)
  ;; 	   ;;[(ftype-pointer? usb-device*-array p)
  ;; 	   (cond 
  ;; 	    [(ftype-pointer? SDL_Window p) (sdl-destroy-window p)]
  ;; 	    [(ftype-pointer? SDL_Surface p) (sdl-free-surface p)]
  ;; 	    [(ftype-pointer? SDL_Texture p) (sdl-destroy-texture p)]
  ;; 	    [(ftype-pointer? SDL_Renderer p) (sdl-destroy-renderer p)]
  ;; 	    ;; [(ftype-pointer? sdl-mutex-t p) (sdl-destroy-mutex p)]			 
  ;; 	    ;; [(ftype-pointer? sdl-sem-t p) (sdl-destroy-semaphore p)]

  ;; 	    ;; [(ftype-pointer? sdl-cond-t p) (sdl-destroy-cond p)]
  ;; 	    [(ftype-pointer? SDL_Cursor p) (sdl-free-cursor p)]
  ;; 	    [(ftype-pointer? SDL_PixelFormat p) (sdl-free-format p)]
  ;; 	    [(ftype-pointer? SDL_Palette p) (sdl-free-palette p)]
  ;; 	    ;; [(ftype-pointer? sdl-rw-ops-t p) (sdl-free-rw p)]
  ;; 	    [else
  ;; 	     (foreign-free (ftype-pointer-address p))]
  ;; 	    ))
  ;; 	 (loop (sdl-guardian))))))
  )
