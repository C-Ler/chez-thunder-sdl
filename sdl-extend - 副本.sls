;;;; -*- mode: Scheme; -*-


;;; 由于需要调用 类型的值,所以这部分直接写成库文件的一部分  -- 230117
;;; set! 不能放在 lib 的开头,不然会报错 -- 230125
(define evnht (make-eqv-hashtable))

(define (事件-mk 每帧时长 默认事件过程)
  ;; 这是一个试图更加灵活的版本,然而没有成功 -- 221212
  ;; 读取事件类型,计算时间间隔,进行组合键判定得到最终事件类型->根据最终事件类型取得过程,传入运行部分->显示部分进行显示->回到读取的部分 -- 221212
  (lambda (msg)
    (case msg
      [(事件->过程)
       (sdl-poll-event)		;用于实时性高的情景,空队列会阻塞CPU,可以用sdl-wait-event替代
       (let [(evt-type (ftype-ref SDL_Event (type) *event-obj*))
	     ;; chez-sdl将每种type都封装成了无参数谓词,做基于类型的分派时,反而不容易了
	     ]
	 (hashtable-ref evnht evt-type 默认事件过程) ;按事件类型从hash返回一个过程
	 )]
      [else
       (assertion-violation '事件-foo "事件不支持的过程!~s" msg)]
      ))
  )

(define (事件过程-get 事件) (事件 '事件->过程))

(define (事件循环1 事件)
  ;; 事件对应过程,不同的过程需要调用不同的参数....目前只能将所有事件的过程全部封装进trunk中,不过这样做遇到的问题是,初始化窗口这些的引用,只能通过返回过程的过程打包进去 -- 221213
  (let loop ()
    (and ((事件过程-get 事件))	;这里其实把R E P 合并在一个过程了 -- 221213
	 (loop))))

(define (事件循环2 每帧时长)
  ;; 为了避免出现1的那个版本,每套局部都要对各个事件对应的hash-table进行赋值的情况;
  ;; 同时为了避免closure中每增添一个事件就要修改源代码的情况
  ;; 意识到了事件和状态的本质都是谓词之后,通过给事件循环的构造器返回一个传入函数,将传入的函数应用到事件类型上得到了现在的版本 -- 2023年2月15日21:03:31
  (lambda (foo)
    (let loop ((e-t (ftype-ref SDL_Event (type) *event-obj*)))
      ;; (assert (not (= e-t SDL-QUIT-E)))
      ;; 不要使用case,case的条件部分不求值
      (cond 
       [(= e-t SDL-QUIT-E) '退出]
       [else (foo e-t)
	     (loop (begin
		     (sdl-poll-event)
		     (ftype-ref SDL_Event (type) *event-obj*)))]
       ))))



(hashtable-set! evnht SDL-QUIT-E (lambda () #f))

