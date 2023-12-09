%import fstruct
%import fmalloc

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

linkedlist_root {
    const ubyte LINKED_LIST_ROOT_SIZEOF = 6;    
    const ubyte LINKED_LIST_ROOT_head   = $00; ubyte[fptr.SIZEOF_FPTR]    
    const ubyte LINKED_LIST_ROOT_tail   = $03; ubyte[fptr.SIZEOF_FPTR]    

    sub head_get(ubyte[3] ptr, ubyte[3] result) {        
        fstruct.get(ptr, LINKED_LIST_ROOT_head, fptr.SIZEOF_FPTR, result);        
    }

    sub head_set(ubyte[3] ptr, ubyte[3] value) {
        fstruct.set(ptr, LINKED_LIST_ROOT_head, fptr.SIZEOF_FPTR, value);
    }

    sub tail_get(ubyte[3] ptr, ubyte[3] result) {        
        fstruct.get(ptr, LINKED_LIST_ROOT_tail, fptr.SIZEOF_FPTR, result);
    }

    sub tail_set(ubyte[3] ptr, ubyte[3] value) {
        fstruct.set(ptr, LINKED_LIST_ROOT_tail, fptr.SIZEOF_FPTR, value);
    }    

}

linkedlist {

    sub init(uword heap, ubyte[3] root) {  
        fmalloc.malloc(heap, linkedlist_root.LINKED_LIST_ROOT_SIZEOF, root);      
        linkedlist_root.head_set(root, &fptr.NULL);
        linkedlist_root.tail_set(root, &fptr.NULL);
    }

    sub add_first(uword heap, ubyte[3] root, uword data, ubyte[fptr.SIZEOF_FPTR] result) {

        ubyte[fptr.SIZEOF_FPTR] pNew;
        ubyte[fptr.SIZEOF_FPTR] pHead;
        ubyte[fptr.SIZEOF_FPTR] pTail;

        ; Create the new object
        fmalloc.malloc(heap, linkedlist_item.LINKED_LIST_ITEM_SIZEOF, pNew);        

        ; Set it's data pointer
        linkedlist_item.data_set(&pNew, data);

        ; pNew->prev = NULL, always, it's the first node
        linkedlist_item.prev_set(&pNew, &fptr.NULL);
        
        ; Is this the tail?        
        linkedlist_root.tail_get(root, &pTail);        
        if fptr.isnull(&pTail) {

            ; Tail
            linkedlist_root.tail_set(root, &pNew);            

            ; Set pNew->next = NULL
            linkedlist_item.next_set(&pNew, &fptr.NULL);

        } else {

            ; Get the head node
            linkedlist_root.head_get(root, &pHead);

            ; Set pHead->prev = pNew
            linkedlist_item.prev_set(&pHead, &pNew);

            ; Set pNew->next = pHead;
            linkedlist_item.next_set(&pNew, &pHead);            

        }

        ; The new node becomes the new head
        linkedlist_root.head_set(root, &pNew);

        ; Return the result        
        result[0] = pNew[0];
        result[1] = pNew[1];
        result[2] = pNew[2];
        
    }

    sub add_last(uword heap, ubyte[3] root, uword data, ubyte[fptr.SIZEOF_FPTR] result)  {

        ubyte[fptr.SIZEOF_FPTR] pNew;
        ubyte[fptr.SIZEOF_FPTR] pHead;
        ubyte[fptr.SIZEOF_FPTR] pTail;

        ; Create the new object
        fmalloc.malloc(heap, linkedlist_item.LINKED_LIST_ITEM_SIZEOF, pNew);        

        ; Set it's data pointer
        linkedlist_item.data_set(&pNew, data);

        ; pNew->next = NULL, always, it's the last node
        linkedlist_item.next_set(&pNew, &fptr.NULL);
        
        ; Is this the head?        
        linkedlist_root.head_get(root, &pHead);        
        if fptr.isnull(&pHead) {

            ; Head
            linkedlist_root.head_set(root, &pNew);            

            ; Set pNew->prev = NULL
            linkedlist_item.prev_set(&pNew, &fptr.NULL);

        } else {

            ; Get the tail node
            linkedlist_root.tail_get(root, &pTail);

            ; Set pTail->next = pNew
            linkedlist_item.next_set(&pTail, &pNew);

            ; Set pNew->prev = pTail;
            linkedlist_item.prev_set(&pNew, &pTail);            

        }

        ; The new node becomes the new tail
        linkedlist_root.tail_set(root, &pNew);

        ; Return the result        
        result[0] = pNew[0];
        result[1] = pNew[1];
        result[2] = pNew[2];

    }

    sub add_before(uword heap, ubyte[fptr.SIZEOF_FPTR] ptr, uword root, uword data, ubyte[fptr.SIZEOF_FPTR] result) {

        ubyte[fptr.SIZEOF_FPTR] pNew;        
        ubyte[fptr.SIZEOF_FPTR] pHead;
        ubyte[fptr.SIZEOF_FPTR] pTail;
        
        ;  If the thing you're adding before is the head just call add first
        linkedlist_root.head_get(root, &pHead);        
        if (fptr.isnull(&pHead)) or (fptr.equal(&ptr, &pHead)) {
            add_first(heap, root, data, &pNew);
        }
        else {

            ; Create the new object
            fmalloc.malloc(heap, linkedlist_item.LINKED_LIST_ITEM_SIZEOF, pNew);        

            ; Set it's data pointer
            linkedlist_item.data_set(&pNew, data);

            ; pNew->Next = ptr
            ; pNew->Prev = ptr->Prev
            ; ptr->Prev = pNew

        }

        ; Return the result        
        result[0] = pNew[0];
        result[1] = pNew[1];
        result[2] = pNew[2];
        
    }

    sub add_after(uword heap, ubyte[fptr.SIZEOF_FPTR] ptr, uword root, uword data, ubyte[fptr.SIZEOF_FPTR] result) {

        ubyte[fptr.SIZEOF_FPTR] pNew;        
        ubyte[fptr.SIZEOF_FPTR] pHead;
        ubyte[fptr.SIZEOF_FPTR] pTail;
        
        ;  If the thing you're adding after is the tail just call add last
        linkedlist_root.head_get(root, &pTail);        
        if (fptr.isnull(&pTail)) or (fptr.equal(&ptr, &pTail)) {
            add_last(heap, root, data, &pNew);
        }
        else {

            ; Create the new object
            fmalloc.malloc(heap, linkedlist_item.LINKED_LIST_ITEM_SIZEOF, pNew);        

            ; Set it's data pointer
            linkedlist_item.data_set(&pNew, data);

            ; pNew->Prev = ptr
            ; pNew->Next = ptr->Next
            ; ptr->Next = pNew

            ; if ptr == pTail then pTail = pNew

        }

        ; Return the result        
        result[0] = pNew[0];
        result[1] = pNew[1];
        result[2] = pNew[2];

    }

    sub first(ubyte[3] root, ubyte[fptr.SIZEOF_FPTR] result) {        
        ubyte[fptr.SIZEOF_FPTR] pTemp;
        linkedlist_root.head_get(root, &pTemp);         
        result[0] = pTemp[0];
        result[1] = pTemp[1];
        result[2] = pTemp[2];
    }

    sub last(ubyte[3] root, ubyte[fptr.SIZEOF_FPTR] result) {        
        ubyte[fptr.SIZEOF_FPTR] pTemp;
        linkedlist_root.tail_get(root, &pTemp);         
        result[0] = pTemp[0];
        result[1] = pTemp[1];
        result[2] = pTemp[2];
    }    

    sub next(ubyte[fptr.SIZEOF_FPTR] current, ubyte[fptr.SIZEOF_FPTR] result) {
        ubyte[fptr.SIZEOF_FPTR] pTemp;
        linkedlist_item.next_get(current, pTemp);
        result[0] = pTemp[0];
        result[1] = pTemp[1];
        result[2] = pTemp[2];
    }

    sub prev(ubyte[fptr.SIZEOF_FPTR] current, ubyte[fptr.SIZEOF_FPTR] result) {
        ubyte[fptr.SIZEOF_FPTR] pTemp;
        linkedlist_item.prev_get(current, pTemp);
        result[0] = pTemp[0];
        result[1] = pTemp[1];
        result[2] = pTemp[2];
    }    

    sub free(uword heap, ubyte[3] root) {

        ; Free each item

        ; Free each item data

        ; Free the linked list
        fmalloc.free(heap, root);      
    }

}