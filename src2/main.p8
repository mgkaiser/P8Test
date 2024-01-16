%import api
%import textio
%import string
%import fmalloc
%import linkedlist
%import queue
%import monogfx2
%import emudbg

%option no_sysinit
%zeropage basicsafe

main {

    ; Far Heap
    ubyte[fmalloc_root.SIZEOF_FMALLOC] fpm;      
    
    sub start() {
                                
        ; Init stuff        
        fmalloc_init();                                  
        api.init();

        ; Test Task
        task_test();

        ; Test fptr.compare
        ;fptr_compare_test(); 

        ; Test fptr.equal
        ;fptr_equal_test()  

        ; Test malloc        
        ;malloc_test();
        
        ; Test fmalloc            
        ;fmalloc_test();

        ; Test Linked List        
        ;linkedlist_test();

        ; Test Queue       
        ;queue_test();
        
    }    

    sub task_test() {
        ubyte[fptr.SIZEOF_FPTR] pTask;                     
        
        emudbg.console_write(iso:"Creating Task 1\r\n") 
        void api.init_task("extprog.prg", "window 1", 10, 10, 100, 100, &pTask);          
        emudbg.console_write(iso:"\r\n") 

        emudbg.console_write(iso:"Creating Task 2\r\n") 
        void api.init_task("extprog.prg", "window 2", 80, 80, 100, 100, &pTask);                          
        emudbg.console_write(iso:"\r\n") 

        emudbg.console_write(iso:"Creating Task 3\r\n") 
        void api.init_task("extprog.prg", "window 3", 90, 120, 100, 100, &pTask);                  
        emudbg.console_write(iso:"\r\n") 

        emudbg.console_write(iso:"Starting Main Loop\r\n") 
        api.mainloop()  
        
    }

    /*
    sub fptr_equal_test() {
        ubyte[fptr.SIZEOF_FPTR] fptr1 = [$02, $34, $12];
        ubyte[fptr.SIZEOF_FPTR] fptr2;
        bool result;

        fptr2 = [$02, $34, $12];                
        result = fptr.equal(&fptr1, &fptr2);
        dump_fptr("\nfptr1: ", fptr1); 
        dump_fptr(" fptr2: ", fptr2); 
        txt.print(" ");
        if result txt.print("true") else txt.print("false")        
        txt.print("\n");

        fptr2 = [$01, $34, $12];                
        result = fptr.equal(&fptr1, &fptr2);
        dump_fptr("\nfptr1: ", fptr1); 
        dump_fptr(" fptr2: ", fptr2); 
        txt.print(" ");
        if result txt.print("true") else txt.print("false")        
        txt.print("\n");

        fptr2 = [$02, $35, $12];                
        result = fptr.equal(&fptr1, &fptr2);
        dump_fptr("\nfptr1: ", fptr1); 
        dump_fptr(" fptr2: ", fptr2); 
        txt.print(" ");
        if result txt.print("true") else txt.print("false")        
        txt.print("\n");

        fptr2 = [$02, $34, $11];                
        result = fptr.equal(&fptr1, &fptr2);
        dump_fptr("\nfptr1: ", fptr1); 
        dump_fptr(" fptr2: ", fptr2); 
        txt.print(" ");
        if result txt.print("true") else txt.print("false")        
        txt.print("\n");

        fptr2 = [$01, $01, $01];                
        result = fptr.equal(&fptr1, &fptr2);
        dump_fptr("\nfptr1: ", fptr1); 
        dump_fptr(" fptr2: ", fptr2); 
        txt.print(" ");
        if result txt.print("true") else txt.print("false")        
        txt.print("\n");
    }

    sub fptr_compare_test()
    {
        ubyte[fptr.SIZEOF_FPTR] fptr1 = [$02, $34, $12];
        ubyte[fptr.SIZEOF_FPTR] fptr2;
        byte result;

        fptr2 = [$01, $34, $12];                
        result = fptr.compare(&fptr1, &fptr2);
        dump_fptr("\nfptr1: ", fptr1); 
        dump_fptr(" fptr2: ", fptr2); 
        txt.print(" ");
        conv.str_b(result)
        txt.print(conv.string_out);
        txt.print("\n");
        
        fptr2 = [$03, $34, $12];                
        result = fptr.compare(&fptr1, &fptr2);
        dump_fptr("\nfptr1: ", fptr1); 
        dump_fptr(" fptr2: ", fptr2); 
        txt.print(" ");
        conv.str_b(result)
        txt.print(conv.string_out);
        txt.print("\n");

        fptr2 = [$02, $34, $11];                
        result = fptr.compare(&fptr1, &fptr2);
        dump_fptr("\nfptr1: ", fptr1); 
        dump_fptr(" fptr2: ", fptr2); 
        txt.print(" ");
        conv.str_b(result)
        txt.print(conv.string_out);
        txt.print("\n");

        fptr2 = [$02, $34, $13];                
        result = fptr.compare(&fptr1, &fptr2);
        dump_fptr("\nfptr1: ", fptr1); 
        dump_fptr(" fptr2: ", fptr2); 
        txt.print(" ");
        conv.str_b(result)
        txt.print(conv.string_out);
        txt.print("\n");

        fptr2 = [$02, $33, $12];                
        result = fptr.compare(&fptr1, &fptr2);
        dump_fptr("\nfptr1: ", fptr1); 
        dump_fptr(" fptr2: ", fptr2); 
        txt.print(" ");
        conv.str_b(result)
        txt.print(conv.string_out);
        txt.print("\n");

        fptr2 = [$02, $35, $12];                
        result = fptr.compare(&fptr1, &fptr2);
        dump_fptr("\nfptr1: ", fptr1); 
        dump_fptr(" fptr2: ", fptr2); 
        txt.print(" ");
        conv.str_b(result)
        txt.print(conv.string_out);
        txt.print("\n");

        fptr2 = [$02, $34, $12];                
        result = fptr.compare(&fptr1, &fptr2);
        dump_fptr("\nfptr1: ", fptr1); 
        dump_fptr(" fptr2: ", fptr2); 
        txt.print(" ");
        conv.str_b(result)
        txt.print(conv.string_out);
        txt.print("\n");

    }
   
    sub fmalloc_test()
    {
        ubyte[fptr.SIZEOF_FPTR] ptr1;
        ubyte[fptr.SIZEOF_FPTR] ptr2;

        fmalloc.malloc(&fpm, 8184, ptr1) 
        dump_fptr("\nptr1: ", ptr1);             
        txt.print("\n");                 

        fmalloc.malloc(&fpm, 8184, ptr2) 
        dump_fptr("\nptr1: ", ptr2);             
        txt.print("\n");                                 
    }    

    sub struct_test()
    {

    }

    sub queue_test() {

        ; Pointer to a linked list
        ubyte[fptr.SIZEOF_FPTR] pQueue;        
        ubyte[fptr.SIZEOF_FPTR] pText;        
        str test = "             ";

        queue.init(&fpm, &pQueue)
        
        void string.copy("element a", &test)                        
        fmalloc.malloc(&fpm, 16, pText)              
        fptr.memcopy_in(&pText, &test, 11);
        queue.q_push(&fpm, &pQueue, pText);

        void string.copy("element b", &test)                        
        fmalloc.malloc(&fpm, 16, pText)              
        fptr.memcopy_in(&pText, &test, 11);
        queue.q_push(&fpm, &pQueue, pText);

        void string.copy("element c", &test)                                        
        fmalloc.malloc(&fpm, 16, pText)              
        fptr.memcopy_in(&pText, &test, 11);
        queue.q_push(&fpm, &pQueue, pText);

        queue.q_pop(&fpm, &pQueue, &pText)
        while fptr.isnull(pText) != true {
            fptr.memcopy_out(&pText, &test, 11);
            txt.print(test)
            txt.print("\n")
            fmalloc.free(&fpm, pText)
            queue.q_pop(&fpm, &pQueue, &pText)
        }        
        queue.free(&fpm, &pQueue)
    }

    sub linkedlist_test() {

        const ubyte listSize = $08

        ; Temp pointers to be used below
        ubyte[fptr.SIZEOF_FPTR] ptr1;
        ubyte[fptr.SIZEOF_FPTR] pText;
        ubyte[fptr.SIZEOF_FPTR] pHold;

        ; Pointer to a linked list
        ubyte[fptr.SIZEOF_FPTR] llr;        
        
        ; Initialize the list        
        linkedlist.init(&fpm, &llr);

        ; Create a string buffer
        str test = "               ";        

        txt.clear_screen();

        uword @zp i;
        for i in 1 to listSize {   

            ; Build the string
            conv.str_uwhex(i)            
            test = "test: ";
            void string.copy(conv.string_out, &test + 6);    

            ; Copy it into far memory            
            fmalloc.malloc(&fpm, 16, pText)              
            fptr.memcopy_in(&pText, &test, 11);
            
            ; Add it to the list            
            linkedlist.add_last(&fpm, llr, &pText, ptr1);    

            if i == 4 pHold = ptr1

            ; Dump the result            
            txt.home();
            dump_fptr("ptext: ", pText);       
            dump_fptr(" ptr1: ", ptr1);             
            txt.print(" ");              
            txt.print(test);        
        }
        
        for i in 1 to listSize {   

            ; Build the string
            conv.str_uwhex(i)            
            test = "head: ";
            void string.copy(conv.string_out, &test + 6);    

            ; Copy it into far memory            
            fmalloc.malloc(&fpm, 16, pText)              
            fptr.memcopy_in(&pText, &test, 11);
            
            ; Add it to the list            
            linkedlist.add_first(&fpm, llr, &pText, ptr1);    

            ; Dump the result            
            txt.home();
            dump_fptr("ptext: ", pText);       
            dump_fptr(" ptr1: ", ptr1);             
            txt.print(" ");              
            txt.print(test);        
        }

        ;txt.clear_screen(); 
        txt.print("\n")  ;

        ; Walk the list
        linkedlist.first(&llr, ptr1);
        while fptr.isnull(&ptr1) != true {

            ; Copy the string into near memory
            linkedlist_item.data_get(ptr1, pText);
            fptr.memcopy_out(&pText, &test, 15);

            ; Print it
            txt.print("\n");
            dump_fptr("ptext: ", pText);                 
            dump_fptr(" ptr1: ", ptr1); 
            txt.print(" ");        
            txt.print(test);                    

            ; Next item
            linkedlist.next(ptr1, ptr1);
        }
        txt.print("\n")  ;

        ; Walk the list backwards
        linkedlist.last(&llr, ptr1);
        while fptr.isnull(&ptr1) != true {

            ; Copy the string into near memory
            linkedlist_item.data_get(ptr1, pText);
            fptr.memcopy_out(&pText, &test, 15);

            ; Print it
            txt.print("\n");
            dump_fptr("ptext: ", pText);                 
            dump_fptr(" ptr1: ", ptr1); 
            txt.print(" ");        
            txt.print(test);                    

            ; Next item
            linkedlist.prev(ptr1, ptr1);

        }
        txt.print("\n");

        linkedlist.movetop(&fpm, llr, pHold)

        ; Walk the list
        linkedlist.first(&llr, ptr1);
        while fptr.isnull(&ptr1) != true {

            ; Copy the string into near memory
            linkedlist_item.data_get(ptr1, pText);
            fptr.memcopy_out(&pText, &test, 15);

            ; Print it
            txt.print("\n");
            dump_fptr("ptext: ", pText);                 
            dump_fptr(" ptr1: ", ptr1); 
            txt.print(" ");        
            txt.print(test);                    

            ; Next item
            linkedlist.next(ptr1, ptr1);
        }
        txt.print("\n");

        linkedlist.movebottom(&fpm, llr, pHold)

        ; Walk the list
        linkedlist.first(&llr, ptr1);
        while fptr.isnull(&ptr1) != true {

            ; Copy the string into near memory
            linkedlist_item.data_get(ptr1, pText);
            fptr.memcopy_out(&pText, &test, 15);

            ; Print it
            txt.print("\n");
            dump_fptr("ptext: ", pText);                 
            dump_fptr(" ptr1: ", ptr1); 
            txt.print(" ");        
            txt.print(test);                    

            ; Next item
            linkedlist.next(ptr1, ptr1);
        }
        txt.print("\n");

        ; Release the list
        linkedlist.free(&fpm, &llr);        
        
    }

    */

    sub fmalloc_init() {

        ; Clear the heap
        fmalloc.init(&fpm);                   

        ; Initialize heap ptr
        ubyte[fptr.SIZEOF_FPTR] fheap1;
        fheap1[1] = $00;
        fheap1[2] = $a0;        

        ; Loop through the banks an add all of them to the heap
        ubyte bank;
        for bank in 1 to 63 {
            fheap1[0] = bank            
            fmalloc.addblock(&fpm, fheap1, 8192);               
        }      

    }    
    
    sub format_fptr(ubyte[fptr.SIZEOF_FPTR] fptr) -> str {

        str buffer = "00:0000"

        conv.str_ubhex(fptr[0])
        string.copy(conv.string_out, &buffer)
        string.copy(":", &buffer + 2)

        conv.str_ubhex(fptr[1])
        string.copy(conv.string_out, &buffer + 3)

        conv.str_ubhex(fptr[2])
        string.copy(conv.string_out, &buffer + 5)

        return buffer
        
    }
           
    sub dump_fptr(str prompt, ubyte[fptr.SIZEOF_FPTR] fptr) {                
        txt.print(prompt);
        txt.print_ubhex(fptr[0], false)        
        txt.print(":");        
        txt.print_ubhex(fptr[2], false)        
        txt.print_ubhex(fptr[1], false)                
    }

    sub dump_ptr(str prompt, uword ptr) {        
        txt.print(prompt);
        txt.print_uwhex(ptr, false)                                      
    }
    
}