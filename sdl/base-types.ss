;;; tc base-types.ss ,因为 ffi 的 define-sdl-func需要
;;; 为了嫁接,干掉了驼峰标记,这类型映射也要对应修改  2023年2月21日20:46:47
;;; 即便改成了下面这样,依然在load后报错了 invalid function-ftype argument type specifier Uint8 --  2023年2月22日21:31:33
;;; 在repl对下面这些ftype定义求值之后,再运行sdl就正常了....
;;; 和include的顺序有很大关系,必要的情况下需要分拆文件,就像thunder 那样... -- 2023年2月22日22:44:42
;;; 这些类型声明 放入 fype.sls 开头后,Uint8的问题就没有了. -- 2023年2月25日20:16:36
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

(define-ftype SDL_iconv_t void*)

;;; 为了应对thunder和chez-sdl都没定义的过程被parse,而这些过程都用了没定义的类型作为参数  2023年2月26日19:16:17
;; '((long unsigned-long double SDL_AssertData SDL_mutex SDL_sem
;;   SDL_cond SDL_Thread SDL_threadID SDL_TLSID SDL_AudioStatus
;;   SDL_BlendMode float SDL_Keymod SDL_Scancode SDL_Keycode
;;   SDL_JoystickType SDL_JoystickID SDL_JoystickPowerLevel
;;   SDL_GameControllerAxis SDL_GameControllerButton SDL_TouchID
;;   unsigned-int void* SDL_LogPriority SDL_PowerState
;;   SDL_TimerID string int void)
;;   (SDL_SysWMinfo SDL_version SDL_Keysym SDL_CommonEvent
;;    SDL_WindowEvent SDL_KeyboardEvent SDL_TextEditingEvent
;;    SDL_TextInputEvent SDL_MouseMotionEvent SDL_MouseButtonEvent
;;    SDL_MouseWheelEvent SDL_JoyAxisEvent SDL_JoyBallEvent
;;    SDL_JoyHatEvent SDL_JoyButtonEvent SDL_JoyDeviceEvent
;;    SDL_ControllerAxisEvent SDL_ControllerButtonEvent
;;    SDL_ControllerDeviceEvent SDL_AudioDeviceEvent SDL_QuitEvent
;;    SDL_UserEvent SDL_SysWMEvent SDL_TouchFingerEvent
;;    SDL_MultiGestureEvent SDL_DollarGestureEvent SDL_DropEvent
;;    SDL_Event SDL_HapticDirection SDL_HapticConstant
;;    SDL_HapticPeriodic SDL_HapticCondition SDL_HapticRamp
;;    SDL_HapticLeftRight SDL_HapticCustom SDL_HapticEffect
;;    SDL_Rect SDL_FRect SDL_Point SDL_FPoint SDL_Color
;;    SDL_RendererInfo SDL_MessageBoxColor
;;    SDL_MessageBoxColorScheme SDL_MessageBoxButtonData
;;    SDL_MessageBoxData SDL_AudioCallback SDL_AudioFormat
;;    SDL_AudioCVT SDL_AudioFilter Sint32 va_list int% file
;;    SDL_realloc_func SDL_free_func SDL_malloc_func
;;    SDL_calloc_func))

(define-ftype SDL_AssertData void*)
(define-ftype SDL_mutex void*)
(define-ftype SDL_sem void*)
(define-ftype SDL_cond void*)
(define-ftype SDL_Thread void*)
(define-ftype SDL_threadID void*)
(define-ftype SDL_TLSID void*)
(define-ftype SDL_AudioStatus void*)
(define-ftype SDL_BlendMode void*)

(define-ftype SDL_Keymod void*)
(define-ftype SDL_Scancode void*)
(define-ftype SDL_Keycode void*)
(define-ftype SDL_JoystickType void*)
(define-ftype SDL_JoystickID void*)
(define-ftype SDL_JoystickPowerLevel void*)
(define-ftype SDL_GameControllerAxis void*)
(define-ftype SDL_GameControllerButton void*)
(define-ftype SDL_TouchID void*)
(define-ftype SDL_LogPriority void*)
(define-ftype SDL_PowerState void*)
(define-ftype SDL_TimerID void*)
(define-ftype SDL_SpinLock int) 	;反驼峰加-t后在thunder中找到了定义,但是chez-sdl无  2023年2月26日22:37:36


(define-ftype SDL_realloc_func void*)
(define-ftype SDL_AssertState void*)
(define-ftype SDL_AssertionHandler void*)
(define-ftype SDL_free_func void*)
(define-ftype SDL_malloc_func void*)
(define-ftype SDL_calloc_func void*)

(define-ftype wchar_t void*)
(define-ftype SDL_atomic_t void*)
(define-ftype SDL_errorcode void*)
(define-ftype SDL_ThreadFunction void*)
(define-ftype SDL_ThreadPriority void*)
(define-ftype FILE void*)
(define-ftype SDL_BlendFactor void*)
(define-ftype SDL_BlendOperation void*)
(define-ftype SDL_HitTest void*)
(define-ftype SDL_GLattr void*)
(define-ftype SDL_SystemCursor void*)
(define-ftype SDL_GestureID void*)
(define-ftype SDL_eventaction void*)
(define-ftype SDL_EventFilter void*)
(define-ftype SDL_HintPriority void*)
(define-ftype SDL_HintCallback void*)
(define-ftype SDL_LogOutputFunction void*)
(define-ftype SDL_RendererFlip void*)
(define-ftype SDL_WindowShapeMode void*)
(define-ftype SDL_TimerCallback void*)
;; (define-ftype void void*)
 ;; Conditions
(define-record-type (&sdl2 make-sdl2-condition $sdl2-condition?)
  (parent &condition)
  (fields (immutable status $sdl2-condition-status)))

(define rtd (record-type-descriptor &sdl2))
(define sdl2-condition? (condition-predicate rtd))
(define sdl2-status (condition-accessor rtd $sdl2-condition-status))

