task {
    const ubyte TASK_SIZEOF         = $18;    
    const ubyte TASK_TASKIMAGE      = $00; 3 - fptr
    const ubyte TASK_TITLE          = $03; 3 - fptr
    const ubyte TASK_STATE          = $06; 3 - fptr
    const ubyte TASK_X              = $09; 2 - uword
    const ubyte TASK_Y              = $0b; 2 - uword
    const ubyte TASK_H              = $0d; 2 - uword
    const ubyte TASK_W              = $0f; 2 - uword
    const ubyte TASK_FILENAME       = $11; 3 - fptr
    const ubyte TASK_DONE           = $14; 2 - uword
    const ubyte TASK_CANVAS         = $16; 3 - fptr
    
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

    sub done_get(ubyte[3] ptr, uword result) {        
        fstruct.get_w(ptr, TASK_DONE, result);
    }

    sub done_set(ubyte[3] ptr, uword value) {
        fstruct.set_w(ptr, TASK_DONE, value);
    }
    
    sub done_set_wi(ubyte[3] ptr, uword value) {
        fstruct.set_wi(ptr, TASK_DONE, value);
    }      

    sub canvas_get(ubyte[3] ptr, uword result) {        
        fstruct.get(ptr, TASK_CANVAS, fptr.SIZEOF_FPTR, result);
    }

    sub canvas_set(ubyte[3] ptr, uword value) {
        fstruct.set(ptr, TASK_CANVAS, fptr.SIZEOF_FPTR, value);
    } 
}

