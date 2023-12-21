%import fstruct
%import fmalloc
%import linkedlist_item_h
%import linkedlist

; Queue is a special case of linked list
queue {

    sub init(uword heap, ubyte[3] root) {
        linkedlist.init(heap, root)
    }

    sub push(uword heap, ubyte[3] root, uword data, ubyte[fptr.SIZEOF_FPTR] result) {
        linkedlist.add_first(heap, root, data, result)
    }

    sub pop(uword heap, ubyte[3] root, ubyte[fptr.SIZEOF_FPTR] result) {
        ubyte[fptr.SIZEOF_FPTR] pListItem
        linkedlist.first(root, pListItem)
        linkedlist_item.data_get(pListItem, result)        
        linkedlist.remove(heap, root, ubyte[3] pListItem)
    }

    sub peek(ubyte[3] root, ubyte[fptr.SIZEOF_FPTR] result) {
        ubyte[fptr.SIZEOF_FPTR] pListItem
        linkedlist.first(root, pListItem)
        linkedlist_item.data_get(pListItem, result)        
    }
}