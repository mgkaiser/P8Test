%import textio_h
%import struct_h
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
        txt.print("hello world");
    }

    sub run() {
        ubyte @shared temp;
        temp = 1
    }

    sub done() {
        ubyte @shared temp;
        temp = 2
    }
}
