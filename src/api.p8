%import diskio
%import task_h
%import queue
%import mouse
%import window
%import desktop
%import linkedlist
%import message_h
%import monogfx2

api {

    romsub $a008 = external_command(uword command @R0, uword param1 @R1, uword param2 @R2, uword pTask @R3);

    const ubyte API_INIT = $01
    const ubyte API_RUN = $02
    const ubyte API_DONE = $03

    ubyte[fptr.SIZEOF_FPTR] pTaskList;
    ubyte[fptr.SIZEOF_FPTR] pQueue;

    uword lastMouseX;
    uword lastMouseY;
    ubyte lastMouseButton;

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

        ; Initialize the queue        
        queue.init(&main.fpm, &pQueue)

        ; Clear the screen        
        monogfx2.hires();
        monogfx2.clear_screen_stipple()
        monogfx2.stipple(false)

        ; Turn on the mouse        
        mouse.mouse_config(1, 640/8, 480/8);

        ; Initial draw        
        post_message(fptr.NULL, fptr.NULL, message.WM_PAINT, 0, 0, fptr.NULL)        
        
    }

    sub registerjumpitem(uword address, uword ptr) -> uword {
        poke(address, $4c)  
        pokew(address+1, ptr)
        return address + 3
    }  

    sub generateMouseEvents() {

        uword mouseX, mouseY
        ubyte mouseButton
        bool  mousePressed
        bool  lastMousePressed

        ; Get the events        
        mouseButton = mouse.mouse_get(2);
        mouseX = cx16.r0;
        mouseY = cx16.r1;
        
        ; Should we generate a mouse move event
        if mouseX != lastMouseX or mouseY != lastMouseY {
            post_message(fptr.NULL, fptr.NULL, message.WM_MOUSE_MOVE, mouseX, mouseY, fptr.NULL)        
        }

        ; Should we generate mouse_button events 
        if mouseButton != lastMouseButton {
            mousePressed = ((mouseButton and 1) == 1)
            lastMousePressed = ((lastMouseButton and 1) == 1)
            if (mousePressed != lastMousePressed) {
                if mousePressed {
                    post_message(fptr.NULL, fptr.NULL, message.WM_MOUSE_LEFT_DOWN, mouseX, mouseY, fptr.NULL)  
                    emudbg.console_write("left-down ")
                } else {
                    post_message(fptr.NULL, fptr.NULL, message.WM_MOUSE_LEFT_UP, mouseX, mouseY, fptr.NULL)  
                    emudbg.console_write("left-up ")
                }
            }
            mousePressed = ((mouseButton and 2) == 2)
            lastMousePressed = ((lastMouseButton and 2) == 2)
            if (mousePressed != lastMousePressed) {
                if mousePressed {                    
                    post_message(fptr.NULL, fptr.NULL, message.WM_MOUSE_RIGHT_DOWN, mouseX, mouseY, fptr.NULL)  
                    emudbg.console_write("right-down ")
                } else {
                    post_message(fptr.NULL, fptr.NULL, message.WM_MOUSE_RIGHT_UP, mouseX, mouseY, fptr.NULL)  
                    emudbg.console_write("right-up ")
                }
            }
        }

        lastMouseX = mouseX
        lastMouseY = mouseY
        lastMouseButton = mouseButton        
    }  
    
    sub mainloop() {
        ubyte[fptr.SIZEOF_FPTR] pTask;
        ubyte[fptr.SIZEOF_FPTR] pTaskData;   
        ubyte[fptr.SIZEOF_FPTR] pMessage;   
        uword current_message                      
        
        while true {    

            ; Generate the mouse events                      
            generateMouseEvents();

            ; Pull a message out of the queue                  
            queue.q_pop(&main.fpm, &pQueue, &pMessage)            

            if (fptr.isnull(&pMessage) == false ) {                

                ; Extract the messageid    
                message.messageid_get(pMessage, &current_message)

                ; If the message is for a specific task, send it
                message.task_get(pMessage, &pTask)
                if (fptr.isnull(&pTask) == false ) {    

                    %asm{{ .byte $db }}

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
                            message.messageid_get(pMessage, &current_message)
                            if current_message == message.WM_CONSUMED 
                            {
                                emudbg.console_write("message-consumed ")
                                goto message_done
                            }         

                            linkedlist.prev(pTask, pTask);
                        }            
                    }

                    ; Send messages with ID < $80, to be processed in forward Z order
                    if (current_message < $8000) {
                        linkedlist.first(&api.pTaskList, pTask);
                        while fptr.isnull(&pTask) != true {                                    
                            send_message(pTask, current_message, pMessage)

                            ; Bail on loop if message was destroyed
                            message.messageid_get(pMessage, &current_message)
                            if current_message == message.WM_CONSUMED 
                            {
                                emudbg.console_write("message-consumed ")
                                goto message_done
                            }         
                            
                            linkedlist.next(pTask, pTask);
                        }
                    }                    
                }                       
            }

            message_done:

            ; Destroy the message (unless something else along the way did)
            if (fptr.isnull(&pMessage) == false ) {
                fmalloc.free(&main.fpm, pMessage);
                pMessage[0] = 0            
                pMessage[1] = 0
                pMessage[2] = 0
            }
        }
    }        
    
    sub post_message(ubyte[fptr.SIZEOF_FPTR] pTask, ubyte[fptr.SIZEOF_FPTR] pComponent, uword messageId, uword param1, uword param2, ubyte[fptr.SIZEOF_FPTR] param3) {        

        ubyte[fptr.SIZEOF_FPTR] pMessage
        
        ; Create a new message
        fmalloc.malloc(&main.fpm, message.MESSAGE_SIZEOF, pMessage) 
        message.task_set(pMessage, pTask)
        message.component_set(pMessage, pComponent)
        message.messageid_set(pMessage, &messageId)
        message.param1_set(pMessage, &param1)
        message.param2_set(pMessage, &param2)
        message.param3_set(pMessage, param3)
        
        ; Push it into the queue
        queue.q_push(&main.fpm, &pQueue, pMessage)
        
    }
    
    sub send_message(ubyte[fptr.SIZEOF_FPTR] pTask, uword messageId, ubyte[fptr.SIZEOF_FPTR] pMessage) -> bool {
        if process_message(pTask, messageId, pMessage) {  
                     
            ; Process user message
            return run_task(pTask, messageId, pMessage)  

        }

        return false;
    }
        
    sub init_message(ubyte[fptr.SIZEOF_FPTR] pTask, uword messageId, ubyte[fptr.SIZEOF_FPTR] pMessage)  {        
        when messageId {
            message.WM_PAINT -> desktop.paint()                        
        }    
    }
    
    sub process_message(ubyte[fptr.SIZEOF_FPTR] pTask, uword messageId, ubyte[fptr.SIZEOF_FPTR] pMessage) -> bool {        
        when messageId {
            message.WM_PAINT -> return window.paint(pTask)            
            message.WM_TEXT -> text(pTask, pMessage)
            message.WM_MOUSE_LEFT_UP -> window.mouseUp(pTask, pMessage)
        }
    }

    sub text (ubyte[fptr.SIZEOF_FPTR] pTask, ubyte[fptr.SIZEOF_FPTR] pMessage) -> bool {

        ubyte[fptr.SIZEOF_FPTR] pTaskData
        ubyte[fptr.SIZEOF_FPTR] pString
        uword task_X, task_Y
        uword text_X, text_Y        
        str buffer = "                                 "

        ; Get the taskdata from the task
        linkedlist_item.data_get(pTask, &pTaskData) 
        
        ; Get the X and Y from the task
        task.x_get(pTaskData, &task_X)
        task.y_get(pTaskData, &task_Y)

        ; Get X and Y from param1 and param2 of message
        message.param1_get(pMessage, &text_X)
        message.param2_get(pMessage, &text_Y)

        ; Get string pointer from param3 of message
        message.param3_get(pMessage, pString)
        fptr.memcopy_out(&pString, buffer, 31);
        buffer[32] = $00

        ; Print it
        monogfx2.text(task_X + text_X, task_Y + text_Y, true, &buffer);

        ; Dispose of string
        fmalloc.free(&main.fpm, pString)

        ; Set message to WM_CONSUMED
        message.messageid_set_wi(pTask, message.WM_CONSUMED)

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
            task.flags_clear(pTaskData)                
            
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
        return task.flags_done_get(pTaskData);
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