struct {

    asmsub set(uword pointer @R0, ubyte offset @R2, ubyte count @X, uword valuePointer @R1) {
    %asm {{           
    - 
    ldy cx16.r2H
    lda(cx16.r1),y
    ldy cx16.r2L
    sta(cx16.r0),y    
    inc cx16.r2L
    inc cx16.r2H
    dex
    bne -
    }}
    }

    asmsub get(uword pointer @R0, ubyte offset @R2, ubyte count @X, uword valuePointer @R1) {
    %asm {{         
    - 
    ldy cx16.r2L
    lda(cx16.r0),y
    ldy cx16.r2H
    sta(cx16.r1),y    
    inc cx16.r2L
    inc cx16.r2H
    dex
    bne -
    }}        
    }    


    asmsub set_w(uword pointer @R0, ubyte offset @Y, uword valuePointer @R1) {
    %asm {{   
    phy 
    ldy #$00
    lda(cx16.r1),y
    ply
    sta(cx16.r0),y    
    iny
    phy
    ldy #$01    
    lda(cx16.r1),y
    ply
    sta(cx16.r0),y
    }}
    }

    asmsub set_wi(uword pointer @R0, ubyte offset @Y, uword value @R1) {
    %asm {{   
    lda cx16.r1
    sta(cx16.r0),y
    iny
    lda cx16.r1 + 1
    sta(cx16.r0),y
    }}
    }    

    asmsub get_w(uword pointer @R0, ubyte offset @Y, uword valuePointer @R1) {
    %asm {{                    
    lda(cx16.r0),y        
    phy
    ldy #$00
    sta(cx16.r1),y
    ply
    iny
    lda(cx16.r0),y        
    ldy #$01
    sta(cx16.r1),y
    }}        
    }    
}

ptr {

    const uword NULL = $0000;

    asmsub set_w(uword pointer @R0, uword valuePointer @R1) clobbers (X) {
    %asm {{       
    ldy #$00
    lda(cx16.r1),y    
    sta(cx16.r0),y    
    iny    
    lda(cx16.r1),y    
    sta(cx16.r0),y
    }}
    }    

    asmsub get_w(uword pointer @R0, uword valuePointer @R1) {
    %asm {{                    
    ldy #$00
    lda(cx16.r0),y                
    sta(cx16.r1),y    
    iny
    lda(cx16.r0),y            
    sta(cx16.r1),y
    }}        
    }    

}