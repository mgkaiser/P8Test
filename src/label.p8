label {    
    ;** Methods
    
    ; WM_PAINT
    sub paint (ubyte[fptr.SIZEOF_FPTR] pTask, ubyte[fptr.SIZEOF_FPTR] pComponentData) {

        ubyte[fptr.SIZEOF_FPTR] pTaskData
        ubyte[fptr.SIZEOF_FPTR] pText
        uword winX
        uword winY
        uword labX
        uword labY  
        str petscii = "????????????????"
        str screencode = "????????????????"      

        emudbg.console_write(iso:"label.paint\r\n")

        ; Clear the buffer
        sys.memset(&petscii, 16, 0);
        sys.memset(&screencode, 16, 0);
        
        ; Get the window dimensions
        linkedlist_item.data_get(pTask, &pTaskData)   
        task.x_get(pTaskData, &winX)
        task.y_get(pTaskData, &winY)        

        ; Get the label dimensions
        component.x_get(pComponentData, &labX)
        component.y_get(pComponentData, &labY)
                
        ; Extract text
        component.text_get(pComponentData, &pText)
        fptr.memcopy_out(&pText, &petscii, 16); 

        ; Convert it        
        monogfx2.petsciiToScreencode(petscii, screencode)

        ; Display it
        monogfx2.text(winX + labX, winY + labY, false, &screencode)

    }

    ; WM_SET_TEXT
    ; WM_GET_TEXT
    ; WM_ENTER
    ; WM_LEAVE
    ; WM_CLICK

}