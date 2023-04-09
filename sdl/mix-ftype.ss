
(define-ftype Mix_Chunk
  (struct
    (allocated int)
    (abuf void*)
    (alen unsigned-32)
    (volume unsigned-8)
    ))

(define-ftype Mix_Music
  (struct
    (interface void*)
    (context void*)
    
    (playing int)
    (fading void*)
    (fade_step int)
    (fade_steps int)
    
    (filename (array 1024 char))
    ))

(define-ftype Mix_MusicType Uint8)		;参考了thunder  2023年3月24日20:39:53
(define-ftype Mix_Fading Uint8)
;;;Fixme enum ^

(define-ftype Mix_EffectFunc_t (function (int void* int void*) void))
(define-ftype Mix_EffectDone_t (function (int void*) void))

;;;注意参考thunder  2023年3月23日22:27:05
(define MIX_INIT_FLAC #x00000001)
(define MIX_INIT_MOD  #x00000002)
(define MIX_INIT_MP3  #x00000008)
(define MIX_INIT_OGG  #x00000010)
(define MIX_INIT_MID  #x00000020)
(define MIX_INIT_OPUS #x00000040)

;;; AUDIO FORMAT FLAG
(define AUDIO_U8        #x0008)  ;**< Unsigned 8-bit samples *;
(define AUDIO_S8        #x8008) ;**< Signed 8-bit samples *;
(define AUDIO_U16LSB    #x0010) ;**< Unsigned 16-bit samples *;
(define AUDIO_S16LSB    #x8010) ;**< Signed 16-bit samples *;
(define AUDIO_U16MSB    #x1010) ;**< As above, but big-endian byte order *;
(define AUDIO_S16MSB    #x9010) ;**< As above, but big-endian byte order *;
(define AUDIO_U16       AUDIO_U16LSB)
(define AUDIO_S16       AUDIO_S16LSB)

(define AUDIO_S32LSB    #x8020) ;**< 32-bit integer samples *;
(define AUDIO_S32MSB    #x9020)  ;**< As above, but big-endian byte order *;
(define AUDIO_S32       AUDIO_S32LSB)

(define AUDIO_F32LSB    #x8120)  ;**< 32-bit floating point samples *;
(define AUDIO_F32MSB    #x9120)  ;**< As above, but big-endian byte order *;
(define AUDIO_F32       AUDIO_F32LSB)
 
(define SDL_AUDIO_ALLOW_FREQUENCY_CHANGE    #x00000001)
(define SDL_AUDIO_ALLOW_FORMAT_CHANGE       #x00000002)
(define SDL_AUDIO_ALLOW_CHANNELS_CHANGE     #x00000004)
(define SDL_AUDIO_ALLOW_SAMPLES_CHANGE      #x00000008)

(define MIX_DEFAULT_FORMAT AUDIO_S16LSB) ;这里应该根据系统编码是大端派还是小端派做分辨的,为了省事,随便猜了一个,这个ok 2023年3月25日20:40:44


(define-sdl-func (* SDL_version) Mix_Linked_Version () "Mix_Linked_Version")
(define-sdl-func int Mix_Init ((flags int)) "Mix_Init")
(define-sdl-func void Mix_Quit () "Mix_Quit")
(define-sdl-func int Mix_OpenAudio ((frequency int) (format Uint16) (channels int) (chunksize int)) "Mix_OpenAudio")
(define-sdl-func int Mix_OpenAudioDevice ((frequency int) (format Uint16) (channels int) (chunksize int) (device string) (allowed_changes int)) "Mix_OpenAudioDevice")
(define-sdl-func int Mix_AllocateChannels ((numchans int)) "Mix_AllocateChannels")
(define-sdl-func int Mix_QuerySpec ((frequency (* int)) (format (* Uint16)) (channels (* int))) "Mix_QuerySpec")
(define-sdl-func (* Mix_Chunk) Mix_LoadWAV_RW ((src (* SDL_RWops)) (freesrc int)) "Mix_LoadWAV_RW")
(define-sdl-func (* Mix_Music) Mix_LoadMUS ((file string)) "Mix_LoadMUS")
(define-sdl-func (* Mix_Music) Mix_LoadMUS_RW ((src (* SDL_RWops)) (freesrc int)) "Mix_LoadMUS_RW")
(define-sdl-func (* Mix_Music) Mix_LoadMUSType_RW ((src (* SDL_RWops)) (type Mix_MusicType) (freesrc int)) "Mix_LoadMUSType_RW")
(define-sdl-func (* Mix_Chunk) Mix_QuickLoad_WAV ((mem (* Uint8))) "Mix_QuickLoad_WAV")
(define-sdl-func (* Mix_Chunk) Mix_QuickLoad_RAW ((mem (* Uint8)) (len Uint32)) "Mix_QuickLoad_RAW")
(define-sdl-func void Mix_FreeChunk ((chunk (* Mix_Chunk))) "Mix_FreeChunk")
(define-sdl-func void Mix_FreeMusic ((music (* Mix_Music))) "Mix_FreeMusic")
(define-sdl-func int Mix_GetNumChunkDecoders () "Mix_GetNumChunkDecoders")
(define-sdl-func string Mix_GetChunkDecoder ((index int)) "Mix_GetChunkDecoder")
(define-sdl-func SDL_bool Mix_HasChunkDecoder ((name string)) "Mix_HasChunkDecoder")
(define-sdl-func int Mix_GetNumMusicDecoders () "Mix_GetNumMusicDecoders")
(define-sdl-func string Mix_GetMusicDecoder ((index int)) "Mix_GetMusicDecoder")
(define-sdl-func SDL_bool Mix_HasMusicDecoder ((name string)) "Mix_HasMusicDecoder")
(define-sdl-func Mix_MusicType Mix_GetMusicType ((music (* Mix_Music))) "Mix_GetMusicType")
(define-sdl-func void Mix_SetPostMix ((mix_func void*) (arg void*)) "Mix_SetPostMix")
(define-sdl-func void Mix_HookMusic ((mix_func void*) (arg void*)) "Mix_HookMusic")
(define-sdl-func void Mix_HookMusicFinished ((music_finished void*)) "Mix_HookMusicFinished")
(define-sdl-func void* Mix_GetMusicHookData () "Mix_GetMusicHookData")
(define-sdl-func void Mix_ChannelFinished ((channel_finished void*)) "Mix_ChannelFinished")
(define-sdl-func int Mix_RegisterEffect ((chan int) (f (* Mix_EffectFunc_t)) (d (* Mix_EffectDone_t)) (arg void*)) "Mix_RegisterEffect")
(define-sdl-func int Mix_UnregisterEffect ((channel int) (f (* Mix_EffectFunc_t))) "Mix_UnregisterEffect")
(define-sdl-func int Mix_UnregisterAllEffects ((channel int)) "Mix_UnregisterAllEffects")
(define-sdl-func int Mix_SetPanning ((channel int) (left Uint8) (right Uint8)) "Mix_SetPanning")
(define-sdl-func int Mix_SetPosition ((channel int) (angle Sint16) (distance Uint8)) "Mix_SetPosition")
(define-sdl-func int Mix_SetDistance ((channel int) (distance Uint8)) "Mix_SetDistance")
(define-sdl-func int Mix_SetReverseStereo ((channel int) (flip int)) "Mix_SetReverseStereo")
(define-sdl-func int Mix_ReserveChannels ((num int)) "Mix_ReserveChannels")
(define-sdl-func int Mix_GroupChannel ((which int) (tag int)) "Mix_GroupChannel")
(define-sdl-func int Mix_GroupChannels ((from int) (to int) (tag int)) "Mix_GroupChannels")
(define-sdl-func int Mix_GroupAvailable ((tag int)) "Mix_GroupAvailable")
(define-sdl-func int Mix_GroupCount ((tag int)) "Mix_GroupCount")
(define-sdl-func int Mix_GroupOldest ((tag int)) "Mix_GroupOldest")
(define-sdl-func int Mix_GroupNewer ((tag int)) "Mix_GroupNewer")
(define-sdl-func int Mix_PlayChannelTimed ((channel int) (chunk (* Mix_Chunk)) (loops int) (ticks int)) "Mix_PlayChannelTimed")
(define-sdl-func int Mix_PlayMusic ((music (* Mix_Music)) (loops int)) "Mix_PlayMusic")
(define-sdl-func int Mix_FadeInMusic ((music (* Mix_Music)) (loops int) (ms int)) "Mix_FadeInMusic")
(define-sdl-func int Mix_FadeInMusicPos ((music (* Mix_Music)) (loops int) (ms int) (position double)) "Mix_FadeInMusicPos")
(define-sdl-func int Mix_FadeInChannelTimed ((channel int) (chunk (* Mix_Chunk)) (loops int) (ms int) (ticks int)) "Mix_FadeInChannelTimed")
(define-sdl-func int Mix_Volume ((channel int) (volume int)) "Mix_Volume")
(define-sdl-func int Mix_VolumeChunk ((chunk (* Mix_Chunk)) (volume int)) "Mix_VolumeChunk")
(define-sdl-func int Mix_VolumeMusic ((volume int)) "Mix_VolumeMusic")
(define-sdl-func int Mix_HaltChannel ((channel int)) "Mix_HaltChannel")
(define-sdl-func int Mix_HaltGroup ((tag int)) "Mix_HaltGroup")
(define-sdl-func int Mix_HaltMusic () "Mix_HaltMusic")
(define-sdl-func int Mix_PlayChannel ((channel int) (chunk (* Mix_Chunk)) (loops int)) "Mix_PlayChannel") ;chez-sdl和thunder都没有这个 2023年4月9日12:01:35
(define-sdl-func int Mix_ExpireChannel ((channel int) (ticks int)) "Mix_ExpireChannel")
(define-sdl-func int Mix_FadeOutChannel ((which int) (ms int)) "Mix_FadeOutChannel")
(define-sdl-func int Mix_FadeOutGroup ((tag int) (ms int)) "Mix_FadeOutGroup")
(define-sdl-func int Mix_FadeOutMusic ((ms int)) "Mix_FadeOutMusic")
(define-sdl-func Mix_Fading Mix_FadingMusic () "Mix_FadingMusic")
(define-sdl-func Mix_Fading Mix_FadingChannel ((which int)) "Mix_FadingChannel")
(define-sdl-func void Mix_Pause ((channel int)) "Mix_Pause")
(define-sdl-func void Mix_Resume ((channel int)) "Mix_Resume")
(define-sdl-func int Mix_Paused ((channel int)) "Mix_Paused")
(define-sdl-func void Mix_PauseMusic () "Mix_PauseMusic")
(define-sdl-func void Mix_ResumeMusic () "Mix_ResumeMusic")
(define-sdl-func void Mix_RewindMusic () "Mix_RewindMusic")
(define-sdl-func int Mix_PausedMusic () "Mix_PausedMusic")
(define-sdl-func int Mix_SetMusicPosition ((position double)) "Mix_SetMusicPosition")
(define-sdl-func int Mix_Playing ((channel int)) "Mix_Playing")
(define-sdl-func int Mix_PlayingMusic () "Mix_PlayingMusic")
(define-sdl-func int Mix_SetMusicCMD ((command string)) "Mix_SetMusicCMD")
(define-sdl-func int Mix_SetSynchroValue ((value int)) "Mix_SetSynchroValue")
(define-sdl-func int Mix_GetSynchroValue () "Mix_GetSynchroValue")
(define-sdl-func int Mix_SetSoundFonts ((paths string)) "Mix_SetSoundFonts")
(define-sdl-func string Mix_GetSoundFonts () "Mix_GetSoundFonts")
(define-sdl-func int Mix_EachSoundFont ((function void*) (data void*)) "Mix_EachSoundFont")
(define-sdl-func (* Mix_Chunk) Mix_GetChunk ((channel int)) "Mix_GetChunk")
(define-sdl-func void Mix_CloseAudio () "Mix_CloseAudio")
