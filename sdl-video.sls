;;;; -*- mode: Scheme; -*-

(define-record-type sdl-rect
  ;; Rect and FRect use same scheme rect rcd.
  (fields (mutable x) (mutable y) w h)		;修改 变成可以修改的槽 -- 230126
  )

(define-record-type sdl-point
  (fields x y))

(define-record-type sdl-color
  (fields r g b a))

(define-record-type sdl-renderer-info
  (fields name
	  flags
	  texture-formats
	  max-texture-width
	  max-texture-height))

(define (sdl-rect->ftype rect)
  (let*
      ((size (ftype-sizeof SDL_Rect))
       (addr (foreign-alloc size))
       (fptr (make-ftype-pointer SDL_Rect addr)))
    (ftype-set! SDL_Rect (x) fptr (exact (round (sdl-rect-x rect))))
    (ftype-set! SDL_Rect (y) fptr (exact (round (sdl-rect-y rect))))
    (ftype-set! SDL_Rect (w) fptr (exact (round (sdl-rect-w rect))))
    (ftype-set! SDL_Rect (h) fptr (exact (round (sdl-rect-h rect))))
    fptr))

(define (sdl-frect->ftype frect)
  (let*
      ((size (ftype-sizeof SDL_FRect))
       (addr (foreign-alloc size))
       (fptr (make-ftype-pointer SDL_FRect addr)))
    (ftype-set! SDL_FRect (x) fptr (inexact (sdl-rect-x frect)))
    (ftype-set! SDL_FRect (y) fptr (inexact (sdl-rect-y frect)))
    (ftype-set! SDL_FRect (w) fptr (inexact (sdl-rect-w frect)))
    (ftype-set! SDL_FRect (h) fptr (inexact (sdl-rect-h frect)))
    fptr))


(define (ftype->sdl-rect rect)
  (if (ftype-pointer-null? rect)
      '()
      (let ((return (make-sdl-rect (ftype-ref SDL_Rect (x) rect)
				   (ftype-ref SDL_Rect (y) rect)
				   (ftype-ref SDL_Rect (w) rect)
				   (ftype-ref SDL_Rect (h) rect))))
	(foreign-free (ftype-pointer-address rect))
	return)))


(define (sdl-point->ftype point)
  (let*
      ((size (ftype-sizeof SDL_Point))
       (addr (foreign-alloc size))
       (fptr (make-ftype-pointer SDL_Point addr)))
    (ftype-set! SDL_Point (x) fptr (sdl-point-x point))
    (ftype-set! SDL_Point (y) fptr (sdl-point-y point))
    fptr))

(define (sdl-fpoint->ftype fpoint)
  (let*
      ((size (ftype-sizeof SDL_FPoint))
       (addr (foreign-alloc size))
       (fptr (make-ftype-pointer SDL_FPoint addr)))
    (ftype-set! SDL_FPoint (x) fptr (inexact (sdl-point-x fpoint)))
    (ftype-set! SDL_FPoint (y) fptr (inexact (sdl-point-y fpoint)))
    fptr))

(define (sdl-color->ftype color)
  (let*
      ((size (ftype-sizeof SDL_Color))
       (addr (foreign-alloc size))
       (fptr (make-ftype-pointer SDL_Color addr)))
    ;; SDL_Color的四个槽都是 unsigned int 类型 0~255, int的 -1 会变成 255...补码很大
    (ftype-set! SDL_Color (r) fptr (sdl-color-r color))
    (ftype-set! SDL_Color (g) fptr (sdl-color-g color))
    (ftype-set! SDL_Color (b) fptr (sdl-color-b color))
    (ftype-set! SDL_Color (a) fptr (sdl-color-a color))
    fptr))

