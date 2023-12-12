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

main $A008 {
    
    sub start() {
        when cx16.r0L {
            1 -> init();
            2 -> run();
            3 -> done();
        }
    }    

    sub init() {
        uword ptr1;
        ubyte[fptr.SIZEOF_FPTR] fptr1;

        txt.print("hello world\n");                

        fmalloc.malloc(32, &fptr1);
        dump_fptr("fptr1:", fptr1);

        fmalloc.free(&fptr1)

        fmalloc.malloc(32, &fptr1);
        dump_fptr("fptr1:", fptr1);

        fmalloc.malloc(32, &fptr1);
        dump_fptr("fptr1:", fptr1);
        
    }

    sub run() {
        ubyte @shared temp;
        temp = 1
    }

    sub done() {
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
