fstruct {
    romsub $0420 = set_zfp(uword pointer @R0, ubyte offset @R2) 
    romsub $0423 = set(uword pointer @R0, ubyte offset @R2, ubyte count @X, uword valuePointer @R1) 
    romsub $0426 = get(uword pointer @R0, ubyte offset @R2, ubyte count @X, uword valuePointer @R1) 
    romsub $0429 = set_w(uword fptr @R0, ubyte offset @Y, uword valuePointer @R1)
    romsub $042c = set_wi(uword fptr @R0, ubyte offset @Y, uword valuePointer @R1) 
    romsub $042f = get_w(uword fptr @R0, ubyte offset @Y, uword valuePointer @R1)
}

fptr {
    const ubyte SIZEOF_FPTR = 3;
    byte[] NULL = [0,0,0];
      
    romsub $0432 = set(uword fptr @R0, uword valuePointer @R1) clobbers (Y)  
    romsub $0435 = get(uword fptr @R0, uword valuePointer @R1) clobbers (Y)   
    romsub $0438 = memcopy_in(uword fptr @R0, uword valuePointer @R1, ubyte count @X) clobbers (Y)
    romsub $043a = memcopy_out(uword fptr @R0, uword valuePointer @R1, ubyte count @X) clobbers (Y) 
}