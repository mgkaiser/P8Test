desktop {

    ubyte[] DESKTOP = [$ff,$ff,$ff];

    ubyte currentPage = 0;

    sub paint () {

        ;emudbg..console_write(iso:"desktop.paint\r\n")

        if monogfx2.drawPage == 0 {
            monogfx2.showpage0()
            monogfx2.drawPage = 1
        } else {
            monogfx2.showpage1()
            monogfx2.drawPage = 0
        }                

        ; Clear the screen        
        monogfx2.clear_screen_stipple()
        monogfx2.stipple(false)

    }

    sub paint_done() {
        ;emudbg..console_write(iso:"desktop.paint_done\r\n")
        if monogfx2.drawPage == 0 {
            monogfx2.showpage0()
        } else {
            monogfx2.showpage1()
        }
    }

    sub mouseMove(ubyte[fptr.SIZEOF_FPTR] pTask, ubyte[fptr.SIZEOF_FPTR] pMessage)  {    
           
        ; If we don't already have focus take focus         
        if fptr.compare(api.pFocusTask, pTask) != fptr.compare_equal {
            api.post_message(pTask, fptr.NULL, message.WM_ENTER, 0, 0, fptr.NULL)
        }            

        ; Consume the message
        message.messageid_set_wi(pMessage, message.WM_CONSUMED)                                
    }

    sub enter (ubyte[fptr.SIZEOF_FPTR] pTask)  {
        ;emudbg..console_write(iso:"desktop.enter\r\n")
        
        ; Send leave to any other window or desktop that has focus   
        if fptr.isnull(api.pFocusTask) != true {
            api.post_message(api.pFocusTask, fptr.NULL, message.WM_LEAVE, 0, 0, fptr.NULL)          
        }

        ; Set this pTask as the focused pTask
        api.pFocusTask[0] = pTask[0]
        api.pFocusTask[1] = pTask[1]
        api.pFocusTask[2] = pTask[2]
    }

    sub leave (ubyte[fptr.SIZEOF_FPTR] pTask) -> bool {
        ;emudbg..console_write(iso:"desktop.leave\r\n")
        
        return true
    }
}