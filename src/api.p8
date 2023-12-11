%import diskio

api {

    romsub $a008 = external_command(uword command @R0, uword param1 @R1, uword param2 @R2);

    const ubyte API_INIT = $01
    const ubyte API_RUN = $02
    const ubyte API_DONE = $03

    sub registerjumptable() {

        uword address

        ; Register methods from "txt"
        address = $07e0
        address = registerjumpitem(address, &txt.print)        

        ; Register methods from "struct"        
        address = $0400
        address = registerjumpitem(address, &struct.set) 
        address = registerjumpitem(address, &struct.get) 
        address = registerjumpitem(address, &struct.set_w) 
        address = registerjumpitem(address, &struct.set_wi) 
        address = registerjumpitem(address, &struct.get_w)     

        ; Register methods from "ptr"        
        address = $0410
        address = registerjumpitem(address, &ptr.set_w) 
        address = registerjumpitem(address, &ptr.get_w)   

        ; Register methods from "fstruct"              
        address = $0420

        ; Register methods from "fptr"              
        address = $0430

        ; Register methods from "pmalloc"              
        address = $0440

        ; Register methods from "fmalloc"              
        address = $0448
        
    }

    sub registerjumpitem(uword address, uword ptr) -> uword {
        poke(address, $4c)  
        pokew(address+1, ptr)
        return address + 3
    }

    ; Launcher
    sub launch(str filename, ubyte bank, uword param1, uword param2) -> bool {
        cx16.rambank(bank) ;
        uword result = diskio.load(filename, $a008)
        if result > 0 {       
            run(bank, API_INIT, param1, param2)                          
        }
        return result != 0
    }

    sub run (ubyte bank, uword command, uword param1, uword param2) {
        cx16.rambank(bank);
        external_command(command, param1, param2);
    }


    ; Stubs for routines that aren't assembly functions

}