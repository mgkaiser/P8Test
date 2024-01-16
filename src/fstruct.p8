fstruct {

    asmsub set_zfp(uword pointer @R0, ubyte offset @R2) {
    %asm{{
        ; Remember the bank
        lda $00 
        pha
        
        ; Set Bank and extract pointer
        ldy #$00
        lda (cx16.r0),y
        sta $00       
        iny
        lda (cx16.r0),y
        sta cx16.r3L
        iny
        lda (cx16.r0),y
        sta cx16.r3H    
        
        ; Store zero in the far pointer
        lda #$00
        ldy cx16.r2L        
        sta (cx16.r3), y
        iny
        sta (cx16.r3), y
        iny
        sta (cx16.r3), y

        ; Restore the bank
        pla
        sta $00
    }}
    }

    asmsub set(uword pointer @R0, ubyte offset @R2, ubyte count @X, uword valuePointer @R1) {
    %asm {{
        ; r4H = Bank of the struct
        ; r4L = Bank of the valuePointer 
        ; r3  = Pointer to the struct
        ; r1  = Pointer to the valuePointer

        ; Remember the bank
        lda $00 
        sta cx16.r4L
        
        ; Set Bank and extract pointer
        ldy #$00
        lda (cx16.r0),y
        sta cx16.r4H  
        iny
        lda (cx16.r0),y
        sta cx16.r3L
        iny
        lda (cx16.r0),y
        sta cx16.r3H            
        
        ; Move the bytes from @R1 - valuePointer
        - 
        lda cx16.r4L
        sta $00
        ldy cx16.r2H
        lda(cx16.r1),y

        ; Move the bytes to @R3 - struct
        pha
        lda cx16.r4H        
        sta $00
        pla
        ldy cx16.r2L
        sta(cx16.r3),y    

        inc cx16.r2L
        inc cx16.r2H
        dex
        bne -

        ; Restore the bank
        lda cx16.r4L
        sta $00
    }}
    }

    asmsub get(uword pointer @R0, ubyte offset @R2, ubyte count @X, uword valuePointer @R1) {
    %asm {{ 
        ; r4H = Bank of the struct
        ; r4L = Bank of the valuePointer 
        ; r3  = Pointer to the struct
        ; r1  = Pointer to the valuePointer

        ; Remember the bank
        lda $00 
        sta cx16.r4L

        ; Set Bank and extract pointer
        ldy #$00
        lda (cx16.r0),y
        sta cx16.r4H    
        iny
        lda (cx16.r0),y
        sta cx16.r3L
        iny
        lda (cx16.r0),y
        sta cx16.r3H      
        
        ; Move the bytes from @R3 - struct
        - 
        lda cx16.r4H
        sta $00
        ldy cx16.r2L
        lda(cx16.r3),y

        ; Move the bytes R1 - valuePointer
        pha
        lda cx16.r4L
        sta $00
        pla
        ldy cx16.r2H
        sta(cx16.r1),y    

        inc cx16.r2L
        inc cx16.r2H
        dex
        bne -

        ; Restore the bank
        lda cx16.r4L
        sta $00
    }}        
    }  
        
    asmsub set_w(uword fptr @R0, ubyte offset @Y, uword valuePointer @R1) {
    %asm {{ 
        ; r4H = Bank of the struct
        ; r4L = Bank of the valuePointer 
        ; r3  = Pointer to the struct
        ; r1  = Pointer to the valuePointer

        ; Remember the bank
        lda $00 
        sta cx16.r4L

        ; Remember the @Y param for later
        phy
        
        ; Set Bank and extract pointer
        ldy #$00
        lda (cx16.r0),y
        sta cx16.r4H         
        iny
        lda (cx16.r0),y
        sta cx16.r2L
        iny
        lda (cx16.r0),y
        sta cx16.r2H  

        ; @R2->Y = *@R1 
        lda cx16.r4L
        sta $00
        ldy #$00        
        lda(cx16.r1),y

        pha
        lda cx16.r4H
        sta $00
        pla
        ply
        sta(cx16.r2),y    

        lda cx16.r4L
        sta $00
        iny
        phy
        ldy #$01    
        lda(cx16.r1),y

        pha
        lda cx16.r4H
        sta $00
        pla
        ply
        sta(cx16.r2),y

        ; Restore the bank
        lda cx16.r4L
        sta $00
    
    }}
    }

    asmsub set_wi(uword fptr @R0, ubyte offset @Y, uword valuePointer @R1) {
    %asm {{ 
        ; r4H = Bank of the struct
        ; r4L = Bank of the valuePointer 
        ; r3  = Pointer to the struct
        ; r1  = Pointer to the valuePointer

        ; Remember the bank
        lda $00 
        sta cx16.r4L
    
        ; Remember the @Y param for later
        phy  

        ; Set Bank and extract pointer
        ldy #$00
        lda (cx16.r0),y
        sta cx16.r4H         
        iny
        lda (cx16.r0),y
        sta cx16.r2L
        iny
        lda (cx16.r0),y
        sta cx16.r2H  

        ; @R2->Y = @R1
        lda cx16.r4L
        sta $00
        ply    
        lda cx16.r1
        pha
        lda cx16.r4H
        sta $00
        pla        
        sta(cx16.r2),y        
        
        lda cx16.r4L
        sta $00
        iny
        lda cx16.r1 + 1                
        pha
        lda cx16.r4H
        sta $00
        pla
        sta(cx16.r2),y

        ; Restore the bank
        lda cx16.r4L
        sta $00
    
    }}
    }

    asmsub get_w(uword fptr @R0, ubyte offset @Y, uword valuePointer @R1) {
    %asm {{
        ; r4H = Bank of the struct
        ; r4L = Bank of the valuePointer 
        ; r3  = Pointer to the struct
        ; r1  = Pointer to the valuePointer

        ; Remember the bank
        lda $00 
        sta cx16.r4L

        ; Remember @Y parameter for later
        phy

        ; Set Bank and extract pointer
        ldy #$00
        lda (cx16.r0),y
        sta cx16.r4H  
        iny
        lda (cx16.r0),y
        sta cx16.r2L
        iny
        lda (cx16.r0),y
        sta cx16.r2H 

        lda cx16.r4H
        sta $00
        ply
        lda (cx16.r2),y 
        iny
        phy
        pha
        lda cx16.r4L
        sta $00
        pla
        ldy #$00
        sta (cx16.r1),y

        lda cx16.r4H
        sta $00
        ply
        lda (cx16.r2),y 
        pha
        lda cx16.r4L
        sta $00
        pla
        ldy #$01
        sta (cx16.r1),y   
        
        ; Restore the bank
        ; Restore the bank
        lda cx16.r4L
        sta $00
    
    }}        
    }        
}

