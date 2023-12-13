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
    const ubyte STATE_SIZEOF         = $02;   
    const ubyte STATE_COUNTER        = $02;

    sub counter_get(ubyte[3] ptr, uword result) {        
        fstruct.get_w(ptr, STATE_COUNTER, result);
    }

    sub counter_set(ubyte[3] ptr, uword value) {
        fstruct.set_w(ptr, STATE_COUNTER, value);
    }

    sub counter_set_wi(ubyte[3] ptr, uword value) {
        fstruct.set_wi(ptr, STATE_COUNTER, value);
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
        state.counter_set_wi(pState, 1000);

        ; Attach it to the task
        task.state_set(pTaskData, &pState)        
        
    }

    sub run(ubyte[fptr.SIZEOF_FPTR] pTask, uword param1, uword param2) {
        ubyte[fptr.SIZEOF_FPTR] pTaskData;
        ubyte[fptr.SIZEOF_FPTR] pState;
        uword counter;

        ;dump_fptr("ptask: ", pTask)

        ; Get the task data
        ;%asm{{.byte $DB }}
        linkedlist_item.data_get(pTask, &pTaskData)         
        ;dump_fptr("ptaskdata: ", pTaskData)    

        ; Get the state 
        task.state_get(pTaskData, &pState)
        ;dump_fptr("pstate: ", pState)

        ; Increment Counter
        state.counter_get(pState, &counter)
        counter = counter - 1
        state.counter_set(pState, &counter)        

        txt.print_uw(counter)
        txt.print("\n  ")        

    }

    sub done(ubyte[fptr.SIZEOF_FPTR] pTask, uword param1, uword param2) {
        ubyte @shared temp;
        temp = 2
    }

    sub dump_ptr(str prompt, uword ptr)
    {        
        txt.print(prompt);
        txt.print_uwhex(ptr, false)                       
        txt.print("  \n");       
    }

    sub dump_fptr(str prompt, ubyte[fptr.SIZEOF_FPTR] fptr)
    {        
        txt.print(prompt);
        txt.print_ubhex(fptr[0], false)        
        txt.print(" : ");        
        txt.print_ubhex(fptr[2], false)        
        txt.print_ubhex(fptr[1], false)        
        txt.print("  \n")        
    }
}
