%import textio_h
%import fstruct_h
%import fmalloc_h
%import task_h
%import linkedlist_item_h

%launcher none
%option no_sysinit
%zeropage dontuse
%address $A008

; TODO:
; Headers for imported functions
; Jump table for imported functions
; Launcher

state {
    const ubyte STATE_SIZEOF         = $08;   
    const ubyte STATE_COUNTER        = $00;
    const ubyte STATE_X              = $02;
    const ubyte STATE_Y              = $04;

    sub counter_get(ubyte[3] ptr, uword result) {        
        fstruct.get_w(ptr, STATE_COUNTER, result);
    }

    sub counter_set(ubyte[3] ptr, uword value) {
        fstruct.set_w(ptr, STATE_COUNTER, value);
    }

    sub counter_set_wi(ubyte[3] ptr, uword value) {
        fstruct.set_wi(ptr, STATE_COUNTER, value);
    }

    sub x_get(ubyte[3] ptr, uword result) {        
        fstruct.get_w(ptr, STATE_X, result);
    }

    sub x_set(ubyte[3] ptr, uword value) {
        fstruct.set_w(ptr, STATE_X, value);
    }

    sub x_set_wi(ubyte[3] ptr, uword value) {
        fstruct.set_wi(ptr, STATE_X, value);
    }

    sub y_get(ubyte[3] ptr, uword result) {        
        fstruct.get_w(ptr, STATE_Y, result);
    }

    sub y_set(ubyte[3] ptr, uword value) {
        fstruct.set_w(ptr, STATE_Y, value);
    }

    sub y_set_wi(ubyte[3] ptr, uword value) {
        fstruct.set_wi(ptr, STATE_Y, value);
    }        
}

main $A008 {
        
    sub start() {
        when cx16.r0L {
            1 -> init(cx16.r3, cx16.r1, cx16.r2);
            2 -> run(cx16.r3, cx16.r1, cx16.r2);
            3 -> done(cx16.r3, cx16.r1, cx16.r2);
        }
    }    

    sub init(ubyte[fptr.SIZEOF_FPTR] pTask, uword param1, uword param2) {

        ubyte[fptr.SIZEOF_FPTR] pTaskData;
        ubyte[fptr.SIZEOF_FPTR] pState;

        ; Get the task data
        linkedlist_item.data_get(pTask, &pTaskData)        

        ; Create state
        fmalloc.malloc(state.STATE_SIZEOF, &pState);
        state.counter_set_wi(pState, 0);
        state.x_set(pState, &param1)    
        state.y_set(pState, &param2)    

        ; Attach it to the task
        task.state_set(pTaskData, &pState)        
        
    }

    sub run(ubyte[fptr.SIZEOF_FPTR] pTask, uword param1, uword param2) {
        ubyte[fptr.SIZEOF_FPTR] pTaskData;
        ubyte[fptr.SIZEOF_FPTR] pState;
        uword counter;
        uword x;
        uword y;         

        ; Get the task data        
        linkedlist_item.data_get(pTask, &pTaskData)                 

        ; Get the state 
        task.state_get(pTaskData, &pState)        

        ; Increment Counter
        state.counter_get(pState, &counter)
        counter = counter + 1
        state.counter_set(pState, &counter)        
        
        ; Display the data
        state.x_get(pState, &x)    
        state.y_get(pState, &y)  
        txt.column(lsb(x))          
        txt.row(lsb(y))
        txt.print_uw(counter)              
    }

    sub done(ubyte[fptr.SIZEOF_FPTR] pTask, uword param1, uword param2) {
        ubyte @shared temp;
        temp = 2
    }

    sub dump_ptr(str prompt, uword ptr)
    {        
        txt.print(prompt);
        txt.print_uwhex(ptr, false)                                   
    }

    sub dump_fptr(str prompt, ubyte[fptr.SIZEOF_FPTR] fptr)
    {        
        txt.print(prompt);
        txt.print_ubhex(fptr[0], false)                
        txt.print_ubhex(fptr[2], false)        
        txt.print_ubhex(fptr[1], false)                   
    }
}
