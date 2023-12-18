message {
    const ubyte MESSAGE_SIZEOF      = $0e
    const ubyte MESSAGE_TASK        = $00; ubyte[fptr.SIZEOF_FPTR]    
    const ubyte MESSAGE_COMPONENT   = $03; ubyte[fptr.SIZEOF_FPTR]    
    const ubyte MESSAGE_MESSAGEID   = $06; uword
    const ubyte MESSAGE_PARAM1      = $08; uword
    const ubyte MESSAGE_PARAM2      = $0a; uword
    const ubyte MESSAGE_PARAM3      = $0c; uword        

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
        fstruct.get_w(ptr, MESSAGE_PARAM3, result);
    }

    sub param3_set(ubyte[3] ptr, uword value) {
        fstruct.set_w(ptr, MESSAGE_PARAM3, value);
    }
    
    sub param3_set_wi(ubyte[3] ptr, uword value) {
        fstruct.set_wi(ptr, MESSAGE_PARAM3, value);
    }     
}