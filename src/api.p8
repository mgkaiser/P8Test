%import diskio
%import task_h

api {

    romsub $a008 = external_command(uword command @R0, uword param1 @R1, uword param2 @R2, uword pTask @R3);

    const ubyte API_INIT = $01
    const ubyte API_RUN = $02
    const ubyte API_DONE = $03

    ubyte[fptr.SIZEOF_FPTR] pTaskList;

    sub init() {

        uword address

        ; Register methods from "txt"
        address = $07e0
        address = registerjumpitem(address, &txt.print)     
        address = registerjumpitem(address, &txt.print_uw)     
        address = registerjumpitem(address, &txt.print_uwhex) 
        address = registerjumpitem(address, &txt.print_ub)     
        address = registerjumpitem(address, &txt.print_ubhex)                   
        address = registerjumpitem(address, &txt.column)     
        address = registerjumpitem(address, &txt.get_column)     
        address = registerjumpitem(address, &txt.row)     
        address = registerjumpitem(address, &txt.get_row)     
        
        ; Register methods from "struct"        
        address = $0400
        address = registerjumpitem(address, &struct.set) 
        address = registerjumpitem(address, &struct.get) 
        address = registerjumpitem(address, &struct.set_w) 
        address = registerjumpitem(address, &struct.set_wi) 
        address = registerjumpitem(address, &struct.get_w)     

        ; Register methods from "ptr"                
        address = registerjumpitem(address, &ptr.set_w) 
        address = registerjumpitem(address, &ptr.get_w)   

        ; Register methods from "fstruct"   --> Make sure these restore the previous bank when done             
        address = $0420
        address = registerjumpitem(address, &fstruct.set_zfp) 
        address = registerjumpitem(address, &fstruct.set) 
        address = registerjumpitem(address, &fstruct.get) 
        address = registerjumpitem(address, &fstruct.set_w) 
        address = registerjumpitem(address, &fstruct.set_wi) 
        address = registerjumpitem(address, &fstruct.get_w) 

        ; Register methods from "fptr"      --> Make sure these restore the previous bank when done            
        address = registerjumpitem(address, &fptr.set) 
        address = registerjumpitem(address, &fptr.get) 
        address = registerjumpitem(address, &fptr.memcopy_in) 
        address = registerjumpitem(address, &fptr.memcopy_out) 
        
        ; Register methods from "pmalloc"              
        address = $0440
        address = registerjumpitem(address, &pmalloc_malloc_stub) 
        address = registerjumpitem(address, &pmalloc_free_stub) 

        ; Register methods from "fmalloc"              
        address = $0448
        address = registerjumpitem(address, &fmalloc_malloc_stub) 
        address = registerjumpitem(address, &fmalloc_free_stub) 

        ; Initialize the task list
        linkedlist.init(&main.fpm, &pTaskList);
        
    }

    sub registerjumpitem(uword address, uword ptr) -> uword {
        poke(address, $4c)  
        pokew(address+1, ptr)
        return address + 3
    }    

    sub findByFilename(str filename, ubyte[fptr.SIZEOF_FPTR] pTaskImage) -> bool {
        return false
    }    

    ; Launcher
    ;
    ; Add something into the state so we can tell if the file has already been loaded
    ; If you try to load the same file again, just create a new task, and let the existing instance create a new state
    sub init_task(str filename, uword param1, uword param2, ubyte[fptr.SIZEOF_FPTR] pTask) -> bool {

        ubyte[fptr.SIZEOF_FPTR] pTaskData;
        ubyte[fptr.SIZEOF_FPTR] pTaskImage;
        ubyte[fptr.SIZEOF_FPTR] pFileName;

        ; See if a task with the same file name already exists 
        if findByFilename(filename, pTaskImage) {

            ; Task already exists and pTaskImage contains it's pointer

        } else {

            ; Allocate space for the task
            fmalloc.malloc(&main.fpm, 8184, pTaskImage) 
        }

        ; Allocate and set the filename
        fmalloc.malloc(&main.fpm, string.length(filename) + 1, pFileName)             
        fptr.memcopy_in(&pFileName, filename, string.length(filename) + 1);

        ; Create the Task
        fmalloc.malloc(&main.fpm, task.TASK_SIZEOF, pTaskData)         
        task.done_set_wi(pTaskData, 0)                
        task.taskimage_set(pTaskData, &pTaskImage);                
        task.filename_set(pTaskData, &pFileName)
        
        ; Insert it into task list as pTask
        linkedlist.add_last(&main.fpm, pTaskList, &pTaskData, pTask);          
                
        ; Load Image from disk to pTaskImage[0]:a008
        cx16.rambank(pTaskImage[0]) ;
        uword result = diskio.load(filename, $a008)

        ; If it loaded run it's init method
        if result > 0 {       
            run(pTaskImage[0], API_INIT, param1, param2, pTask)                          

        ; Otherwise release it
        } else {
                           
            ; Free the task
            freeTask(pTask);            
                        
        }
        return result != 0
    }

    sub run_task(ubyte[fptr.SIZEOF_FPTR] pTask, uword param1, uword param2) -> bool {

        ubyte[fptr.SIZEOF_FPTR] pTaskImage;
        ubyte[fptr.SIZEOF_FPTR] pTaskData;
        uword done;

        ; Extract pTaskImage from pTask                                
        linkedlist_item.data_get(pTask, &pTaskData)     
        task.taskimage_get(pTaskData, &pTaskImage)                            

        ; Run the run method
        run(pTaskImage[0], API_RUN, param1, param2, pTask)  
        
        ; Is it done?
        task.done_get(pTaskData, &done)
        return done != 0;
    }

    sub done_task(ubyte[fptr.SIZEOF_FPTR] pTask, uword param1, uword param2) {

        ubyte[fptr.SIZEOF_FPTR] pTaskImage;
        ubyte[fptr.SIZEOF_FPTR] pTaskData;

        ; Extract pTaskImage from pTask
        linkedlist_item.data_get(pTask, &pTaskData)     
        task.taskimage_get(pTaskData, &pTaskImage)             
        
        ; Run the done method - This should at least free the state, clean anything else up too.
        run(pTaskImage[0], API_DONE, param1, param2, pTask)  

        ; Free the task
        freeTask(pTask);

    }

    sub freeTask(ubyte[fptr.SIZEOF_FPTR] pTask) {
        ; If it's the last copy of this image, free pTaskImage
        ; Free pFileName
        ; Free pTaskData  
        ; Remove pTask from list
        ; Set pTask to null  
        pTask[0] = 0;
        pTask[1] = 0;
        pTask[2] = 0;       
    }

    sub run (ubyte bank, uword command, uword param1, uword param2, uword pTask) {
        cx16.rambank(bank);
        external_command(command, param1, param2, pTask);
    }

    ; Stubs for routines that aren't assembly functions
    sub pmalloc_malloc_stub() {
        cx16.r1 = pmalloc.malloc(&main.pm, cx16.r0);
    }

    sub pmalloc_free_stub() {
        pmalloc.free(&main.pm, cx16.r0);
    }

    sub fmalloc_malloc_stub() {
        fmalloc.malloc(&main.fpm, cx16.r0, cx16.r1);
    }

    sub fmalloc_free_stub() {
        fmalloc.free(&main.fpm, cx16.r0);
    }
    
}