fptr {

    const ubyte SIZEOF_FPTR = 3;
    byte[] NULL = [0,0,0];
    
    inline asmsub b2p(ubyte bank @A, uword ptr @R1, uword fptr @R0) clobbers (Y)
    {
    %asm {{      
    ldy #$00
    sta (cx16.r0)
    iny 
    lda cx16.r1L
    sta (cx16.r0),y  
    iny 
    lda cx16.r1H
    sta (cx16.r0),y  
    }}
    }

    const byte compare_equal = 0;
    const byte compare_greater = 1;
    const byte compare_less = -1;    

    inline asmsub isnull(uword ptr1 @R0) clobbers(Y) -> bool @A {
    %asm{{
    ldy  #0	
	lda  (cx16.r0),y
	iny	
	clc
	adc  (cx16.r0),y
	iny	
	clc
	adc  (cx16.r0),y
	beq  +
	lda  #1
    +
    eor  #1	
    }}
    }

    inline asmsub equal(uword ptr1 @R0, uword ptr2 @R1) clobbers(Y) -> bool @A {
    %asm{{    
    ldy  #0	
	lda  (cx16.r0),y    
    cmp  (cx16.r1),y
    bne +
	iny	
	lda  (cx16.r0),y    
    cmp  (cx16.r1),y
    bne +
	iny	
	lda  (cx16.r0),y    
    cmp  (cx16.r1),y	
    bne +
	lda #1
    bra ++
    +
    lda #0    
    +
    }}  
    }

    inline asmsub notequal(uword ptr1 @R0, uword ptr2 @R1) clobbers(Y) -> bool @A {
    %asm{{    
    ldy  #0	
	lda  (cx16.r0),y    
    cmp  (cx16.r1),y
    bne +
	iny	
	lda  (cx16.r0),y    
    cmp  (cx16.r1),y
    bne +
	iny	
	lda  (cx16.r0),y    
    cmp  (cx16.r1),y	
    bne +
	lda #0
    bra ++
    +
    lda #1    
    +
    }}  
    }
    
    inline asmsub compare(uword ptr1 @R0, uword ptr2 @R1) -> byte @A {
    %asm{{
    ldy #$00
    lda(cx16.r0),y
    cmp(cx16.r1),y
    bcc +                   ; r0[0] < r1[0]
    beq ++                  ; r0[0] == r1[0]
    lda  #1	                ; if it isn't < or == then it is >    
    bra +++++++
    + ; 1
    lda  #-1	
    bra ++++++
    + ; 2    
    ldy #$02
    lda(cx16.r0),y
    cmp(cx16.r1),y
    bcc +                   ; r0[2] < r1[2]
    beq ++                  ; r0[2] == r1[2]
    lda  #1                 ; if it isn't < or == then it is >	
    bra +++++
    + ; 3
    lda  #-1    
    bra ++++
    + ; 4    
    ldy #$01
    lda(cx16.r0),y
    cmp(cx16.r1),y
    bcc +                   ; r0[1] < r1[1]
    beq ++                  ; r0[1] == r1[1]
    lda  #1                 ; if it isn't < or == then it is >
	bra +++
    + ; 5
    lda  #-1    
    bra ++
    + ; 6
    lda #0
    + ; 7

    }}
    }

    ; Needs bank work
    asmsub set(uword fptr @R0, uword valuePointer @R1) clobbers (Y) {
    %asm {{  
        ; Remember the bank
        lda $00 
        pha

        ; Set Bank and extract pointer
        ldy #$00
        lda(cx16.r0),y
        sta $00       
        iny
        lda(cx16.r0),y
        sta cx16.r2L
        iny
        lda(cx16.r0),y
        sta cx16.r2H    
                                
        ldy #$00
        lda(cx16.r1),y  
        sta(cx16.r2),y    
        iny    
        lda(cx16.r1),y    
        sta(cx16.r2),y
        iny    
        lda(cx16.r1),y    
        sta(cx16.r2),y

        ; Restore the bank
        pla
        sta $00
    }}
    }    

    ; Needs bank work
    asmsub get(uword fptr @R0, uword valuePointer @R1) clobbers (Y) {
    %asm {{     
        ; Remember the bank
        lda $00 
        pha

        ; Set Bank and extract pointer
        ldy #$00
        lda (cx16.r0),y
        sta $00       
        iny
        lda (cx16.r0),y
        sta cx16.r2L
        iny
        lda (cx16.r0),y
        sta cx16.r2H
        
        ldy #$00
        lda(cx16.r2),y                
        sta(cx16.r1),y    
        iny
        lda(cx16.r2),y            
        sta(cx16.r1),y
        iny
        lda(cx16.r2),y            
        sta(cx16.r1),y

        ; Restore the bank
        pla
        sta $00
    }}        
    }   

    ; Needs bank work
    asmsub memcopy_in(uword fptr @R0, uword valuePointer @R1, ubyte count @X) clobbers (Y) {
    %asm {{    
        ; Remember the (source) bank
        lda $00 
        pha

        ; Set Bank and extract pointer -> @R2 becomes pointer to destination
        ldy #$01                      
        lda (cx16.r0),y
        sta cx16.r2L
        iny
        lda (cx16.r0),y
        sta cx16.r2H    
        ldy #$00
        lda (cx16.r0),y
        sta $00 

        ldy #$00
        -                        
        lda (cx16.r1),y     ; Load Source Bank before this.         On the stack    Maybe store in @R3h 
        sta (cx16.r2),y     ; Load Destination bank before this.    (@R0)[0]        Maybe store in @R3l
        iny    
        dex
        bne -

        ; Restore the bank
        pla
        sta $00

    }}
    }   

    ; Needs bank work
    asmsub memcopy_out(uword fptr @R0, uword valuePointer @R1, ubyte count @X) clobbers (Y) {
    %asm {{
        ; Remember the (destination) bank
        lda $00 
        pha
             
        ; Set Bank and extract pointer -> @R2 becomes pointer to source
        ldy #$01
        lda (cx16.r0),y
        sta cx16.r2L
        iny
        lda (cx16.r0),y
        sta cx16.r2H    
        ldy #$00
        lda (cx16.r0),y
        sta $00       

        ldy #$00
        -                    
        lda (cx16.r2),y     ; Load Source Bank before this.         (@R0)[0]        Maybe store in @R3l
        sta (cx16.r1),y     ; Load Destination bank before this.    On the stack    Maybe store in @R3h 
        iny    
        dex
        bne -

        ; Restore the bank
        pla
        sta $00

    }}
    }   

}