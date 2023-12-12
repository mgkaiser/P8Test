task {
    const ubyte TASK_SIZEOF         = $14;    
    const ubyte TASK_TASKIMAGE      = $00;
    const ubyte TASK_TITLE          = $03;
    const ubyte TASK_STATE          = $06;
    const ubyte TASK_X              = $09;
    const ubyte TASK_Y              = $0b;
    const ubyte TASK_H              = $0d;
    const ubyte TASK_W              = $0f;
    const ubyte TASK_FILENAME       = $11;
    
    sub taskimage_get(ubyte[3] ptr, uword result) {        
        fstruct.get(ptr, TASK_TASKIMAGE, fptr.SIZEOF_FPTR, result);
    }

    sub taskimage_set(ubyte[3] ptr, uword value) {
        fstruct.set(ptr, TASK_TASKIMAGE, fptr.SIZEOF_FPTR, value);
    }

    sub title_get(ubyte[3] ptr, uword result) {        
        fstruct.get(ptr, TASK_TITLE, fptr.SIZEOF_FPTR, result);
    }

    sub title_set(ubyte[3] ptr, uword value) {
        fstruct.set(ptr, TASK_TITLE, fptr.SIZEOF_FPTR, value);
    }

    sub state_get(ubyte[3] ptr, uword result) {        
        fstruct.get(ptr, TASK_STATE, fptr.SIZEOF_FPTR, result);
    }

    sub state_set(ubyte[3] ptr, uword value) {
        fstruct.set(ptr, TASK_STATE, fptr.SIZEOF_FPTR, value);
    }

    sub x_get(ubyte[3] ptr, uword result) {        
        fstruct.get_w(ptr, TASK_X, result);
    }

    sub x_set(ubyte[3] ptr, uword value) {
        fstruct.set_w(ptr, TASK_X, value);
    }
    
    sub x_set_wi(ubyte[3] ptr, uword value) {
        fstruct.set_wi(ptr, TASK_X, value);
    }    

    sub y_get(ubyte[3] ptr, uword result) {        
        fstruct.get_w(ptr, TASK_Y, result);
    }

    sub y_set(ubyte[3] ptr, uword value) {
        fstruct.set_w(ptr, TASK_Y, value);
    }
    
    sub y_set_wi(ubyte[3] ptr, uword value) {
        fstruct.set_wi(ptr, TASK_Y, value);
    }    

    sub h_get(ubyte[3] ptr, uword result) {        
        fstruct.get_w(ptr, TASK_H, result);
    }

    sub h_set(ubyte[3] ptr, uword value) {
        fstruct.set_w(ptr, TASK_H, value);
    }
    
    sub h_set_wi(ubyte[3] ptr, uword value) {
        fstruct.set_wi(ptr, TASK_H, value);
    }    

    sub w_get(ubyte[3] ptr, uword result) {        
        fstruct.get_w(ptr, TASK_W, result);
    }

    sub w_set(ubyte[3] ptr, uword value) {
        fstruct.set_w(ptr, TASK_W, value);
    }
    
    sub w_set_wi(ubyte[3] ptr, uword value) {
        fstruct.set_wi(ptr, TASK_W, value);
    }    

    sub filename_get(ubyte[3] ptr, uword result) {        
        fstruct.get(ptr, TASK_FILENAME, fptr.SIZEOF_FPTR, result);
    }

    sub filename_set(ubyte[3] ptr, uword value) {
        fstruct.set(ptr, TASK_FILENAME, fptr.SIZEOF_FPTR, value);
    }       
}

