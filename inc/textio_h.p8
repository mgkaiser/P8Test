txt {    
    romsub $07e0 = print(str string @AY) clobbers(A,Y)   
    romsub $07e3 = print_uw(uword value @AY) clobbers(A,Y)
    romsub $07e6 = print_uwhex(uword value @AY, bool prefix @Pc) clobbers(A,Y) 
    romsub $07e9 = print_ub  (ubyte value @ A) clobbers(A,X,Y)
    romsub $07ec = print_ubhex  (ubyte value @ A, bool prefix @ Pc) clobbers(A,X,Y)    
    romsub $07ef = column(ubyte col @A) clobbers(A, X, Y)     
    romsub $07f2 = get_column() -> ubyte @Y 
    romsub $07f5 = row(ubyte rownum @A) clobbers(A, X, Y) 
    romsub $07f8 = get_row() -> ubyte @X
    romsub $ffd2 = chrout(ubyte character @ A)
}