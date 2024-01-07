message {
    const ubyte MESSAGE_SIZEOF      = $0f
    const ubyte MESSAGE_TASK        = $00; ubyte[fptr.SIZEOF_FPTR]    
    const ubyte MESSAGE_COMPONENT   = $03; ubyte[fptr.SIZEOF_FPTR]    
    const ubyte MESSAGE_MESSAGEID   = $06; uword
    const ubyte MESSAGE_PARAM1      = $08; uword
    const ubyte MESSAGE_PARAM2      = $0a; uword
    const ubyte MESSAGE_PARAM3      = $0c; ubyte[fptr.SIZEOF_FPTR]    

    const uword WM_NULL         = $0000

    const uword WM_MOUSE_MOVE       = $0100
    const uword WM_MOUSE_LEFT_UP    = $0101
    const uword WM_MOUSE_LEFT_DOWN  = $0102
    const uword WM_MOUSE_RIGHT_UP   = $0103
    const uword WM_MOUSE_RIGHT_DOWN = $0104
    
    const uword WM_ENTER            = $0200
    const uword WM_LEAVE            = $0201

    const uword WM_TOP              = $0300

    const uword WM_PAINT            = $8000 
    const uword WM_TEXT             = $8001 

    const uword WM_CONSUMED     = $ffff

    romsub $0450 = post_message(uword pTask @R0, uword pComponent @R1, uword messageId @R2, uword param1 @R3, uword param2 @R4, uword param3 @R5)     

    sub task_get(ubyte[3] ptr, uword result) {        
        fstruct.get(ptr, MESSAGE_TASK, fptr.SIZEOF_FPTR, result);
    }

    sub task_set(ubyte[3] ptr, uword value) {
        fstruct.set(ptr, MESSAGE_TASK, fptr.SIZEOF_FPTR, value);
    }

    sub component_get(ubyte[3] ptr, uword result) {        
        fstruct.get(ptr, MESSAGE_COMPONENT, fptr.SIZEOF_FPTR, result);
    }

    sub component_set(ubyte[3] ptr, uword value) {
        fstruct.set(ptr, MESSAGE_COMPONENT, fptr.SIZEOF_FPTR, value);
    }

    sub messageid_get(ubyte[3] ptr, uword result) {        
        fstruct.get_w(ptr, MESSAGE_MESSAGEID, result);
    }

    sub messageid_set(ubyte[3] ptr, uword value) {
        fstruct.set_w(ptr, MESSAGE_MESSAGEID, value);
    }
    
    sub messageid_set_wi(ubyte[3] ptr, uword value) {
        fstruct.set_wi(ptr, MESSAGE_MESSAGEID, value);
    }     

    sub param1_get(ubyte[3] ptr, uword result) {        
        fstruct.get_w(ptr, MESSAGE_PARAM1, result);
    }

    sub param1_set(ubyte[3] ptr, uword value) {
        fstruct.set_w(ptr, MESSAGE_PARAM1, value);
    }
    
    sub param1_set_wi(ubyte[3] ptr, uword value) {
        fstruct.set_wi(ptr, MESSAGE_PARAM1, value);
    }     

    sub param2_get(ubyte[3] ptr, uword result) {        
        fstruct.get_w(ptr, MESSAGE_PARAM2, result);
    }

    sub param2_set(ubyte[3] ptr, uword value) {
        fstruct.set_w(ptr, MESSAGE_PARAM2, value);
    }
    
    sub param2_set_wi(ubyte[3] ptr, uword value) {
        fstruct.set_wi(ptr, MESSAGE_PARAM2, value);
    }     

    sub param3_get(ubyte[3] ptr, uword result) {        
        fstruct.get(ptr, MESSAGE_PARAM3, fptr.SIZEOF_FPTR, result);
    }

    sub param3_set(ubyte[3] ptr, uword value) {
        fstruct.set(ptr, MESSAGE_PARAM3, fptr.SIZEOF_FPTR, value);
    }
}