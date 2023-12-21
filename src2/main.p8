%import api
%import textio
%import string
%import fmalloc
%import pmalloc
%import linkedlist
%import monogfx2
%option no_sysinit
%zeropage basicsafe

main {

    ; Far Heap
    ubyte[fmalloc_root.SIZEOF_FMALLOC] fpm;  

    ; Near Heap
    uword heap = memory("heap", 8192, 0);
    ubyte[pmalloc.SIZEOF_PMALLOC] pm    
    
    sub start() {
                        
        ; Init stuff        
        fmalloc_init();                          
        malloc_init();
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
        
    }    

    sub task_test() {
        ubyte[fptr.SIZEOF_FPTR] pTask;                     

        void api.init_task("extprog.prg", "window 1", 10, 10, 100, 100, &pTask);          
        void api.init_task("extprog.prg", "window 2", 80, 80, 100, 100, &pTask);                  
        void api.init_task("extprog.prg", "window 3", 90, 120, 100, 100, &pTask);                  

        api.mainloop()  
        
    }

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

    sub malloc_test()
    {
        uword ptr1;
        uword ptr2;
        uword ptr3;

        ptr1 = pmalloc.malloc(&pm, 32);
        dump_ptr("\nptr1:", ptr1);

        ptr2 = pmalloc.malloc(&pm, 32);
        dump_ptr("\nptr2:", ptr2);

        ptr3 = pmalloc.malloc(&pm, 32);
        dump_ptr("\nptr3:", ptr3);

        pmalloc.free(&pm, ptr1);
        pmalloc.free(&pm, ptr3);

        ptr3 = pmalloc.malloc(&pm, 32);
        dump_ptr("\nptr3:", ptr3);
        
        pmalloc.free(&pm, ptr3);

        ptr3 = pmalloc.malloc(&pm, 64);
        dump_ptr("\nptr3:", ptr3);

        ptr1 = pmalloc.malloc(&pm, 32);
        dump_ptr("\nptr1:", ptr1);
        
                        
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

    sub linkedlist_test() {

        ; Temp pointers to be used below
        ubyte[fptr.SIZEOF_FPTR] ptr1;
        ubyte[fptr.SIZEOF_FPTR] pText;

        ; Pointer to a linked list
        ubyte[fptr.SIZEOF_FPTR] llr;        
        
        ; Initialize the list        
        linkedlist.init(&fpm, &llr);

        ; Create a string buffer
        str test = "               ";        

        txt.clear_screen();

        uword @zp i;
        for i in 1 to $80 {   

            ; Build the string
            conv.str_uwhex(i)            
            test = "test: ";
            void string.copy(conv.string_out, &test + 6);    

            ; Copy it into far memory            
            fmalloc.malloc(&fpm, 16, pText)              
            fptr.memcopy_in(&pText, &test, 11);
            
            ; Add it to the list            
            linkedlist.add_last(&fpm, llr, &pText, ptr1);    

            ; Dump the result            
            txt.home();
            dump_fptr("ptext: ", pText);       
            dump_fptr(" ptr1: ", ptr1);             
            txt.print(" ");              
            txt.print(test);        
        }

        for i in 1 to $80 {   

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

        ;txt.clear_screen();   
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

        ; Release the list
        linkedlist.free(&fpm, &llr);        
        
    }

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

    sub malloc_init() {

        ; Clear the heap
        pmalloc.init(&pm);                           

        ; Add heap
        pmalloc.addblock(&pm, heap, 8192);               

    }
       
    sub dump_fptr(str prompt, ubyte[fptr.SIZEOF_FPTR] fptr)
    {        
        txt.print(prompt);
        txt.print_ubhex(fptr[0], false)        
        txt.print(":");        
        txt.print_ubhex(fptr[2], false)        
        txt.print_ubhex(fptr[1], false)                
    }

    sub dump_ptr(str prompt, uword ptr)
    {        
        txt.print(prompt);
        txt.print_uwhex(ptr, false)                                      
    }
    
}