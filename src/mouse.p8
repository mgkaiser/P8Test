mouse {
    romsub $ff68 = mouse_config(ubyte enabled @A, ubyte x @X, ubyte y @Y) clobbers(A, X, Y) 
    romsub $ff71 = mouse_scan() clobbers(A, X, Y)
    romsub $ff6b = mouse_get(ubyte pMouseData @X) clobbers (X, Y) -> ubyte @A
}