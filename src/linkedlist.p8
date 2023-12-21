%import fstruct
%import fmalloc
%import linkedlist_item_h

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

    sub remove(uword heap, ubyte[3] root, ubyte[3] ptr) {

        ; Disconnect the node from the list
        internal_remove(heap, root, ptr)

        ; Free the node
        fmalloc.free(heap, ptr)
    }

    sub internal_remove(uword heap, ubyte[3] root, ubyte[3] ptr) {

        ubyte[fptr.SIZEOF_FPTR] pNext;
        ubyte[fptr.SIZEOF_FPTR] pPrev;        
        bool prevIsNull;
        bool nextIsNull

        ; Get the previous and next nodes
        linkedlist_item.next_get(ptr, pNext);
        linkedlist_item.prev_get(ptr, pPrev);

        ; Check them for null
        nextIsNull = fptr.isnull(pNext)
        prevIsNull = fptr.isnull(pPrev)

        ; We're the only node
        if prevIsNull and nextIsNull {

            ; Head -> null
            linkedlist_root.head_set(root, &fptr.NULL);

            ; Tail -> null
            linkedlist_root.tail_set(root, &fptr.NULL);            

        ; We're the first node
        } else if prevIsNull {

            ; Head -> pNext
            linkedlist_root.head_set(root, pNext);

            ; pNext.prev -> null
            linkedlist_item.prev_set(pNext, &fptr.NULL);            

        ; We're the last node
        } else if nextIsNull {

            ; Tail -> pPrev
            linkedlist_root.tail_set(root, pPrev);

            ; pPrev.next -> null
            linkedlist_item.next_set(pPrev, &fptr.NULL);            

        ; We're somewhere in the middle
        } else {

            ; pNext.prev -> pPrev
            linkedlist_item.prev_set(pNext, pPrev);

            ; pPrev.next -> pNext
            linkedlist_item.next_set(pPrev, pNext);            
        }
                
    }

    sub moveup(uword heap, ubyte[3] root, ubyte[3] ptr) {
        ; Remember ptr.prev
        ; Detach the node
        ; If ptr.prev is null
            ; Move to top
        ; Otherwise 
            ; Insert before ptr.prev.prev
    }

    sub movedown(uword heap, ubyte[3] root, ubyte[3] ptr) {
        ; Remember ptr.next
        ; Detach the node
        ; If ptr.next.next is null
            ; Move to bottom
        ; Otherwise 
            ; Insert after ptr.next
    }

    sub movetop(uword heap, ubyte[3] root, ubyte[3] ptr) {

        ubyte[3] pHead;
        
        ; Detach the node
        internal_remove(heap, root, ptr)

        ; Get the head
        linkedlist_root.head_get(root, pHead);
        
        ; ptr.next -> head
        linkedlist_item.next_set(ptr, pHead);   

        ; pHead.prev -> ptr    
        linkedlist_item.prev_set(pHead, ptr);       
        
        ; ptr.prev -> null
        linkedlist_item.prev_set(ptr, &fptr.NULL);       
        
        ; head -> ptr
        linkedlist_root.head_set(root, ptr);
    }

    sub movebottom(uword heap, ubyte[3] root, ubyte[3] ptr) {

        ubyte[3] pTail;
        
        ; Detach the node
        internal_remove(heap, root, ptr)

        ; Get the tail
        linkedlist_root.tail_get(root, pTail);
        
        ; ptr.prev -> tail
        linkedlist_item.prev_set(ptr, pTail);   

        ; pTail.next -> ptr    
        linkedlist_item.next_set(pTail, ptr);       
        
        ; ptr.next -> null
        linkedlist_item.next_set(ptr, &fptr.NULL);       
        
        ; tail -> ptr
        linkedlist_root.tail_set(root, ptr);

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
        ubyte[fptr.SIZEOF_FPTR] ptr1;
        ubyte[fptr.SIZEOF_FPTR] ptr2;
        ubyte[fptr.SIZEOF_FPTR] pData
                           
        linkedlist.first(root, ptr1);
        while fptr.isnull(ptr1) != true {            

            ; Free each item data            
            linkedlist_item.data_get(ptr1, pData);
            fmalloc.free(heap, pData)
                        
            ; Next item            
            ptr2 = ptr1            
            linkedlist.next(ptr1, ptr1);

            ; Free each item                    
            fmalloc.free(heap, ptr2)
        }   

        ; Free the linked list              
        fmalloc.free(heap, root);      
    }

}