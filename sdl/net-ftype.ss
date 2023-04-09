(define-ftype IPaddress
  (struct 
   (host Uint32)
   (port Uint16)))

(define-ftype UDPpacket
  (struct 
   (channel int)
   (data Uint8)
   (len int)
   (maxlen int)
   (status int)
   (address IPaddress)))

(define-ftype UDPsocket void*)
(define-ftype TCPsocket void*)

(define-syntax INADDR_ANY (identifier-syntax 0))
(define-syntax INADDR_NONE (identifier-syntax #xffffffff))
(define-syntax INADDR_BROADCAST (identifier-syntax #xffffffff))
(define-syntax INADDR_LOOPBACK (identifier-syntax #x7f000001))

(define-ftype SDLNet_version
  (struct 
   (major Uint8)
   (minor Uint8)
   (patch Uint8)))

(define-ftype SDLNet_SocketSet void*)

;; (define-ftype SDLNet_SocketSet
;;; thunder这里是个不带t的 sdl-net-generic-socket
;;   (struct
;;    (ready int)))

(define-ftype SDLNet_GenericSocket void*)

(define-sdl-func (* SDLNet_version) SDLNet_Linked_Version () "SDLNet_Linked_Version")
(define-sdl-func int SDLNet_Init () "SDLNet_Init")
(define-sdl-func void SDLNet_Quit () "SDLNet_Quit")
(define-sdl-func int SDLNet_ResolveHost ((address (* IPaddress)) (host string) (port Uint16)) "SDLNet_ResolveHost")
(define-sdl-func string SDLNet_ResolveIP ((ip (* IPaddress))) "SDLNet_ResolveIP")
(define-sdl-func int SDLNet_GetLocalAddresses ((addresses (* IPaddress)) (maxcount int)) "SDLNet_GetLocalAddresses")
(define-sdl-func TCPsocket SDLNet_TCP_Open ((ip (* IPaddress))) "SDLNet_TCP_Open")
(define-sdl-func TCPsocket SDLNet_TCP_Accept ((server TCPsocket)) "SDLNet_TCP_Accept")
(define-sdl-func (* IPaddress) SDLNet_TCP_GetPeerAddress ((sock TCPsocket)) "SDLNet_TCP_GetPeerAddress")
(define-sdl-func int SDLNet_TCP_Send ((sock TCPsocket) (data void*) (len int)) "SDLNet_TCP_Send")
(define-sdl-func int SDLNet_TCP_Recv ((sock TCPsocket) (data void*) (maxlen int)) "SDLNet_TCP_Recv")
(define-sdl-func void SDLNet_TCP_Close ((sock TCPsocket)) "SDLNet_TCP_Close")
(define-sdl-func (* UDPpacket) SDLNet_AllocPacket ((size int)) "SDLNet_AllocPacket")
(define-sdl-func int SDLNet_ResizePacket ((packet (* UDPpacket)) (newsize int)) "SDLNet_ResizePacket")
(define-sdl-func void SDLNet_FreePacket ((packet (* UDPpacket))) "SDLNet_FreePacket")
(define-sdl-func (* UDPpacket) SDLNet_AllocPacketV ((howmany int) (size int)) "SDLNet_AllocPacketV")
(define-sdl-func void SDLNet_FreePacketV ((packetV (* UDPpacket))) "SDLNet_FreePacketV")
(define-sdl-func UDPsocket SDLNet_UDP_Open ((port Uint16)) "SDLNet_UDP_Open")
(define-sdl-func void SDLNet_UDP_SetPacketLoss ((sock UDPsocket) (percent int)) "SDLNet_UDP_SetPacketLoss")
(define-sdl-func int SDLNet_UDP_Bind ((sock UDPsocket) (channel int) (address (* IPaddress))) "SDLNet_UDP_Bind")
(define-sdl-func void SDLNet_UDP_Unbind ((sock UDPsocket) (channel int)) "SDLNet_UDP_Unbind")
(define-sdl-func (* IPaddress) SDLNet_UDP_GetPeerAddress ((sock UDPsocket) (channel int)) "SDLNet_UDP_GetPeerAddress")
(define-sdl-func int SDLNet_UDP_SendV ((sock UDPsocket) (packets (* UDPpacket)) (npackets int)) "SDLNet_UDP_SendV")
(define-sdl-func int SDLNet_UDP_Send ((sock UDPsocket) (channel int) (packet (* UDPpacket))) "SDLNet_UDP_Send")
(define-sdl-func int SDLNet_UDP_RecvV ((sock UDPsocket) (packets (* UDPpacket))) "SDLNet_UDP_RecvV")
(define-sdl-func int SDLNet_UDP_Recv ((sock UDPsocket) (packet (* UDPpacket))) "SDLNet_UDP_Recv")
(define-sdl-func void SDLNet_UDP_Close ((sock UDPsocket)) "SDLNet_UDP_Close")
(define-sdl-func SDLNet_SocketSet SDLNet_AllocSocketSet ((maxsockets int)) "SDLNet_AllocSocketSet")
(define-sdl-func int SDLNet_AddSocket ((set SDLNet_SocketSet) (sock SDLNet_GenericSocket)) "SDLNet_AddSocket")
(define-sdl-func int SDLNet_TCP_AddSocket ((set SDLNet_SocketSet) (sock TCPsocket)) "SDLNet_TCP_AddSocket")
(define-sdl-func int SDLNet_UDP_AddSocket ((set SDLNet_SocketSet) (sock UDPsocket)) "SDLNet_UDP_AddSocket")
(define-sdl-func int SDLNet_DelSocket ((set SDLNet_SocketSet) (sock SDLNet_GenericSocket)) "SDLNet_DelSocket")
(define-sdl-func int SDLNet_TCP_DelSocket ((set SDLNet_SocketSet) (sock TCPsocket)) "SDLNet_TCP_DelSocket")
(define-sdl-func int SDLNet_UDP_DelSocket ((set SDLNet_SocketSet) (sock UDPsocket)) "SDLNet_UDP_DelSocket")
(define-sdl-func int SDLNet_CheckSockets ((set SDLNet_SocketSet) (timeout Uint32)) "SDLNet_CheckSockets")
(define-sdl-func void SDLNet_FreeSocketSet ((set SDLNet_SocketSet)) "SDLNet_FreeSocketSet")
(define-sdl-func void SDLNet_SetError ((fmt string)) "SDLNet_SetError")
(define-sdl-func string SDLNet_GetError () "SDLNet_GetError")
