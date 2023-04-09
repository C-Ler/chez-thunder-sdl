;;; 
;; (define-ftype ttf-font
;;   (struct))

(define-ftype TTF_Image
  (struct
    (buffer (* unsigned-8))
    (left int)
    (top int)
    (width int)
    (rows int)
    (pitch int)
    (is_color int)
    ))

(define-ftype c_glyph
  (struct
    (strored int)
    (index void*)
    (bitmap TTF_Image)
    (pixmap TTF_Image)
    (sz_left int)
    (sz_top int)
    (sz_width int)
    (sz_rows int)
    (advance int)
    (value (union			;C语言的union在结构体中似乎不需要名称,chez-sdl中出现了两次,其中一次在嵌套中,使用了名称value,猜测是临时名称--220705
	     (subpixel (struct
			 (lsb_minus_rsb int)
			 (translation int)
			 ))
	     (kerning_smart (struct (rsb_delta int)
				    (lsb_delta int)))
	     ))
    ))

;; (define-ftype FT_Open_Args
;;   )
(define-ftype PosBuf_t
  (struct
    (index void*)
    (x int)
    (y int)))

(define-ftype TTF_Font
  ;; 需要源码,可以不用打开黑盒,该隐藏的隐藏掉;
  ;; 必要的话像thunder学习,直接 (struct) 2023年3月11日20:14:01
  (struct
    (face void*)			;FT_Face保持黑盒吧
    
    (height int)
    (ascent int)
    (descent int)
    (lineskip int)
    
    (style int)
    (outline_val int)
    
    (allow_kerning int)
    (use_kerning int)
    
    (glyph_overhang int)
    
    (line_thickness int)
    (underline_top_row int)
    (strikethrough_top_row int)
    
    (cache (array 256 c_glyph))
    (cache_index (array 128 void*))	;FT_UInt 也保持黑盒
    
    (src void*)		;SDL_RWops 保持黑盒
    (freesrc int)
    (args void*)		;FT_Open_Args也保持黑盒
    
    (pos_buf (* PosBuf_t))
    (pos_len unsigned-32)
    (pos_max unsigned-32)
    
    (ft_load_target int)
    (render_subpixel int)
    ;; 需要读懂预编译的#if段,目前在SDL.h没找到参照 210225
    ;; 也就两种情况,试一试呗,先试第一种,TF_USE_HARFBUZZ为0
    (render_sdf int)
    (horizontal_align int)
    ))

;; flags


;;; 在古早版本的chez无法直接传递结构体参数,thunder用了一个sttf
(define-sdl-func (* SDL_version) TTF_Linked_Version () "TTF_Linked_Version")
(define-sdl-func void TTF_ByteSwappedUNICODE ((swapped int)) "TTF_ByteSwappedUNICODE")
(define-sdl-func int TTF_Init () "TTF_Init")
(define-sdl-func (* TTF_Font) TTF_OpenFont ((file string) (ptsize int)) "TTF_OpenFont")
(define-sdl-func (* TTF_Font) TTF_OpenFontIndex ((file string) (ptsize int) (index long)) "TTF_OpenFontIndex")
(define-sdl-func (* TTF_Font) TTF_OpenFontRW ((src (* SDL_RWops)) (freesrc int) (ptsize int)) "TTF_OpenFontRW")
(define-sdl-func (* TTF_Font) TTF_OpenFontIndexRW ((src (* SDL_RWops)) (freesrc int) (ptsize int) (index long)) "TTF_OpenFontIndexRW")
(define-sdl-func int TTF_GetFontStyle ((font (* TTF_Font))) "TTF_GetFontStyle")
(define-sdl-func void TTF_SetFontStyle ((font (* TTF_Font)) (style int)) "TTF_SetFontStyle")
(define-sdl-func int TTF_GetFontOutline ((font (* TTF_Font))) "TTF_GetFontOutline")
(define-sdl-func void TTF_SetFontOutline ((font (* TTF_Font)) (outline int)) "TTF_SetFontOutline")
(define-sdl-func int TTF_GetFontHinting ((font (* TTF_Font))) "TTF_GetFontHinting")
(define-sdl-func void TTF_SetFontHinting ((font (* TTF_Font)) (hinting int)) "TTF_SetFontHinting")
(define-sdl-func int TTF_FontHeight ((font (* TTF_Font))) "TTF_FontHeight")
(define-sdl-func int TTF_FontAscent ((font (* TTF_Font))) "TTF_FontAscent")
(define-sdl-func int TTF_FontDescent ((font (* TTF_Font))) "TTF_FontDescent")
(define-sdl-func int TTF_FontLineSkip ((font (* TTF_Font))) "TTF_FontLineSkip")
(define-sdl-func int TTF_GetFontKerning ((font (* TTF_Font))) "TTF_GetFontKerning")
(define-sdl-func void TTF_SetFontKerning ((font (* TTF_Font)) (allowed int)) "TTF_SetFontKerning")
(define-sdl-func long TTF_FontFaces ((font (* TTF_Font))) "TTF_FontFaces")
(define-sdl-func int TTF_FontFaceIsFixedWidth ((font (* TTF_Font))) "TTF_FontFaceIsFixedWidth")
(define-sdl-func string TTF_FontFaceFamilyName ((font (* TTF_Font))) "TTF_FontFaceFamilyName")
(define-sdl-func string TTF_FontFaceStyleName ((font (* TTF_Font))) "TTF_FontFaceStyleName")
(define-sdl-func int TTF_GlyphIsProvided ((font (* TTF_Font)) (ch Uint16)) "TTF_GlyphIsProvided")
(define-sdl-func int TTF_GlyphMetrics ((font (* TTF_Font)) (ch Uint16) (minx (* int)) (maxx (* int)) (miny (* int)) (maxy (* int)) (advance (* int))) "TTF_GlyphMetrics")
(define-sdl-func int TTF_SizeText ((font (* TTF_Font)) (text string) (w (* int)) (h (* int))) "TTF_SizeText")
(define-sdl-func int TTF_SizeUTF8 ((font (* TTF_Font)) (text string) (w (* int)) (h (* int))) "TTF_SizeUTF8")
(define-sdl-func int TTF_SizeUNICODE ((font (* TTF_Font)) (text (* Uint16)) (w (* int)) (h (* int))) "TTF_SizeUNICODE")

