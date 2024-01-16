component {    
    const uword CM_LABEL                = $0001

    const ubyte COMPONENT_SIZEOF        = $10;    
    const ubyte COMPONENT_ID            = $00; 2 - uword    
    const ubyte COMPONENT_X             = $02; 2 - uword
    const ubyte COMPONENT_Y             = $04; 2 - uword
    const ubyte COMPONENT_H             = $06; 2 - uword
    const ubyte COMPONENT_W             = $08; 2 - uword    
    const ubyte COMPONENT_FLAGS         = $0a; 2 - uword        
    const ubyte COMPONENT_TEXT          = $0c; 3 - fptr

    sub componentId_get(ubyte[3] ptr, uword result) {        
        fstruct.get_w(ptr, COMPONENT_ID, result);
    }

    sub componentId_set(ubyte[3] ptr, uword value) {
        fstruct.set_w(ptr, COMPONENT_ID, value);
    }
    
    sub componentId_set_wi(ubyte[3] ptr, uword value) {
        fstruct.set_wi(ptr, COMPONENT_ID, value);
    }    

    sub x_get(ubyte[3] ptr, uword result) {        
        fstruct.get_w(ptr, COMPONENT_X, result);
    }

    sub x_set(ubyte[3] ptr, uword value) {
        fstruct.set_w(ptr, COMPONENT_X, value);
    }
    
    sub x_set_wi(ubyte[3] ptr, uword value) {
        fstruct.set_wi(ptr, COMPONENT_X, value);
    }    

    sub y_get(ubyte[3] ptr, uword result) {        
        fstruct.get_w(ptr, COMPONENT_Y, result);
    }

    sub y_set(ubyte[3] ptr, uword value) {
        fstruct.set_w(ptr, COMPONENT_Y, value);
    }
    
    sub y_set_wi(ubyte[3] ptr, uword value) {
        fstruct.set_wi(ptr, COMPONENT_Y, value);
    }    

    sub h_get(ubyte[3] ptr, uword result) {        
        fstruct.get_w(ptr, COMPONENT_H, result);
    }

    sub h_set(ubyte[3] ptr, uword value) {
        fstruct.set_w(ptr, COMPONENT_H, value);
    }
    
    sub h_set_wi(ubyte[3] ptr, uword value) {
        fstruct.set_wi(ptr, COMPONENT_H, value);
    }    

    sub w_get(ubyte[3] ptr, uword result) {        
        fstruct.get_w(ptr, COMPONENT_W, result);
    }

    sub w_set(ubyte[3] ptr, uword value) {
        fstruct.set_w(ptr, COMPONENT_W, value);
    }
    
    sub w_set_wi(ubyte[3] ptr, uword value) {
        fstruct.set_wi(ptr, COMPONENT_W, value);
    }        

    sub text_get(ubyte[3] ptr, uword result) {        
        fstruct.get(ptr, COMPONENT_TEXT, fptr.SIZEOF_FPTR, result);
    }

    sub text_set(ubyte[3] ptr, uword value) {
        fstruct.set(ptr, COMPONENT_TEXT, fptr.SIZEOF_FPTR, value);
    }
}