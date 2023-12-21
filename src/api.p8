%import diskio
%import task_h
%import message_h
%import monogfx2

api {

    romsub $a008 = external_command(uword command @R0, uword param1 @R1, uword param2 @R2, uword pTask @R3);

    const ubyte API_INIT = $01
    const ubyte API_RUN = $02
    const ubyte API_DONE = $03

    const uword WM_NULL         = $0000

    const uword WM_MOUSE_MOVE   = $0100
    const uword WM_MOUSE_UP     = $0101
    const uword WM_MOUSE_DOWN   = $0102

    const uword WM_PAINT        = $8000

    ubyte[fptr.SIZEOF_FPTR] pTaskList;

    sub init() {

        uword address

        ; Register methods from "txt" 
        ;   -> Replace all of these with abstracts that take the pTask pointer and constrain output to the frame.
        ;   -> Double buffer this so it all draws to background page which will be displayed all at once
        ;   -> Maybe also add "draw frame" which will draw box of x,y,h,w dimensions and add a title.
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

        ; Clear the screen
        monogfx2.hires();
        monogfx2.clear_screen_stipple()
        monogfx2.stipple(false)

        ; Initial draw
        post_message(fptr.NULL, fptr.NULL, WM_PAINT, 0, 0, 0)
        
    }

    sub registerjumpitem(uword address, uword ptr) -> uword {
        poke(address, $4c)  
        pokew(address+1, ptr)
        return address + 3
    }    
    
    sub mainloop() {
        ubyte[fptr.SIZEOF_FPTR] pTask;
        ubyte[fptr.SIZEOF_FPTR] pTaskData;   
        ubyte[fptr.SIZEOF_FPTR] pMessage;   
        uword current_message
                
        fmalloc.malloc(&main.fpm, message.MESSAGE_SIZEOF, pMessage) 
        message.task_set(pMessage, &fptr.NULL)
        message.component_set(pMessage, &fptr.NULL)
        message.messageid_set_wi(pMessage, WM_PAINT)
        message.param1_set_wi(pMessage, 0)
        message.param2_set_wi(pMessage, 0)
        message.param3_set_wi(pMessage, 0)
        
        while true {    

            ; Pull a message out of the queue

            if (fptr.isnull(&pMessage) == false ) {

                ; Extract the messageid    
                message.messageid_get(pMessage, &current_message)

                ; If the message is for a specific task, send it
                message.task_get(pMessage, &pTask)
                if (fptr.isnull(&pTask) == false ) {    

                    ; Send the message to the one and only task it's meant for
                    send_message(pTask, current_message, pMessage)                                             

                ; Otherwise dispatch it    
                } else {

                    ; Do any initialization that must happen before message is dispatched
                    init_message(pTask, message, pMessage)

                    ; Send messages with ID >= $80, to be processed in reverse Z order
                    if (current_message >= $8000) {
                        linkedlist.last(&api.pTaskList, pTask);                        
                        while fptr.isnull(&pTask) != true {                
                            send_message(pTask, current_message, pMessage)   
                            ; Bail on loop if message was destroyed                              
                            linkedlist.prev(pTask, pTask);
                        }            
                    }

                    ; Send messages with ID < $80, to be processed in forward Z order
                    if (current_message < $8000) {
                        linkedlist.first(&api.pTaskList, pTask);
                        while fptr.isnull(&pTask) != true {                                    
                            send_message(pTask, current_message, pMessage)
                            ; Bail on loop if message was destroyed
                            linkedlist.next(pTask, pTask);
                        }
                    }
                }
            }

            ; Destroy the message (unless something else along the way did)
            if (fptr.isnull(&pMessage) == false ) {
                fmalloc.free(&main.fpm, pMessage);
                pMessage[0] = 0            
                pMessage[1] = 0
                pMessage[2] = 0
            }
        }
    }        
    
    sub post_message(ubyte[fptr.SIZEOF_FPTR] pTask, ubyte[fptr.SIZEOF_FPTR] pComponent, uword messageId, uword param1, uword param2, uword param3) {        

        ubyte[fptr.SIZEOF_FPTR] pMessage
        
        ; Create a new message
        fmalloc.malloc(&main.fpm, message.MESSAGE_SIZEOF, pMessage) 
        message.task_set(pMessage, &pTask)
        message.component_set(pMessage, &pComponent)
        message.messageid_set(pMessage, &messageId)
        message.param1_set(pMessage, &param1)
        message.param2_set(pMessage, &param2)
        message.param3_set(pMessage, &param3)

        ; Push it into the queue
        fmalloc.free(&main.fpm, pMessage)
    }
    
    sub send_message(ubyte[fptr.SIZEOF_FPTR] pTask, uword messageId, ubyte[fptr.SIZEOF_FPTR] pMessage) {
        if process_message(pTask, messageId, pMessage) {  
                     
            ; Process user message
            run_task(pTask, messageId, pMessage)  

        }
    }
        
    sub init_message(ubyte[fptr.SIZEOF_FPTR] pTask, uword messageId, ubyte[fptr.SIZEOF_FPTR] pMessage)  {        
        when messageId {
            WM_PAINT -> paint_init()            
        }    
    }
    
    sub process_message(ubyte[fptr.SIZEOF_FPTR] pTask, uword messageId, ubyte[fptr.SIZEOF_FPTR] pMessage) -> bool {        
        when messageId {
            WM_PAINT -> return paint(pTask)            
        }
    }

    sub paint_init () {

        ; Clear the screen
        monogfx2.clear_screen_stipple()

    }

    sub paint (ubyte[fptr.SIZEOF_FPTR] pTask) -> bool {

        ubyte[fptr.SIZEOF_FPTR] pTaskData;
        uword x
        uword y
        uword h
        uword w

        ; Get the task data        
        linkedlist_item.data_get(pTask, &pTaskData)   
        task.x_get(pTaskData, &x)
        task.y_get(pTaskData, &y)
        task.h_get(pTaskData, &h)
        task.w_get(pTaskData, &w)

        ; Draw the window        
        monogfx2.fillrect(x,y,w,h,true);
        monogfx2.rect(x,y,w,h,false);

        ; Draw a header with title

        ; Draw a footer

        ; Let the task draw more on it
        return true;

    }

    sub findByFilename(str filename, ubyte[fptr.SIZEOF_FPTR] pTaskImage) -> bool {        
                
        ubyte[fptr.SIZEOF_FPTR] pTaskData2;
        ubyte[fptr.SIZEOF_FPTR] pFileName2;
        ubyte[fptr.SIZEOF_FPTR] pTask2
        str filename2 = "                 "
        
        linkedlist.first(&api.pTaskList, pTask2);
        while fptr.isnull(&pTask2) != true {                

            ; Get the task's filename: filename2 = *(pTask2->pTaskData2->pFileName2)
            linkedlist_item.data_get(pTask2, &pTaskData2) 
            task.filename_get(pTaskData2, &pFileName2)
            fptr.memcopy_out(&pFileName2, filename2, string.length(filename2) - 1)

            ; Does filename == filename2
            if string.compare(filename, filename2) == 0 {
                task.taskimage_get(pTaskData2, &pTaskImage)   
                return true
            }            
                                
            ; Next item
            linkedlist.next(pTask2, pTask2);

        }

        return false
    }    

    ; Launcher
    ;
    ; Add something into the state so we can tell if the file has already been loaded
    ; If you try to load the same file again, just create a new task, and let the existing instance create a new state
    sub init_task(str filename, str title, uword x, uword y, uword h, uword w, ubyte[fptr.SIZEOF_FPTR] pTask) -> bool {

        ubyte[fptr.SIZEOF_FPTR] pTaskData;
        ubyte[fptr.SIZEOF_FPTR] pTaskImage;        
        ubyte[fptr.SIZEOF_FPTR] pFileName;
        ubyte[fptr.SIZEOF_FPTR] pTitle;

        ; See if a task with the same file name already exists 
        if findByFilename(filename, pTaskImage) {

            ; Task already exists and pTaskImage contains it's pointer

        } else {

            ; Allocate space for the task
            fmalloc.malloc(&main.fpm, 8184, pTaskImage) 

            ; Load the image
            cx16.rambank(pTaskImage[0]) ;
            uword result = diskio.load(filename, $a008)
            if result == 0 {
                fmalloc.free(&main.fpm, pTaskImage)
            }

        }
        
        if fptr.isnull(&pTaskImage) == false {       

            ; Allocate and set the filename
            fmalloc.malloc(&main.fpm, string.length(filename) + 1, pFileName)             
            fptr.memcopy_in(&pFileName, filename, string.length(filename) + 1);

            ; Allocate and set the title
            fmalloc.malloc(&main.fpm, string.length(title) + 1, pTitle)             
            fptr.memcopy_in(&pTitle, title, string.length(title) + 1);            

            ; Create the Task
            fmalloc.malloc(&main.fpm, task.TASK_SIZEOF, pTaskData)                                 
            task.taskimage_set(pTaskData, &pTaskImage);                
            task.filename_set(pTaskData, &pFileName)
            task.title_set(pTaskData, &pTitle)
            task.x_set(pTaskData, &x)
            task.y_set(pTaskData, &y)
            task.h_set(pTaskData, &h)
            task.w_set(pTaskData, &w)
            task.done_set_wi(pTaskData, 0)                
            
            ; Insert it into task list as pTask
            linkedlist.add_first(&main.fpm, pTaskList, &pTaskData, pTask);                                                  

            ; If it loaded run it's init method
            run(pTaskImage[0], API_INIT, 0, 0, pTask)                                                          

            return true
        } else {
            return false
        }        
    }

    sub run_task(ubyte[fptr.SIZEOF_FPTR] pTask, uword messageId, ubyte[fptr.SIZEOF_FPTR] pMessage) -> bool {

        ubyte[fptr.SIZEOF_FPTR] pTaskImage;
        ubyte[fptr.SIZEOF_FPTR] pTaskData;
        uword done;

        ; Extract pTaskImage from pTask                                
        linkedlist_item.data_get(pTask, &pTaskData)     
        task.taskimage_get(pTaskData, &pTaskImage)                            

        ; Run the run method
        run(pTaskImage[0], API_RUN, messageId, &pMessage, pTask)  
        
        ; Is it done?
        task.done_get(pTaskData, &done)
        return done != 0;
    }

    sub done_task(ubyte[fptr.SIZEOF_FPTR] pTask) {

        ubyte[fptr.SIZEOF_FPTR] pTaskImage;
        ubyte[fptr.SIZEOF_FPTR] pTaskData;

        ; Extract pTaskImage from pTask
        linkedlist_item.data_get(pTask, &pTaskData)     
        task.taskimage_get(pTaskData, &pTaskImage)             
        
        ; Run the done method - This should at least free the state, clean anything else up too.
        run(pTaskImage[0], API_DONE, 0, 0, pTask)  

        ; Free the task
        freeTask(pTask);

    }

    sub freeTask(ubyte[fptr.SIZEOF_FPTR] pTask) {
        ; If it's the last copy of this image, free pTaskImage
        ; Free pFileName
        ; Free pTitle        
        ; Free pTaskData  
        ; Remove pTask from list
        ; Set pTask to null  
        pTask[0] = 0;
        pTask[1] = 0;
        pTask[2] = 0;       
    }

    sub run (ubyte bank, uword messageId, uword param1, uword param2, uword pTask) {
        cx16.rambank(bank);
        external_command(messageId, param1, param2, pTask);
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