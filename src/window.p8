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

    sub mouseMove(ubyte[fptr.SIZEOF_FPTR] pTask, ubyte[fptr.SIZEOF_FPTR] pMessage) -> bool {

        ubyte[fptr.SIZEOF_FPTR] pTaskData
        ubyte[fptr.SIZEOF_FPTR] pTask2
        uword winX
        uword winY
        uword winH
        uword winW
        uword mouseX
        uword mouseY  
        bool result      

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

            ; Post "WM_ENTER" to this window                        
            if fptr.compare(api.pFocusTask, pTask) != fptr.compare_equal {
                api.post_message(pTask, fptr.NULL, message.WM_ENTER, 0, 0, fptr.NULL)
            }            

            ; Consume the message
            message.messageid_set_wi(pMessage, message.WM_CONSUMED)            

            ; Let the controls on the form also see the message
            result = true

        } else {
                        
            ; Do not let the controls on the form also see the message
            result = false;

        }
        
        return result;

    }

    sub mouseUp(ubyte[fptr.SIZEOF_FPTR] pTask, ubyte[fptr.SIZEOF_FPTR] pMessage, bool left) -> bool {

        ubyte[fptr.SIZEOF_FPTR] pTaskData
        ubyte[fptr.SIZEOF_FPTR] pTask2
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
            
            ; Left button pressed
            if left {
                ; Move window to top and repaint
                linkedlist.movetop(&main.fpm, &api.pTaskList, pTask)            
                api.post_message(fptr.NULL, fptr.NULL, message.WM_PAINT, 0, 0, fptr.NULL)                 
            
            ; Right button pressed
            } else {
            
            }
            
            ; Consume the message
            message.messageid_set_wi(pMessage, message.WM_CONSUMED)            

            ; Let the controls on the form also see the message
            return true;

        } else {
            
            ; Do not let the controls on the form also see the message
            return false;

        }
        
    }

    sub mouseDown(ubyte[fptr.SIZEOF_FPTR] pTask, ubyte[fptr.SIZEOF_FPTR] pMessage, bool left) -> bool {
        return true
    }

    sub enter (ubyte[fptr.SIZEOF_FPTR] pTask) -> bool {
        emudbg.console_write(iso:"window.enter\r\n")

        ; Set the focus flags_done_get
        task.flags_hasfocus_set(pTask)   

        ; Send leave to any other window or desktop that has focus   
        if fptr.isnull(api.pFocusTask) != true {
            api.post_message(api.pFocusTask, fptr.NULL, message.WM_LEAVE, 0, 0, fptr.NULL)          
        }

        ; Set this pTask as the focused pTask
        api.pFocusTask[0] = pTask[0]
        api.pFocusTask[1] = pTask[1]
        api.pFocusTask[2] = pTask[2]

        return true
    }

    sub leave (ubyte[fptr.SIZEOF_FPTR] pTask) -> bool {
        emudbg.console_write(iso:"window.leave\r\n")
        task.flags_hasfocus_clear(pTask)        
        return true
    }

    sub mouseInWindowBoundaries(uword winX, uword winY, uword winH, uword winW, uword mouseX, uword mouseY) -> bool {

        uword winX2
        uword winY2

        winX2 = winX + winW
        winY2 = winY + winH
        
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