message {
    const ubyte MESSAGE_SIZEOF      = $0e
    const ubyte MESSAGE_TASK        = $00; ubyte[fptr.SIZEOF_FPTR]    
    const ubyte MESSAGE_COMPONENT   = $03; ubyte[fptr.SIZEOF_FPTR]    
    const ubyte MESSAGE_MESSAGEID   = $06; uword
    const ubyte MESSAGE_PARAM1      = $08; uword
    const ubyte MESSAGE_PARAM1      = $0a; uword
    const ubyte MESSAGE_PARAM1      = $0c; uword
}