%import diskio
%import task_h
%import queue
%import mouse
%import component_h
%import window
%import desktop
%import linkedlist
%import message_h
%import monogfx2
%import fmalloc

api {

    romsub $a008 = external_command(uword command @R0, uword param1 @R1, uword param2 @R2, uword pTask @R3, uword pComponent @R4);

    const ubyte API_INIT = $01
    const ubyte API_RUN = $02
    const ubyte API_DONE = $03

    ubyte[fptr.SIZEOF_FPTR] pTaskList;
    ubyte[fptr.SIZEOF_FPTR] pQueue;
    ubyte[fptr.SIZEOF_FPTR] pFocusTask;

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

        ; Register api methods
        address = $0440
        address = registerjumpitem(address, &add_component_stub)
        
        ; Register methods from "fmalloc"              
        address = $0448
        address = registerjumpitem(address, &fmalloc_malloc_stub) 
        address = registerjumpitem(address, &fmalloc_free_stub) 

        ; Register message methods
        address = $0450
        address = registerjumpitem(address, &post_message_stub)                 

        ; Initialize the task list        
        linkedlist.init(&main.fpm, &pTaskList);

        ; Initialize the queue        
        queue.init(&main.fpm, &pQueue)

        ; Nothing has focus yet
        pFocusTask[0] = 0;
        pFocusTask[1] = 0;
        pFocusTask[2] = 0;

        ; Clear the screen        
        monogfx2.hires();
        monogfx2.clear_screen_stipple()
        monogfx2.stipple(false)

        ; Turn on the mouse        
        mouse.mouse_config(1, 640/8, 480/8);        
        monogfx2.fixSprite()

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
                } else {
                    post_message(fptr.NULL, fptr.NULL, message.WM_MOUSE_LEFT_UP, mouseX, mouseY, fptr.NULL)                      
                }
            }
            mousePressed = ((mouseButton and 2) == 2)
            lastMousePressed = ((lastMouseButton and 2) == 2)
            if (mousePressed != lastMousePressed) {
                if mousePressed {                    
                    post_message(fptr.NULL, fptr.NULL, message.WM_MOUSE_RIGHT_DOWN, mouseX, mouseY, fptr.NULL)                      
                } else {
                    post_message(fptr.NULL, fptr.NULL, message.WM_MOUSE_RIGHT_UP, mouseX, mouseY, fptr.NULL)                      
                }
            }
        }

        lastMouseX = mouseX
        lastMouseY = mouseY
        lastMouseButton = mouseButton        
    }  
    
    sub mainloop() {
        ubyte[fptr.SIZEOF_FPTR] pTask;
        ubyte[fptr.SIZEOF_FPTR] pComponent;        
        ubyte[fptr.SIZEOF_FPTR] pMessage;   
        uword current_message                      
        
        while true {    

            ; Generate the mouse events                      
            generateMouseEvents();

            ; Pull a message out of the queue                  
            queue.q_pop(&main.fpm, &pQueue, &pMessage)  

            ; If there is a message   
            if (fptr.isnull(&pMessage) == false ) {                

                ; Extract the messageid    
                message.messageid_get(pMessage, &current_message)                                

                ; Extract task
                message.task_get(pMessage, &pTask)

                ; If the message is for the desktop dispatch it                
                if (fptr.compare(pTask, desktop.DESKTOP) == fptr.compare_equal) {

                    done_message(pTask, current_message, pMessage)                         

                ; If the message is for a specific task, send it
                } else if (fptr.isnull(&pTask) == false ) {    

                    ; Extract component
                    message.task_get(pMessage, &pComponent)
                    
                    ; Send the message to the one and only task it's meant for                    
                    send_message(pTask, pComponent, current_message, pMessage)                                                    

                ; Otherwise dispatch it    
                } else {

                    ; Do any initialization that must happen before message is dispatched
                    init_message(desktop.DESKTOP, current_message, pMessage)

                    ; Send messages with ID >= $80, to be processed in reverse Z order
                    if (current_message >= $8000) {
                        linkedlist.last(&api.pTaskList, pTask);                        
                        while fptr.isnull(&pTask) != true {
                                         
                            send_message(pTask, fptr.NULL, current_message, pMessage)
                            
                            ; Bail on loop if message was destroyed
                            message.messageid_get(pMessage, &current_message)
                            if current_message == message.WM_CONSUMED 
                            {                                
                                goto message_done
                            }                              

                            linkedlist.prev(pTask, pTask);
                        }            
                    }

                    ; Send messages with ID < $80, to be processed in forward Z order
                    if (current_message < $8000) {
                        linkedlist.first(&api.pTaskList, pTask);
                        while fptr.isnull(&pTask) != true {   
                                                
                            send_message(pTask, fptr.NULL, current_message, pMessage)

                            ; Bail on loop if message was destroyed
                            message.messageid_get(pMessage, &current_message)
                            if current_message == message.WM_CONSUMED 
                            {                                
                                goto message_done
                            }                                 
                            
                            linkedlist.next(pTask, pTask);
                        }
                    }     

                    ; Do any cleanup that must happen
                    done_message(desktop.DESKTOP, current_message, pMessage)                       
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

    sub component_loop(ubyte[fptr.SIZEOF_FPTR] pTask, ubyte[fptr.SIZEOF_FPTR] pComponent, uword messageId, ubyte[fptr.SIZEOF_FPTR] pMessage) {
                
        ubyte[fptr.SIZEOF_FPTR] pTaskData;
        ubyte[fptr.SIZEOF_FPTR] pComponents;

        ; Get the taskdata from the task
        linkedlist_item.data_get(pTask, &pTaskData)   

        ; Get the component list for the task
        task.components_get(pTaskData, &pComponents)

        ; Walk the list

            ; If pComponent == NULL process_component_message then run_task for component
            ; If pComponent != NULL -> only for pComponent specified process_component_message then run_task for component

    }

    sub process_component_message() {
        ; nested when componentId
            ; nested when messageId
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
    
    sub send_message(ubyte[fptr.SIZEOF_FPTR] pTask, ubyte[fptr.SIZEOF_FPTR] pComponent, uword messageId, ubyte[fptr.SIZEOF_FPTR] pMessage) -> bool {
        bool result = false
        if process_message(pTask, messageId, pMessage) {  
                     
            ; Process user message            
            result = run_task(pTask, messageId, pMessage, fptr.NULL)  
            
        }

        ; Walk the list of controls on the form and dispatch to them...   
        if messageId != message.WM_CONSUMED {
            component_loop(pTask, pComponent, messageId, pMessage);
        }

        return result;
    }
        
    sub init_message(ubyte[fptr.SIZEOF_FPTR] pTask, uword messageId, ubyte[fptr.SIZEOF_FPTR] pMessage)  {        
        when messageId {
            message.WM_PAINT -> desktop.paint()                        
        }    
    }
    
    sub process_message(ubyte[fptr.SIZEOF_FPTR] pTask, uword messageId, ubyte[fptr.SIZEOF_FPTR] pMessage) -> bool {     
        bool result;          
        ;emudbg.console_value1($05)          
        ;%asm{{ .byte $db }}
        when messageId {
            message.WM_PAINT -> result = window.paint(pTask)                        
            message.WM_MOUSE_MOVE -> result = window.mouseMove(pTask, pMessage)
            message.WM_MOUSE_LEFT_UP -> result = window.mouseUp(pTask, pMessage, true)
            message.WM_MOUSE_RIGHT_UP -> result = window.mouseUp(pTask, pMessage, false)
            message.WM_MOUSE_LEFT_DOWN -> result = window.mouseDown(pTask, pMessage, true)
            message.WM_MOUSE_RIGHT_DOWN -> result = window.mouseDown(pTask, pMessage, false)
            message.WM_ENTER -> result = window.enter(pTask)
            message.WM_LEAVE -> result = window.leave(pTask)
            message.WM_TOP -> window.top(pTask)
        }
        ;emudbg.console_value1($15)          
        return result;
    }

    sub done_message(ubyte[fptr.SIZEOF_FPTR] pTask, uword messageId, ubyte[fptr.SIZEOF_FPTR] pMessage)  {                                                
        when messageId { 
            message.WM_PAINT -> desktop.paint_done()           
            message.WM_MOUSE_MOVE -> desktop.mouseMove(pTask, pMessage)            
            message.WM_ENTER -> desktop.enter(pTask)
            message.WM_LEAVE -> desktop.leave(pTask)
        }                        
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

    sub add_component(ubyte[fptr.SIZEOF_FPTR] pTask, uword componentId, uword x, uword y, uword h, uword w, ubyte[fptr.SIZEOF_FPTR] pText, ubyte[fptr.SIZEOF_FPTR] pComponent ) {

        ubyte[fptr.SIZEOF_FPTR] pTaskData
        ubyte[fptr.SIZEOF_FPTR] pComponents
        ubyte[fptr.SIZEOF_FPTR] pComponentData

        ; Get the task data for this task
        linkedlist_item.data_get(pTask, &pTaskData) 

        ; Get the component list for this task
        task.components_get(pTaskData, &pComponents)

        ; Allocate a new component
        fmalloc.malloc(&main.fpm, component.COMPONENT_SIZEOF, pComponentData)

        ; Set the data
        component.componentId_set(pComponentData, componentId)
        component.x_set(pComponentData, x)
        component.y_set(pComponentData, y)
        component.h_set(pComponentData, h)
        component.w_set(pComponentData, w)
        component.text_set(pComponentData, pText)

        ; Add it to the list
        emudbg.console_write(iso:"pComponents: ")
        emudbg.console_write(main.format_fptr(pComponents))
        emudbg.console_write(iso:"\r\n")
        ;linkedlist.add_first(&main.fpm, pComponents, &pComponentData, pComponent);
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
        ubyte[fptr.SIZEOF_FPTR] pComponents;

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

            ; Create the compnent list
            linkedlist.init(&main.fpm, pComponents)             
            task.components_set(pTaskData, pComponents)
            
            ; Insert it into task list as pTask
            linkedlist.add_first(&main.fpm, pTaskList, &pTaskData, pTask);                                                  

            ; If it loaded run it's init method
            ;emudbg.console_value1($20) 
            run(pTaskImage[0], API_INIT, 0, 0, pTask, 0)                                                          
            ;emudbg.console_value1($21) 

            return true
        } else {
            return false
        }        
    }

    sub run_task(ubyte[fptr.SIZEOF_FPTR] pTask, ubyte[fptr.SIZEOF_FPTR] pComponent, uword messageId, ubyte[fptr.SIZEOF_FPTR] pMessage) -> bool {

        ubyte[fptr.SIZEOF_FPTR] pTaskImage;
        ubyte[fptr.SIZEOF_FPTR] pTaskData;
        uword done;

        ; Extract pTaskImage from pTask                                
        linkedlist_item.data_get(pTask, &pTaskData)     
        task.taskimage_get(pTaskData, &pTaskImage)                            

        ; Run the run method
        ;emudbg.console_value1($06)          
        ;%asm{{ .byte $db }}
        run(pTaskImage[0], API_RUN, messageId, &pMessage, pTask, pComponent)  
        
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
        ;emudbg.console_value1($07)          
        ;%asm{{ .byte $db }}
        run(pTaskImage[0], API_DONE, 0, 0, pTask, 0)  

        ; Free the task
        freeTask(pTask);

    }

    sub freeTask(ubyte[fptr.SIZEOF_FPTR] pTask) {
        ; If it's the last copy of this image, free pTaskImage
        ; Free pFileName
        ; Free pTitle        
        ; Free pComponents 
        ; Free pTaskData  
        ; Remove pTask from list
        ; Set pTask to null  
        pTask[0] = 0;
        pTask[1] = 0;
        pTask[2] = 0;       
    }

    sub run (ubyte bank, uword messageId, uword param1, uword param2, uword pTask, uword pComponent) {
        ;emudbg.console_value1($08)          
        ;%asm{{ .byte $db }}
        cx16.rambank(bank);        
        external_command(messageId, param1, param2, pTask, pComponent);
        ;emudbg.console_value1($18)
        ;%asm{{ .byte $db }}
    }    

    ; Stubs for routines that aren't assembly functions    
    sub add_component_stub() {
        add_component(cx16.r0, cx16.r1, cx16.r2, cx16.r3, cx16.r4, cx16.r5, cx16.r6, cx16.r7 )
    }
    
    sub fmalloc_malloc_stub() {
        fmalloc.malloc(&main.fpm, cx16.r0, cx16.r1);
    }

    sub fmalloc_free_stub() {
        fmalloc.free(&main.fpm, cx16.r0);
    }

    sub post_message_stub() {
        post_message(cx16.r0, cx16.r1, cx16.r2, cx16.r3, cx16.r4, cx16.r5)              
    }
    
}