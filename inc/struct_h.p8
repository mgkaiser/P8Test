struct {
    romsub $0400 = set(uword pointer @R0, ubyte offset @R2, ubyte count @X, uword valuePointer @R1)    
    romsub $0403 = get(uword pointer @R0, ubyte offset @R2, ubyte count @X, uword valuePointer @R1)     
    romsub $0406 = set_w(uword pointer @R0, ubyte offset @Y, uword valuePointer @R1) 
    romsub $0408 = set_wi(uword pointer @R0, ubyte offset @Y, uword value @R1)     
    romsub $040c = get_w(uword pointer @R0, ubyte offset @Y, uword valuePointer @R1)     
}

ptr {
    romsub $0410 = set_w(uword pointer @R0, uword valuePointer @R1) clobbers (X)
    romsub $0413 = get_w(uword pointer @R0, uword valuePointer @R1)
}