window {

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

    sub mouseUp(ubyte[fptr.SIZEOF_FPTR] pTask, ubyte[fptr.SIZEOF_FPTR] pMessage) -> bool {

        ubyte[fptr.SIZEOF_FPTR] pTaskData
        uword winX
        uword winY
        uword winH
        uword winW
        uword mouseX
        uword mouseY        

        ; Get the window dimensions
        linkedlist_item.data_get(pTask, &pTaskData)   
        task.x_get(pTaskData, &winX)
        task.y_get(pTaskData, &winY)
        task.h_get(pTaskData, &winH)
        task.w_get(pTaskData, &winW)

        ; Get the mouse param1_set
        message.param1_get(pMessage, &mouseX)
        message.param2_get(pMessage, &mouseY)

        ; Did they click in this window?
        if mouseInWindowBoundaries(winX, winY, winH, winW, mouseX, mouseY) {            
            ; Move window to top and repaint
            linkedlist.movetop(&main.fpm, &api.pTaskList, pTask)            
            api.post_message(fptr.NULL, fptr.NULL, message.WM_PAINT, 0, 0, fptr.NULL)                 

            ; Consume the message
            message.messageid_set_wi(pMessage, message.WM_CONSUMED)            

            ; Let the controls on the form also see the message
            return true;

        } else {
            
            ; Do not let the controls on the form also see the message
            return false;

        }
        
    }

    sub mouseInWindowBoundaries(uword winX, uword winY, uword winH, uword winW, uword mouseX, uword mouseY) -> bool {

        uword winX2
        uword winY2

        winX2 = winX + winW
        winY2 = winY + winH

        /*
        emudbg.console_write("mousex: ")
        conv.str_uw(mouseX)
        emudbg.console_write(conv.string_out)                                      
        emudbg.console_write(" ")
        emudbg.console_value1(0) 

        emudbg.console_write("mousey: ")
        conv.str_uw(mouseY)
        emudbg.console_write(conv.string_out)                                      
        emudbg.console_write(" ")
        emudbg.console_value1(0) 

        emudbg.console_write("winx: ")
        conv.str_uw(winX)
        emudbg.console_write(conv.string_out)                                      
        emudbg.console_write(" ")
        emudbg.console_value1(0) 

        emudbg.console_write("winy: ")
        conv.str_uw(winY)
        emudbg.console_write(conv.string_out)                                      
        emudbg.console_write(" ")
        emudbg.console_value1(0) 

        emudbg.console_write("winx2: ")
        conv.str_uw(winX2)
        emudbg.console_write(conv.string_out)                                      
        emudbg.console_write(" ")
        emudbg.console_value1(0) 

        emudbg.console_write("winy2: ")
        conv.str_uw(winY2)
        emudbg.console_write(conv.string_out)                                      
        emudbg.console_write(" ")
        emudbg.console_value1(0)                         
        */

        if (mouseX >= winX) and (mouseX <= winX2) {            
            if (mouseY >= winY) and (mouseY <= winY2) {                
                return true
            } else {
                return false    
            }
        } else {
            return false
        }        
    }
}