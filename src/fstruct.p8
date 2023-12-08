fstruct {

    inline asmsub set_zfp(uword pointer @R0, ubyte offset @R2) {
    %asm{{
      
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
    
    lda #$00
    ldy cx16.r2L        
    sta (cx16.r3), y
    iny
    sta (cx16.r3), y
    iny
    sta (cx16.r3), y
    }}
    }

    inline asmsub set(uword pointer @R0, ubyte offset @R2, ubyte count @X, uword valuePointer @R1) {
    %asm {{
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
    ; Move the bytes from @R1 to @R3
    - 
    ldy cx16.r2H
    lda(cx16.r1),y
    ldy cx16.r2L
    sta(cx16.r3),y    
    inc cx16.r2L
    inc cx16.r2H
    dex
    bne -
    }}
    }

    inline asmsub get(uword pointer @R0, ubyte offset @R2, ubyte count @X, uword valuePointer @R1) {
    %asm {{     
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
    ; Move the bytes from @R3 to @R1
    - 
    ldy cx16.r2L
    lda(cx16.r3),y
    ldy cx16.r2H
    sta(cx16.r1),y    
    inc cx16.r2L
    inc cx16.r2H
    dex
    bne -
    }}        
    }  
        
    inline asmsub set_w(uword fptr @R0, ubyte offset @Y, uword valuePointer @R1) {
    %asm {{ 
    phy
    
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

    ; @R2->Y = *@R1 
    ldy #$00
    lda(cx16.r1),y
    ply
    sta(cx16.r2),y    
    iny
    phy
    ldy #$01    
    lda(cx16.r1),y
    ply
    sta(cx16.r2),y
    
    }}
    }

    inline asmsub set_wi(uword fptr @R0, ubyte offset @Y, uword valuePointer @R1) {
    %asm {{ 
    
    phy  

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

    ; @R2->Y = @R1
    ply    
    lda cx16.r1
    sta(cx16.r2),y
    iny
    lda cx16.r1 + 1
    sta(cx16.r2),y
    
    }}
    }

    inline asmsub get_w(uword fptr @R0, ubyte offset @Y, uword valuePointer @R1) {
    %asm {{

    phy

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

    ply
    lda (cx16.r2),y 
    iny
    phy
    ldy #$00
    sta (cx16.r1),y
    ply
    lda (cx16.r2),y 
    ldy #$01
    sta (cx16.r1),y    
    
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
    
    inline asmsub compare(uword ptr1 @R0, uword ptr2 @R1) -> byte @A {
    %asm{{
    ldy #$00
    lda(cx16.r0),y
    cmp(cx16.r1),y
    bcc +
    beq ++
    lda  #1	
    sec
    bcs +++++++
    + ; 1
    lda  #-1
	sec
    bcs ++++++
    + ; 2
    iny
    ldy #$00
    lda(cx16.r0),y
    cmp(cx16.r1),y
    bcc +
    beq ++
    lda  #1
	sec
    bcs +++++
    + ; 3
    lda  #-1
    sec
    bcs ++++
    + ; 4
    iny
    ldy #$00
    lda(cx16.r0),y
    cmp(cx16.r1),y
    bcc +
    beq ++
    lda  #1
	sec
    bcs +++
    + ; 5
    lda  #-1
    sec
    bcs ++
    + ; 6
    lda #0
    + ; 7

    }}
    }

    inline asmsub set(uword fptr @R0, uword valuePointer @R1) clobbers (Y) {
    %asm {{     
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
    lda (cx16.r1),Y   
    sta (cx16.r2),Y    
    iny    
    lda (cx16.r1),Y    
    sta (cx16.r2),Y
    iny    
    lda (cx16.r1),Y    
    sta (cx16.r2),Y
    }}
    }    

    inline asmsub get(uword fptr @R0, uword valuePointer @R1) clobbers (Y) {
    %asm {{     
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
    }}        
    }   

    inline asmsub memcopy_in(uword fptr @R0, uword valuePointer @R1, ubyte count @X) clobbers (Y) {
    %asm {{     
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
    -                        
    lda (cx16.r1),y   
    sta (cx16.r2),y    
    iny    
    dex
    bne -

    }}
    }   

    inline asmsub memcopy_out(uword fptr @R0, uword valuePointer @R1, ubyte count @X) clobbers (Y) {
    %asm {{     
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
    -                    
    lda (cx16.r2),y 
    sta (cx16.r1),y    
    iny    
    dex
    bne -

    }}
    }   

}