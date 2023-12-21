%import fstruct
%import fmalloc
%import linkedlist_item_h
%import linkedlist

; Queue is a special case of linked list
queue {

    sub init(uword heap, ubyte[3] root) {
        linkedlist.init(heap, root)
    }

    sub q_push(uword heap, ubyte[3] root, uword data) {
        ubyte[fptr.SIZEOF_FPTR] result
        linkedlist.add_first(heap, root, data, result)
    }

    sub q_pop(uword heap, ubyte[3] root, ubyte[fptr.SIZEOF_FPTR] result) {
        ubyte[fptr.SIZEOF_FPTR] pListItem
        linkedlist.first(root, pListItem)
        if fptr.isnull(pListItem) {
            result[0] = 0;
            result[1] = 0;
            result[2] = 0;
        } else {
            linkedlist_item.data_get(pListItem, result)        
            linkedlist.remove(heap, root, pListItem)
        }
    }

    sub q_peek(ubyte[3] root, ubyte[fptr.SIZEOF_FPTR] result) {
        ubyte[fptr.SIZEOF_FPTR] pListItem
        linkedlist.first(root, pListItem)
        if fptr.isnull(pListItem) {
            result[0] = 0;
            result[1] = 0;
            result[2] = 0;
        } else {
            linkedlist_item.data_get(pListItem, result)        
        }
    }

    sub free(uword heap, ubyte[3] root) {
        linkedlist.free(heap, root)
    }
}