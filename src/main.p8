%import textio
%import string
%import fmalloc
%import linkedlist
%option no_sysinit
%zeropage basicsafe

main {

    ; Pointer to the Stack Manager         
    ubyte[fmalloc_root.SIZEOF_FMALLOC] fpm;  
    
    sub start() {
                
        txt.print("p8test\n"); 

        ; Test fptr.compare
        ;fptr_compare_test(); 

        ; Test fptr.equal
        fptr_equal_test()                                

        ; Test Linked List
        ;fmalloc_init();
        ;linkedlist_test();
        
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

        uword i;
        for i in 1 to $200 {   

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

        for i in 1 to $200 {   

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
       
    sub dump_fptr(str prompt, ubyte[fptr.SIZEOF_FPTR] fptr)
    {        
        txt.print(prompt);
        conv.str_ubhex(fptr[0])
        txt.print(conv.string_out);        
        txt.print(":");        
        conv.str_ubhex(fptr[2])
        txt.print(conv.string_out);
        conv.str_ubhex(fptr[1])
        txt.print(conv.string_out);                
    }
}