(define (ftype->sdl-point point)
  (error 'SDL-HELPER "Unimplemented" ftype->sdl-point))


(define (sdl-renderer-info->ftype info)
  (error 'SDL-HELPER "Unimplemented" sdl-renderer-info->ftype))

(define (ftype->sdl-renderer-info info)
  (define (get-formats count renderer-info)
    (define (loop index)
      (if (= index count)
	  '()
	  (cons (ftype-ref SDL_RendererInfo (texture_formats index) renderer-info)
		(loop (+ index 1)))))
    (loop 0))

 (define (read-string name)
    (define (loop index)
      (let ((letter (ftype-ref char () name index)))
	(if (char=? letter #\nul)
	    '()
	    (cons letter (loop (+ index 1))))))
    (list->string (loop 0)))

  (if (ftype-pointer-null? info)
      '()
      (let ((return (make-sdl-renderer-info (read-string (ftype-ref SDL_RendererInfo (name) info))
					    (ftype-ref SDL_RendererInfo (flags) info)
					    (get-formats (ftype-ref SDL_RendererInfo (num_texture_formats) info) info)
					    (ftype-ref SDL_RendererInfo (max_texture_width)  info)
					    (ftype-ref SDL_RendererInfo (max_texture_height) info))))
	(foreign-free (ftype-pointer-address info))
	return)))



(define sdl-show-window              SDL_ShowWindow)
(define sdl-destroy-window           SDL_DestroyWindow)
(define sdl-disable-screen-saver     SDL_DisableScreenSaver)
(define sdl-enable-screen-saver      SDL_EnableScreenSaver)
(define sdl-get-current-video-driver SDL_GetCurrentVideoDriver)
(define sdl-get-window-surface       SDL_GetWindowSurface)
(define sdl-get-display-name         SDL_GetDisplayName)
(define sdl-get-grabbed-window       SDL_GetGrabbedWindow)
(define sdl-get-num-display-modes    SDL_GetNumDisplayModes)
(define sdl-get-num-video-displays   SDL_GetNumVideoDisplays)
(define sdl-get-num-video-drivers    SDL_GetNumVideoDrivers)
(define sdl-get-video-driver         SDL_GetVideoDriver)
(define sdl-update-window-surface    SDL_UpdateWindowSurface)
(define sdl-gl-create-context        SDL_GL_CreateContext)
(define sdl-gl-delete-context        SDL_GL_DeleteContext)
(define sdl-gl-get-current-context   SDL_GL_GetCurrentContext)
(define sdl-gl-get-current-window    SDL_GL_GetCurrentWindow)
(define sdl-gl-get-swap-interval     SDL_GL_GetSwapInterval)
(define sdl-gl-make-current          SDL_GL_MakeCurrent)
(define sdl-gl-reset-attributes!     SDL_GL_ResetAttributes)
(define sdl-gl-set-attribute!        SDL_GL_SetAttribute)
(define sdl-gl-set-swap-interval!    SDL_GL_SetSwapInterval)
(define sdl-gl-swap-window           SDL_GL_SwapWindow)

(define (sdl-create-window title x y w h . flags)
  (SDL_CreateWindow title x y w h (fold-left bitwise-ior 0 flags)))

(define (sdl-gl-extension-supported? extension)
  (= SDL-TRUE (SDL_GL_ExtensionSupported extension)))

(define (sdl-gl-get-attribute attribute)
  (let*
      ((c-val (make-ftype-pointer int (foreign-alloc (ftype-sizeof int))))
       (ret   (SDL_GL_GetAttribute attribute c-val))
       (value (ftype-ref int () c-val)))
    (foreign-free (ftype-pointer-address c-val))
    (if (= ret 0) value ret)))

(define (sdl-gl-get-drawable-size window)
  (let
      ((c-w (make-ftype-pointer int (foreign-alloc (ftype-sizeof int))))
       (c-h (make-ftype-pointer int (foreign-alloc (ftype-sizeof int)))))
    (SDL_GL_GetDrawableSize window c-w c-h)
    (let
	((w (ftype-ref int () c-w))
	 (h (ftype-ref int () c-h)))
      (foreign-free (ftype-pointer-address c-w))
      (foreign-free (ftype-pointer-address c-h))
      (list w h))))

(define (sdl-get-display-bounds display-index)
  (let*
      ((c-rect (make-ftype-pointer SDL_Rect (foreign-alloc (ftype-sizeof SDL_Rect))))
       (ret (SDL_GetDisplayBounds display-index c-rect))
       (val (if (= ret 0)
		(make-sdl-rect (ftype-ref SDL_Rect (x) c-rect)
			       (ftype-ref SDL_Rect (y) c-rect)
			       (ftype-ref SDL_Rect (w) c-rect)
			       (ftype-ref SDL_Rect (h) c-rect))
		ret)))
    (foreign-free (ftype-pointer-address c-rect))
    val))

(define (sdl-get-display-dpi display-index)
  (let*
      ((c-ddpi (make-ftype-pointer float (foreign-alloc (ftype-sizeof float))))
       (c-hdpi (make-ftype-pointer float (foreign-alloc (ftype-sizeof float))))
       (c-vdpi (make-ftype-pointer float (foreign-alloc (ftype-sizeof float))))
       (f-ret  (SDL_GetDisplayDPI display-index c-ddpi c-hdpi c-vdpi))
       (val (if (= f-ret 0)
		(list (ftype-ref float () c-ddpi)
		      (ftype-ref float () c-hdpi)
		      (ftype-ref float () c-vdpi))
		f-ret)))
    (foreign-free (ftype-pointer-address c-ddpi))
    (foreign-free (ftype-pointer-address c-hdpi))
    (foreign-free (ftype-pointer-address c-vdpi))
    val))

(define (sdl-get-display-usable-bounds display-index)
  (let*
      ((c-rect (make-ftype-pointer SDL_Rect (foreign-alloc (ftype-sizeof SDL_Rect))))
       (ret (SDL_GetDisplayUsableBounds display-index c-rect))
       (val (if (= ret 0)
		(make-sdl-rect (ftype-ref SDL_Rect (x) c-rect)
			       (ftype-ref SDL_Rect (y) c-rect)
			       (ftype-ref SDL_Rect (w) c-rect)
			       (ftype-ref SDL_Rect (h) c-rect))
		ret)))
    (foreign-free (ftype-pointer-address c-rect))
    val))



#| 2D Accelerated Rendering
   ------------------------
   https://wiki.libsdl.org/CategoryRender
|#

(define sdl-compose-custom-blend-mode SDL_ComposeCustomBlendMode)

(define (sdl-create-renderer window index . flags)
  (SDL_CreateRenderer window index (fold-left bitwise-ior 0 flags)))

(define sdl-create-software-renderer    SDL_CreateSoftwareRenderer)
(define sdl-create-texture              SDL_CreateTexture)
(define sdl-create-texture-from-surface SDL_CreateTextureFromSurface)
(define sdl-destroy-renderer            SDL_DestroyRenderer)
(define sdl-destroy-texture             SDL_DestroyTexture)

(define (sdl-gl-bind-texture texture)
  (let* ((texw (make-ftype-pointer float (foreign-alloc (ftype-sizeof float))))
	 (texh (make-ftype-pointer float (foreign-alloc (ftype-sizeof float))))
	 (return (if (= 0 (SDL_GL_BindTexture texture texw texh))
		     (list (ftype-ref float () texw)
			   (ftype-ref float () texh))
		     '())))
    (foreign-free (ftype-pointer-address texw))
    (foreign-free (ftype-pointer-address texh))
    return))

(define sdl-gl-unbind-texture      SDL_GL_UnbindTexture)
(define sdl-get-num-render-drivers SDL_GetNumRenderDrivers)

(define (sdl-get-render-draw-blend-mode renderer)
(let* ((blend  (make-ftype-pointer int (foreign-alloc (ftype-sizeof int))))
       (error  (SDL_GetRenderDrawBlendMode renderer blend))
       (return (if (= 0 error)
		   (ftype-ref int () blend)
		   error)))
  (foreign-free (ftype-pointer-address blend))
  return))

(define (sdl-get-render-draw-color renderer)
  (let* ((r      (make-ftype-pointer unsigned-8 (foreign-alloc 1)))
	 (g      (make-ftype-pointer unsigned-8 (foreign-alloc 1)))
	 (b      (make-ftype-pointer unsigned-8 (foreign-alloc 1)))
	 (a      (make-ftype-pointer unsigned-8 (foreign-alloc 1)))
	 (return (if (= 0 (SDL_GetRenderDrawColor renderer r g b a))
		     (list (ftype-ref unsigned-8 () r)
			   (ftype-ref unsigned-8 () g)
			   (ftype-ref unsigned-8 () b)
			   (ftype-ref unsigned-8 () a))
		     '())))
    (foreign-free (ftype-pointer-address r))
    (foreign-free (ftype-pointer-address g))
    (foreign-free (ftype-pointer-address b))
    (foreign-free (ftype-pointer-address a))
    return))

(define (sdl-get-render-driver-info index)
  (let* ((info  (make-ftype-pointer SDL_RendererInfo (foreign-alloc (ftype-sizeof SDL_RendererInfo))))
	 (error (SDL_GetRenderDriverInfo index info)))
    (if (= 0 error)
	(ftype->sdl-renderer-info info)
	error)))

(define sdl-get-render-target SDL_GetRenderTarget)
(define sdl-get-renderer      SDL_GetRenderer)

(define (sdl-get-renderer-info renderer)
  (let* ((info  (make-ftype-pointer SDL_RendererInfo (foreign-alloc (ftype-sizeof SDL_RendererInfo))))
	 (error (SDL_GetRendererInfo renderer info)))
    (if (= 0 error)
	(ftype->sdl-renderer-info info)
	error)))

(define (sdl-get-renderer-output-size renderer)
  (let* ((w      (make-ftype-pointer int (foreign-alloc (ftype-sizeof int))))
	 (h      (make-ftype-pointer int (foreign-alloc (ftype-sizeof int))))
	 (return (if (= 0 (SDL_GetRendererOutputSize renderer w h))
		     (list (ftype-ref int () w)
			   (ftype-ref int () h))
		     '())))
    (foreign-free (ftype-pointer-address w))
    (foreign-free (ftype-pointer-address h))
    return))

(define (sdl-get-texture-alpha-mod texture)
  (let* ((alpha  (make-ftype-pointer unsigned-8 (foreign-alloc (ftype-sizeof unsigned-8))))
	 (error  (SDL_GetTextureAlphaMod texture alpha))
	 (return (if (= 0 error)
		     (ftype-ref unsigned-8 () alpha)
		     error)))
    (foreign-free (ftype-pointer-address alpha))
    return))

(define (sdl-get-texture-blend-mode texture)
  (let* ((blend  (make-ftype-pointer int (foreign-alloc (ftype-sizeof int))))
	 (error  (SDL_GetTextureBlendMode texture blend))
	 (return (if (= 0 error)
		     (ftype-ref int () blend)
		     error)))
    (foreign-free (ftype-pointer-address blend))
    return))

(define (sdl-get-texture-color-mod texture)
  (let* ((r      (make-ftype-pointer unsigned-8 (foreign-alloc (ftype-sizeof unsigned-8))))
	 (g      (make-ftype-pointer unsigned-8 (foreign-alloc (ftype-sizeof unsigned-8))))
	 (b      (make-ftype-pointer unsigned-8 (foreign-alloc (ftype-sizeof unsigned-8))))
	 (return (if (= 0 (SDL_GetTextureColorMod texture r g b))
		     (list (ftype-ref unsigned-8 () r)
			   (ftype-ref unsigned-8 () g)
			   (ftype-ref unsigned-8 () b))
		     '())))
    (foreign-free (ftype-pointer-address r))
    (foreign-free (ftype-pointer-address g))
    (foreign-free (ftype-pointer-address b))
    return))

(define (sdl-query-texture texture)
  ;; 这种接受四个指针,修改指针指向内存的内容,只用返回值作为成功标识的过程的封装方法,同上面那个sdl-get-texture-color-mod一样
  ;; 应该是夏天时候手撸的,而且和SDL本来的作用并不一样,并不是返回0或-1这么简单 -- 20221217
  (let* ((format (make-ftype-pointer unsigned-32 (foreign-alloc (ftype-sizeof unsigned-32))))
	 (access (make-ftype-pointer int (foreign-alloc (ftype-sizeof int))))
	 (w (make-ftype-pointer int (foreign-alloc (ftype-sizeof int))))
	 (h (make-ftype-pointer int (foreign-alloc (ftype-sizeof int))))
	 (return (if (= 0 (SDL_QueryTexture texture format access w h))
		     (list (ftype-ref unsigned-32 () format)
			   (ftype-ref int () access)
			   (ftype-ref int () w)
			   (ftype-ref int () h))
		     '())))
    (foreign-free (ftype-pointer-address format))
    (foreign-free (ftype-pointer-address access))
    (foreign-free (ftype-pointer-address w))
    (foreign-free (ftype-pointer-address h))
    return
    ))

(define sdl-render-clear SDL_RenderClear)

(define (sdl-render-copy renderer texture src-rect dst-rect)
  (let* ((src    (if (sdl-rect? src-rect)
		     (sdl-rect->ftype src-rect)
		     (make-ftype-pointer SDL_Rect 0)))
	 (dst    (if (sdl-rect? dst-rect)
		     (sdl-rect->ftype dst-rect)
		     (make-ftype-pointer SDL_Rect 0)))
	 (return (SDL_RenderCopy renderer texture src dst)))
    (if (sdl-rect? src-rect) (foreign-free (ftype-pointer-address src)))
    (if (sdl-rect? dst-rect) (foreign-free (ftype-pointer-address dst)))
    return))

(define (sdl-render-copy-ex renderer texture src-rect dst-rect angle center-point flip)
  (let* ((src    (if (sdl-rect? src-rect)
		     (sdl-rect->ftype src-rect)
		     (make-ftype-pointer SDL_Rect 0)))
	 (dst    (if (sdl-rect? dst-rect)
		     (sdl-rect->ftype dst-rect)
		     (make-ftype-pointer SDL_Rect 0)))
	 (center (if (sdl-point? center-point)
		     (sdl-point->ftype center-point)
		     (make-ftype-pointer SDL_Point 0)))
	 (return (SDL_RenderCopyEx renderer
				   texture
				   src dst
				   angle
				   center
				   flip)))
    (if (sdl-rect? src-rect)      (foreign-free (ftype-pointer-address src)))
    (if (sdl-rect? dst-rect)      (foreign-free (ftype-pointer-address dst)))
    (if (sdl-point? center-point) (foreign-free (ftype-pointer-address center)))
    return))

(define (sdl-render-copy-exf renderer texture src-frect dst-frect angle center-fpoint FLIP)
  (let* ((src    (if (sdl-rect? src-frect)
		     (sdl-frect->ftype src-frect)
		     (make-ftype-pointer SDL_FRect 0)))
	 (dst    (if (sdl-rect? dst-frect)
		     (sdl-frect->ftype dst-frect)
		     (make-ftype-pointer SDL_FRect 0)))
	 ;; 不同于上面的ex,center-fp是NULL会报错,不过在能把sdl-rect转换为整形之后,这个函数也没有意义了  2023年4月3日23:07:08
	 (center (if (sdl-point? center-fpoint)
		     (sdl-fpoint->ftype center-fpoint)
		     (make-ftype-pointer SDL_FPoint 0)))
	 ;; 疑似自己扩展的,下面这个SDL_RenderCopyExF在原chez-sdl和thunder都找不到  2023年2月28日22:55:07
	 (return (SDL_RenderCopyExF renderer
				    texture
				    src dst
				    angle
				    center
				    FLIP)))
    (if (sdl-rect? src-frect)      (foreign-free (ftype-pointer-address src)))
    (if (sdl-rect? dst-frect)      (foreign-free (ftype-pointer-address dst)))
    (if (sdl-point? center-fpoint) (foreign-free (ftype-pointer-address center)))
    return))

(define sdl-render-draw-line SDL_RenderDrawLine)

(define (sdl-render-draw-lines renderer points)
  (define (fill data count index points-list)
    (if (= index count)
	'()
	(begin
	  (ftype-set! SDL_Point (x) data index (sdl-point-x (car points-list)))
	  (ftype-set! SDL_Point (y) data index (sdl-point-y (car points-list)))
	  (fill data count (+ index 1) (cdr points-list)))))
  (let* ((count (length points))
	 (chunk (make-ftype-pointer SDL_Point (foreign-alloc (* count (ftype-sizeof SDL_Point))))))
    (fill chunk count 0 points)
    (let ((return (SDL_RenderDrawLines renderer chunk count)))
      (foreign-free (ftype-pointer-address chunk))
      return)))

(define sdl-render-draw-point SDL_RenderDrawPoint)

(define (sdl-render-draw-points renderer points)
  (define (fill data count index points-list)
    (if (= index count)
	'()
	(begin
	  (ftype-set! SDL_Point (x) data index (sdl-point-x (car points-list)))
	  (ftype-set! SDL_Point (y) data index (sdl-point-y (car points-list)))
	  (fill data count (+ index 1) (cdr points-list)))))
  (let* ((count (length points))
	 (chunk (make-ftype-pointer SDL_Point (foreign-alloc (* count (ftype-sizeof SDL_Point))))))
    (fill chunk count 0 points)
    (let ((return (SDL_RenderDrawPoints renderer chunk count)))
      (foreign-free (ftype-pointer-address chunk))
      return)))

(define (sdl-render-draw-rect renderer rect)
  (let* ((frect (if (sdl-rect? rect)
		    (sdl-rect->ftype rect)
		    (make-ftype-pointer SDL_Rect 0)))
	 (return (SDL_RenderDrawRect renderer frect)))
    (if (sdl-rect? rect) (foreign-free (ftype-pointer-address frect)))
    return))

(define (sdl-render-draw-rects renderer rects)
  (define (fill data count index rects-list)
    (if (= index count)
	'()
	(begin
	  (ftype-set! SDL_Rect (x) data index (sdl-rect-x (car rects-list)))
	  (ftype-set! SDL_Rect (y) data index (sdl-rect-y (car rects-list)))
	  (ftype-set! SDL_Rect (w) data index (sdl-rect-w (car rects-list)))
	  (ftype-set! SDL_Rect (h) data index (sdl-rect-h (car rects-list)))
	  (fill data count (+ index 1) (cdr rects-list)))))
  (let* ((count (length rects))
	 (chunk (make-ftype-pointer SDL_Rect (foreign-alloc (* count (ftype-sizeof SDL_Rect))))))
    (fill chunk count 0 rects)
    (let ((return (SDL_RenderDrawRects renderer chunk count)))
      (foreign-free (ftype-pointer-address chunk))
      return)))

(define (sdl-render-fill-rect renderer rect)
  (let* ((frect (if (sdl-rect? rect)
		    (sdl-rect->ftype rect)
		    (make-ftype-pointer SDL_Rect 0)))
	 (return (SDL_RenderFillRect renderer frect)))
    (if (sdl-rect? rect) (foreign-free (ftype-pointer-address frect)))
    return))

(define (sdl-render-fill-rects renderer rects)
  (define (fill data count index rects-list)
    (if (= index count)
	'()
	(begin
	  (ftype-set! SDL_Rect (x) data index (sdl-rect-x (car rects-list)))
	  (ftype-set! SDL_Rect (y) data index (sdl-rect-y (car rects-list)))
	  (ftype-set! SDL_Rect (w) data index (sdl-rect-w (car rects-list)))
	  (ftype-set! SDL_Rect (h) data index (sdl-rect-h (car rects-list)))
	  (fill data count (+ index 1) (cdr rects-list)))))
  (let* ((count (length rects))
	 (chunk (make-ftype-pointer SDL_Rect (foreign-alloc (* count (ftype-sizeof SDL_Rect))))))
    (fill chunk count 0 rects)
    (let ((return (SDL_RenderFillRects renderer chunk count)))
      (foreign-free (ftype-pointer-address chunk))
      return)))

(define (sdl-render-get-clip-rect renderer)
  (let ((rect (make-ftype-pointer SDL_Rect (foreign-alloc (ftype-sizeof SDL_Rect)))))
    (SDL_RenderGetClipRect renderer rect)
    (ftype->sdl-rect rect)))

(define (sdl-render-get-integer-scale renderer)
  (SDL_RenderGetIntegerScale renderer))

(define (sdl-render-get-logical-size renderer)
  (let ((w (make-ftype-pointer int (foreign-alloc (ftype-sizeof int))))
	(h (make-ftype-pointer int (foreign-alloc (ftype-sizeof int)))))
    (SDL_RenderGetLogicalSize renderer w h)
    (let ((return (list (ftype-ref int () w)
			(ftype-ref int () h))))
      (foreign-free (ftype-pointer-address w))
      (foreign-free (ftype-pointer-address h))
      return)))

(define (sdl-render-get-scale renderer)
  (let ((x (make-ftype-pointer float (foreign-alloc (ftype-sizeof float))))
	(y (make-ftype-pointer float (foreign-alloc (ftype-sizeof float)))))
    (SDL_RenderGetScale renderer x y)
    (let ((return (list (ftype-ref float () x)
			(ftype-ref float () y))))
      (foreign-free (ftype-pointer-address x))
      (foreign-free (ftype-pointer-address y))
      return)))

(define (sdl-render-get-viewport renderer)
  (let ((rect (make-ftype-pointer SDL_Rect (foreign-alloc (ftype-sizeof SDL_Rect)))))
    (SDL_RenderGetViewport renderer rect)
    (ftype->sdl-rect rect)))

(define (sdl-render-is-clip-enabled? renderer)
  (= (SDL_RenderIsClipEnabled renderer) SDL-TRUE))

(define sdl-render-present SDL_RenderPresent)

(define (sdl-render-set-clip! renderer rect)
  (let* ((clip   (if (sdl-rect? rect)
		     (sdl-rect->ftype rect)
		     (make-ftype-pointer SDL_Rect 0)))
	 (return (SDL_RenderSetClipRect renderer clip)))
    (if (sdl-rect? rect) (foreign-free (ftype-pointer-address clip)))
    return))

(define sdl-render-set-integer-scale! SDL_RenderSetIntegerScale)
(define sdl-render-set-logical-size!  SDL_RenderSetLogicalSize)
(define sdl-render-set-scale!         SDL_RenderSetScale)

(define (sdl-render-set-viewport! renderer rect)
  (let* ((view   (if (sdl-rect? rect)
		     (sdl-rect->ftype rect)
		     (make-ftype-pointer SDL_Rect 0)))
	 (return (SDL_RenderSetViewport renderer view)))
    (if (sdl-rect? rect) (foreign-free (ftype-pointer-address view)))
    return))

(define (sdl-render-target-supported? renderer)
  (= (SDL_RenderTargetSupported renderer) SDL-TRUE))

(define sdl-set-render-draw-blend-mode! SDL_SetRenderDrawBlendMode)
(define sdl-set-render-draw-color!      SDL_SetRenderDrawColor)
(define sdl-set-render-target!          SDL_SetRenderTarget)
(define sdl-set-texture-alpha-mod!      SDL_SetTextureAlphaMod)
(define sdl-set-texture-blend-mode!     SDL_SetTextureBlendMode)
(define sdl-set-texture-color-mod!      SDL_SetTextureColorMod)



#| Pixel Formats and Conversion Routines
   -------------------
   https://wiki.libsdl.org/CategoryPixels
|#

(define sdl-alloc-format SDL_AllocFormat)
(define sdl-alloc-palette SDL_AllocPalette)

(define (sdl-calc-gamma-ramp gamma)
  (define (to-list arr)
    (define (loop index)
      (if (= index 256)
	  '()
	  (cons (ftype-ref unsigned-16 () arr index)
		(loop (+ index 1)))))
    (loop 0))
  (let* ((ramp   (make-ftype-pointer unsigned-16 (foreign-alloc (* 256 (ftype-sizeof unsigned-16)))))
	 (****   (SDL_CalculateGammaRamp gamma ramp))
	 (return (to-list ramp)))
    (foreign-free (ftype-pointer-address ramp))
    return))

(define sdl-free-format SDL_FreeFormat)
(define sdl-free-palette SDL_FreePalette)
(define (sdl-get-pixel-format-name format)
  (SDL_GetPixelFormatName format)) ;以人类可读形式将pixelformat转化为SDL定义的常量--20221127

(define (sdl-get-rgb pixel format)
  (let* ((r      (make-ftype-pointer unsigned-8 (foreign-alloc (ftype-sizeof unsigned-8))))
	 (g      (make-ftype-pointer unsigned-8 (foreign-alloc (ftype-sizeof unsigned-8))))
	 (b      (make-ftype-pointer unsigned-8 (foreign-alloc (ftype-sizeof unsigned-8))))
	 (****   (SDL_GetRGB pixel format r g b))
	 (return (list (ftype-ref unsigned-8 () r)
		       (ftype-ref unsigned-8 () g)
		       (ftype-ref unsigned-8 () b))))
    (foreign-free (ftype-pointer-address r))
    (foreign-free (ftype-pointer-address g))
    (foreign-free (ftype-pointer-address b))
    return))

(define (sdl-get-rgba pixel format)
  (let* ((r      (make-ftype-pointer unsigned-8 (foreign-alloc (ftype-sizeof unsigned-8))))
	 (g      (make-ftype-pointer unsigned-8 (foreign-alloc (ftype-sizeof unsigned-8))))
	 (b      (make-ftype-pointer unsigned-8 (foreign-alloc (ftype-sizeof unsigned-8))))
	 (a      (make-ftype-pointer unsigned-8 (foreign-alloc (ftype-sizeof unsigned-8))))
	 (****   (SDL_GetRGBA pixel format r g b a))
	 (return (list (ftype-ref unsigned-8 () r)
		       (ftype-ref unsigned-8 () g)
		       (ftype-ref unsigned-8 () b)
		       (ftype-ref unsigned-8 () a))))
    (foreign-free (ftype-pointer-address r))
    (foreign-free (ftype-pointer-address g))
    (foreign-free (ftype-pointer-address b))
    (foreign-free (ftype-pointer-address a))
    return))

(define sdl-map-rgb SDL_MapRGB)
(define sdl-map-rgba SDL_MapRGBA)
(define sdl-masks->pixel-format SDL_MasksToPixelFormatEnum)

(define (sdl-pixel-format->masks format)
  (let* ((bpp    (make-ftype-pointer int (foreign-alloc (ftype-sizeof int))))
	 (Rmask  (make-ftype-pointer unsigned-32 (foreign-alloc (ftype-sizeof unsigned-32))))
	 (Gmask  (make-ftype-pointer unsigned-32 (foreign-alloc (ftype-sizeof unsigned-32))))
	 (Bmask  (make-ftype-pointer unsigned-32 (foreign-alloc (ftype-sizeof unsigned-32))))
	 (Amask  (make-ftype-pointer unsigned-32 (foreign-alloc (ftype-sizeof unsigned-32))))
	 (result (SDL_PixelFormatEnumToMasks format bpp Rmask Gmask Bmask Amask))
	 (return (if (= result SDL-TRUE)
		     (list (ftype-ref unsigned-8 () bpp)
			   (ftype-ref unsigned-8 () Rmask)
			   (ftype-ref unsigned-8 () Gmask)
			   (ftype-ref unsigned-8 () Bmask)
			   (ftype-ref unsigned-8 () Amask))
		     '())))
    (foreign-free (ftype-pointer-address bpp))
    (foreign-free (ftype-pointer-address Rmask))
    (foreign-free (ftype-pointer-address Gmask))
    (foreign-free (ftype-pointer-address Bmask))
    (foreign-free (ftype-pointer-address Amask))
    return))

(define (sdl-set-palette-colors! palette index colors)
  (let* ((ncolors (length colors))
	 ;; 下面开辟了一整块ncolors x SDL_Color规格的内存空间
	 (fcolors (make-ftype-pointer SDL_Color (foreign-alloc (* ncolors (ftype-sizeof SDL_Color))))))
    ;; 先定义了一个类型转换
    (define (colors->ftype colors)
      ;; 再在其中定义了一个loop,从初始内存地址开始set!
      (define (loop index colors)
	(if (null? colors)
	    fcolors
	    (begin
	      (ftype-set! SDL_Color (r) fcolors (sdl-color-r (car colors)) index) ;这个index和value的位置应该是反了
	      (ftype-set! SDL_Color (g) fcolors (sdl-color-g (car colors)) index)
	      (ftype-set! SDL_Color (b) fcolors (sdl-color-b (car colors)) index)
	      (ftype-set! SDL_Color (a) fcolors (sdl-color-a (car colors)) index)
	      (loop (+ index 1) (cdr colors)))))
      ;; 运行loop,填充内存空间,这手法...  2023年3月12日16:07:16
      (loop 0 colors))			
    (let ((result (SDL_SetPaletteColors palette fcolors index ncolors)))
      (foreign-free (ftype-pointer-address fcolors))
      result)))

(define sdl-set-pixel-format-palette! SDL_SetPixelFormatPalette)



#| Rectangle Utilities
   -------------------
   https://wiki.libsdl.org/CategoryRect
|#

(define (sdl-rect=? rect-a rect-b)
  (and (= (sdl-rect-x rect-a) (sdl-rect-x rect-b))
       (= (sdl-rect-y rect-a) (sdl-rect-y rect-b))
       (= (sdl-rect-w rect-a) (sdl-rect-w rect-b))
       (= (sdl-rect-h rect-a) (sdl-rect-h rect-b))))

(define (sdl-rect-empty? rect)
  (or (<= (sdl-rect-w rect) 0)
      (<= (sdl-rect-h rect) 0)))

(define (sdl-rect-intersection? rect-a rect-b)
  (error 'SDL "Unimplemented" sdl-rect-intersection?))

(define (sdl-has-intersection? rect-a rect-b)
  (let* ((rect-a-ptr (sdl-rect->ftype rect-a))
	 (rect-b-ptr (sdl-rect->ftype rect-a))
	 (res (SDL_HasIntersection rect-a-ptr rect-b-ptr)))
    (foreign-free (ftype-pointer-address rect-a-ptr))
    (foreign-free (ftype-pointer-address rect-b-ptr))
    res))

(define (sdl-rect-intersect rect-a rect-b)
  (error 'SDL "Unimplemented" sdl-rect-intersect))

(define (sdl-rect-union rect-a rect-b)
  (if (sdl-rect-empty? rect-a)
      (if (sdl-rect-empty? rect-b)
	  (make-sdl-rect 0 0 0 0)
	  rect-b)
      (if (sdl-rect-empty? rect-b)
	  rect-a
	  (let* ((a-min (sdl-rect-x rect-a))
		 (a-max (+ a-min (sdl-rect-w rect-a)))
		 (b-min (sdl-rect-x rect-b))
		 (b-max (+ b-min (sdl-rect-w rect-b)))
		 (min   (if (< b-min a-min) b-min a-min))
		 (max   (if (> b-max a-max) b-max a-max))
		 (x     min)
		 (w     (- max min))
		 (a-min (sdl-rect-y rect-a))
		 (a-max (+ a-min (sdl-rect-h rect-a)))
		 (b-min (sdl-rect-y rect-b))
		 (b-max (+ b-min (sdl-rect-h rect-b)))
		 (min   (if (< b-min a-min) b-min a-min))
		 (max   (if (> b-max a-max) b-max a-max))
		 (y     min)
		 (h     (- max min)))
	    (make-sdl-rect x y w h)))))

(define (sdl-rect-enclose-points points clip)
  (error 'SDL "Unimplemented" sdl-rect-enclose-points))

(define (sdl-rect-intersect-line rect x1 y1 x2 yx)
  (error 'SDL "Unimplemented" sdl-rect-intersect-line))



#| Surface Creation and Simple Drawing
   -----------------------------------
   https://wiki.libsdl.org/CategorySurface
|#

(define (sdl-blit-scaled src src-rect dst dst-rect)
  (let ((fsrc-rect (sdl-rect->ftype src-rect))
	(fdst-rect (sdl-rect->ftype dst-rect)))
    (SDL_UpperBlitScaled src fsrc-rect dst fdst-rect)
    (foreign-free (ftype-pointer-address fsrc-rect))
    (foreign-free (ftype-pointer-address fdst-rect))))

(define (sdl-blit-surface src src-rect dst dst-rect)
  (let ((fsrc-rect (sdl-rect->ftype src-rect))
	(fdst-rect (sdl-rect->ftype dst-rect)))
    (SDL_UpperBlit src fsrc-rect dst fdst-rect)
    (foreign-free (ftype-pointer-address fsrc-rect))
    (foreign-free (ftype-pointer-address fdst-rect))))

(define (sdl-convert-surface surface-src surface-pixelforamt-aim flag-u32)
  ;; 还有一个第三参数flags,用来兼容sdl1.2的,
  (SDL_ConvertSurface surface-src surface-pixelforamt-aim flag-u32)
  ;; (SDL_ConvertSurface surface-src surface-pixelforamt-aim 0) ;用0直接缺省一个参数不行,会报 SDL_ConvertSurface 参数数量不对
  ;; (let* ((aimsurfaceptr (make-ftype-pointer SDL_Surface (foreign-alloc (ftype-sizeof SDL_Surface)))))) ;ftype-set!只能按槽诸个赋值,得换个办法,比如使用sdl-memcpy什么的
  ) 

(define (sdl-convert-surface-format surface-src format-u32 flag-u32)
  ;; 类似上面,更方便使用,不过没有对pallet做变换
  (SDL_ConvertSurfaceFormat surface-src format-u32 flag-u32))
(define sdl-create-rgb-surface             SDL_CreateRGBSurface)
(define bytevector->sdl-surface            SDL_CreateRGBSurfaceFrom) ;; SDL_CreateRGBSurfaceWithFormatFrom
(define sdl-create-rgb-surface-with-format SDL_CreateRGBSurfaceWithFormat)

(define (sdl-fill-rect dst rect color)
  (let ((frect (sdl-rect->ftype rect)))
    (SDL_FillRect dst frect color)
    (foreign-free (ftype-pointer-address frect))))

(define (sdl-fill-rects dst rects color)
  (define (fill data count index rects-list)
    (if (= index count)
	'()
	(begin
	  (ftype-set! SDL_Rect (x) data index (sdl-rect-x (car rects-list)))
	  (ftype-set! SDL_Rect (y) data index (sdl-rect-y (car rects-list)))
	  (ftype-set! SDL_Rect (w) data index (sdl-rect-w (car rects-list)))
	  (ftype-set! SDL_Rect (h) data index (sdl-rect-h (car rects-list)))
	  (fill data count (+ index 1) (cdr rects-list)))))
  (let* ((count (length rects))
	 (chunk (make-ftype-pointer SDL_Rect (foreign-alloc (* count (ftype-sizeof SDL_Rect))))))
    (fill chunk count 0 rects)
    (SDL_FillRects dst chunk count color)
    (foreign-free (ftype-pointer-address chunk))))

(define sdl-free-surface SDL_FreeSurface)

(define (sdl-get-clip-rect surface)
  (let ((c-rect (make-ftype-pointer SDL_Rect (foreign-alloc (ftype-sizeof SDL_Rect)))))
    (SDL_GetClipRect surface c-rect)
    (ftype->sdl-rect c-rect)))

(define (sdl-get-color-key surface)
  (let* ((key    (make-ftype-pointer unsigned-32 (foreign-alloc (ftype-sizeof unsigned-32))))
	 (error  (SDL_GetColorKey surface key))
	 (return (if (= 0 error)
		     (key (ftype-ref unsigned-32 () key))
		     error)))
    (foreign-free (ftype-pointer-address key))
    return))

(define (sdl-get-surface-alpha-mod texture)
  (let* ((alpha  (make-ftype-pointer unsigned-8 (foreign-alloc (ftype-sizeof unsigned-8))))
	 (error  (SDL_GetSurfaceAlphaMod texture alpha))
	 (return (if (= 0 error)
		     (ftype-ref unsigned-8 () alpha)
		     error)))
    (foreign-free (ftype-pointer-address alpha))
    return))

(define (sdl-get-surface-blend-mode surface)
  (let* ((blend  (make-ftype-pointer int (foreign-alloc (ftype-sizeof int))))
	 (error  (SDL_GetSurfaceBlendMode surface blend))
	 (return (if (= 0 error)
		     (ftype-ref int () blend)
		     error)))
    (foreign-free (ftype-pointer-address blend))
    return))

(define (sdl-get-surface-color-mod surface)
  (let* ((r      (make-ftype-pointer unsigned-8 (foreign-alloc (ftype-sizeof unsigned-8))))
	 (g      (make-ftype-pointer unsigned-8 (foreign-alloc (ftype-sizeof unsigned-8))))
	 (b      (make-ftype-pointer unsigned-8 (foreign-alloc (ftype-sizeof unsigned-8))))
	 (return (if (= 0 (SDL_GetSurfaceColorMod surface r g b))
		     (list (ftype-ref unsigned-8 () r)
			   (ftype-ref unsigned-8 () g)
			   (ftype-ref unsigned-8 () b))
		     '())))
    (foreign-free (ftype-pointer-address r))
    (foreign-free (ftype-pointer-address g))
    (foreign-free (ftype-pointer-address b))
    return))
;;; 下面两个定义参考了thunder,原chez-sdl也是手写在ftype.sls文件中  2023年2月28日23:25:59
(define (sdl-load-bmp filename) 
  (let ([rw (SDL_RWFromFile filename "rb")])
    (assert (not (ftype-pointer-null? rw)))
    (SDL_LoadBMP_RW rw 0)))

(define (sdl-save-bmp surface filename) 
  (let ([rw (SDL_RWFromFile filename  "wb")])
    (assert (not (ftype-pointer-null? rw)))
    (SDL_SaveBMP_RW surface rw 0)))

(define sdl-lock-surface   SDL_LockSurface)
(define sdl-unlock-surface SDL_UnlockSurface)

(define (sdl-lower-blit src src-rect dst dst-rect)
  (let ((fsrc-rect (sdl-rect->ftype src-rect))
	(fdst-rect (sdl-rect->ftype dst-rect)))
    (SDL_LowerBlit src fsrc-rect dst fdst-rect)
    (foreign-free (ftype-pointer-address fsrc-rect))
    (foreign-free (ftype-pointer-address fdst-rect))))

(define (sdl-lower-blit-scaled src src-rect dst dst-rect)
  (let ((fsrc-rect (sdl-rect->ftype src-rect))
	(fdst-rect (sdl-rect->ftype dst-rect)))
    (SDL_LowerBlitScaled src fsrc-rect dst fdst-rect)
    (foreign-free (ftype-pointer-address fsrc-rect))
    (foreign-free (ftype-pointer-address fdst-rect))))

(define SDL_MUSTLOCK                       (lambda (surface) (not (= (bitwise-and (ftype-ref SDL_Surface (flags) surface) #x00000002) 0)))) ;从chez-sdl ftype.sls抄的  2023年3月1日19:25:52
(define sdl-must-lock? SDL_MUSTLOCK)

(define (sdl-set-clip! surface rect)
  (let* ((clip   (if (sdl-rect? rect)
		     (sdl-rect->ftype rect)
		     (make-ftype-pointer SDL_Rect 0)))
	 (return (SDL_SetClipRect surface clip)))
    (if (sdl-rect? rect) (foreign-free (ftype-pointer-address clip)))
    return))

(define sdl-set-color-key!  SDL_SetColorKey) ;这个封装等于没有封装,在一般情况下的使用,会需要调用 ftype-ref ,打开surfac的黑盒 --220730
(define sdl-set-alpha-mod!  SDL_SetSurfaceAlphaMod)
(define sdl-set-blend-mode! SDL_SetSurfaceBlendMode)
(define sdl-set-color-mod!  SDL_SetSurfaceColorMod)
(define sdl-set-palette!    SDL_SetSurfacePalette)
(define sdl-set-rle!        SDL_SetSurfaceRLE)


#| Clipboard Handling
   ------------------
   https://wiki.libsdl.org/CategoryClipboard
|#

(define sdl-get-clipboard-text         SDL_GetClipboardText)
(define (sdl-has-clipboard-text?)      (= 1 (SDL_HasClipboardText)))
(define (sdl-set-clipboard-text! text) (= 1 (SDL_SetClipboardText text)))


;;; extend for daily use
(define (sdl-get-rect-from-surface surface x y)
  (make-sdl-rect x y
		 (ftype-ref SDL_Surface (w) surface)
		 (ftype-ref SDL_Surface (h) surface)))

(define 提取图层规格矩形 sdl-get-rect-from-surface)