;;; 文本颜色随机的问题终于解决了,下面这几个,传入的参数不是color的指针,而是color....突然意识到thunder用了个shimmed ttf,读了readme,再读了SDL_ttf的源码,破案了 2023年3月21日19:54:16
(define-sdl-func (* SDL_Surface) TTF_RenderText_Solid ((font (* TTF_Font)) (text string) (
											  fg (& SDL_Color))) "TTF_RenderText_Solid") ;SDL_Color在thunder变成了int,之前自己写的是(* (& SDL_Color))  2023年3月11日22:19:59
(define-sdl-func (* SDL_Surface) TTF_RenderUTF8_Solid ((font (* TTF_Font)) (text string) (fg (& SDL_Color))) "TTF_RenderUTF8_Solid")
(define-sdl-func (* SDL_Surface) TTF_RenderUNICODE_Solid ((font (* TTF_Font)) (text (* Uint16)) (fg (& SDL_Color))) "TTF_RenderUNICODE_Solid")
(define-sdl-func (* SDL_Surface) TTF_RenderGlyph_Solid ((font (* TTF_Font)) (ch Uint16) (fg (& SDL_Color))) "TTF_RenderGlyph_Solid")
(define-sdl-func (* SDL_Surface) TTF_RenderText_Shaded ((font (* TTF_Font)) (text string) (fg (& SDL_Color)) (bg (& SDL_Color))) "TTF_RenderText_Shaded")
(define-sdl-func (* SDL_Surface) TTF_RenderUTF8_Shaded ((font (* TTF_Font)) (text string) (fg (& SDL_Color)) (bg (& SDL_Color))) "TTF_RenderUTF8_Shaded")
(define-sdl-func (* SDL_Surface) TTF_RenderUNICODE_Shaded ((font (* TTF_Font)) (text (* Uint16)) (fg (& SDL_Color)) (bg (& SDL_Color))) "TTF_RenderUNICODE_Shaded")
(define-sdl-func (* SDL_Surface) TTF_RenderGlyph_Shaded ((font (* TTF_Font)) (ch Uint16) (fg
											  (& SDL_Color)) (bg (& SDL_Color))) "TTF_RenderGlyph_Shaded")
(define-sdl-func (* SDL_Surface) TTF_RenderText_Blended ((font (* TTF_Font)) (text string) (fg (& SDL_Color))) "TTF_RenderText_Blended")
(define-sdl-func (* SDL_Surface) TTF_RenderUTF8_Blended ((font (* TTF_Font)) (text string) (fg (& SDL_Color))) "TTF_RenderUTF8_Blended")
(define-sdl-func (* SDL_Surface) TTF_RenderUNICODE_Blended ((font (* TTF_Font)) (text (* Uint16)) (fg (& SDL_Color))) "TTF_RenderUNICODE_Blended")
(define-sdl-func (* SDL_Surface) TTF_RenderText_Blended_Wrapped ((font (* TTF_Font)) (text string) (fg (& SDL_Color)) (wrapLength Uint32)) "TTF_RenderText_Blended_Wrapped")
(define-sdl-func (* SDL_Surface) TTF_RenderUTF8_Blended_Wrapped ((font (* TTF_Font)) (text string) (fg (& SDL_Color)) (wrapLength Uint32)) "TTF_RenderUTF8_Blended_Wrapped")
(define-sdl-func (* SDL_Surface) TTF_RenderUNICODE_Blended_Wrapped ((font (* TTF_Font)) (text (* Uint16)) (fg (& SDL_Color)) (wrapLength Uint32)) "TTF_RenderUNICODE_Blended_Wrapped")
(define-sdl-func (* SDL_Surface) TTF_RenderGlyph_Blended ((font (* TTF_Font)) (ch Uint16) (fg (& SDL_Color))) "TTF_RenderGlyph_Blended")

(define-sdl-func void TTF_CloseFont ((font (* TTF_Font))) "TTF_CloseFont")
(define-sdl-func void TTF_Quit () "TTF_Quit")
(define-sdl-func int TTF_WasInit () "TTF_WasInit")
(define-sdl-func int TTF_GetFontKerningSize ((font (* TTF_Font)) (prev_index int) (index int)) "TTF_GetFontKerningSize")
(define-sdl-func int TTF_GetFontKerningSizeGlyphs ((font (* TTF_Font)) (previous_ch Uint16) (ch Uint16)) "TTF_GetFontKerningSizeGlyphs")
