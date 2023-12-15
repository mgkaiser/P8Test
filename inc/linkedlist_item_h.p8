linkedlist_item {
    const ubyte LINKED_LIST_ITEM_SIZEOF         = $0a;    
    const ubyte LINKED_LIST_ITEM_next           = $00; ubyte[fptr.SIZEOF_FPTR]    
    const ubyte LINKED_LIST_ITEM_prev           = $03; ubyte[fptr.SIZEOF_FPTR]
    const ubyte LINKED_LIST_ITEM_data           = $06; ubyte[fptr.SIZEOF_FPTR]
    
    sub next_get(ubyte[3] ptr, uword result) {        
        fstruct.get(ptr, LINKED_LIST_ITEM_next, fptr.SIZEOF_FPTR, result);
    }

    sub next_set(ubyte[3] ptr, uword value) {
        fstruct.set(ptr, LINKED_LIST_ITEM_next, fptr.SIZEOF_FPTR, value);
    }

    sub prev_get(ubyte[3] ptr, uword result) {        
        fstruct.get(ptr, LINKED_LIST_ITEM_prev, fptr.SIZEOF_FPTR, result);
    }

    sub prev_set(ubyte[3] ptr, uword value) {
        fstruct.set(ptr, LINKED_LIST_ITEM_prev, fptr.SIZEOF_FPTR, value);
    }

    sub data_get(ubyte[3] ptr, uword result) {     
        fstruct.get(ptr, LINKED_LIST_ITEM_data, fptr.SIZEOF_FPTR, result);
    }

    sub data_set(ubyte[3] ptr, uword value) {
        fstruct.set(ptr, LINKED_LIST_ITEM_data, fptr.SIZEOF_FPTR, value);
    }

}