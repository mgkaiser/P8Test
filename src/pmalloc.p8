%import struct
%import textio

pmalloc {
    const ubyte SIZEOF_PMALLOC_ITEM = $06;
    const ubyte PMALLOC_ITEM_prev   = $00; uword
    const ubyte PMALLOC_ITEM_next   = $02; uword
    const ubyte PMALLOC_ITEM_size   = $04; uword

    const ubyte SIZEOF_PMALLOC      = $0a;
    const ubyte PMALLOC_available   = $00; uword
    const ubyte PMALLOC_assigned    = $02; uword
    const ubyte PMALLOC_freemem     = $04; uword
    const ubyte PMALLOC_totalmem    = $06; uword
    const ubyte PMALLOC_totalnodes  = $08; uword

    sub init(uword pm) {               
        struct.set_wi(pm, PMALLOC_available, ptr.NULL);
        struct.set_wi(pm, PMALLOC_assigned, ptr.NULL);
        struct.set_wi(pm, PMALLOC_freemem, 0);
        struct.set_wi(pm, PMALLOC_totalmem, 0);
        struct.set_wi(pm, PMALLOC_totalnodes, 0);        
    }

    ; DO NOT ADD THE SAME BLOCK MORE THAN ONCE!!!!
    sub addblock(uword pm, uword ptr, uword size) {        

        ; Get the usable size of the block
        uword usableSize = size - SIZEOF_PMALLOC_ITEM;
        struct.set_w(ptr, PMALLOC_ITEM_size, &usableSize);

        ; Update freemem and totalmem
        uword freemem;
        struct.get_w(pm, PMALLOC_freemem, &freemem);
        freemem = freemem + usableSize;
        struct.set_w(pm, PMALLOC_freemem, &freemem);

        uword totalmem;
        struct.get_w(pm, PMALLOC_totalmem, &totalmem);
        totalmem = totalmem + usableSize;
        struct.set_w(pm, PMALLOC_totalmem, &totalmem);        

        ; Add it to the available heap
        insert_item(pm + PMALLOC_available, ptr);        

        ; update totalnodes        
        uword totalnodes;
        struct.get_w(pm, PMALLOC_totalnodes, &totalnodes);
        totalnodes++;
        struct.set_w(pm, PMALLOC_totalnodes, &totalnodes);        
        
    }

    sub malloc(uword pm, uword size) -> uword {
        uword current;                
        uword current_size;
        uword freemem;

        ; Find a suitable block
        struct.get_w(pm, PMALLOC_available, &current);
        struct.get_w(current, PMALLOC_ITEM_size, &current_size);
        while (current != ptr.NULL) and (current_size < size) {
            struct.get_w(current, PMALLOC_ITEM_next, &current);
            struct.get_w(current, PMALLOC_ITEM_size, &current_size);
        }

        ; If there's nothing suitable, we're either out of memory or fragged.
        if current == ptr.NULL return ptr.NULL;

        ; Remove it from pm->available
	    remove_item(pm + PMALLOC_available, current);

	    ; Add to pm->assigned
	    insert_item(pm + PMALLOC_assigned, current);

        ; If it's not the exact size..
        if current_size != size {

            ; Add a free block that's the remainder size
            uword newfree = current + SIZEOF_PMALLOC_ITEM + size;
            struct.set_wi(newfree, PMALLOC_ITEM_size, current_size - SIZEOF_PMALLOC_ITEM - size);
            uword current_next;
            struct.get_w(current, PMALLOC_ITEM_next, &current_next);
            struct.set_w(newfree, PMALLOC_ITEM_next, &current_next);
            struct.set_wi(current, PMALLOC_ITEM_next, ptr.NULL);

            ; Change pm->assigned size
            current_size = size;
            struct.set_w(current, PMALLOC_ITEM_size, &current_size);
            insert_item(pm + PMALLOC_available, newfree);

            ; We've lost a bit of overhead making the new node                    
            struct.get_w(pm, PMALLOC_freemem, &freemem);
            freemem = freemem - SIZEOF_PMALLOC_ITEM;
            struct.set_w(pm, PMALLOC_freemem, &freemem);

            ; update totalnodes        
            uword totalnodes;
            struct.get_w(pm, PMALLOC_totalnodes, &totalnodes);
            totalnodes++;
            struct.set_w(pm, PMALLOC_totalnodes, &totalnodes);

            ; Merge around newfree
		    merge(pm, newfree);
        }

        ; Reduce the amount of free memory        
        struct.get_w(pm, PMALLOC_freemem, &freemem);
        freemem = freemem - current_size;
        struct.set_w(pm, PMALLOC_freemem, &freemem);

        ; Return the pointer to the user
        return current + SIZEOF_PMALLOC_ITEM;
    }

    sub free(uword pm, uword ptr)
    {
        ; Match stdlib free() NULL interface
        if ptr == ptr.NULL return;

        ; Get the node of this memory
        uword node = ptr - SIZEOF_PMALLOC_ITEM;

        ; Remove it from pm->assigned
        remove_item(pm + PMALLOC_assigned, node);	

        uword freemem;
        uword node_size;
        struct.get_w(pm, PMALLOC_freemem, &freemem);
        struct.get_w(node, PMALLOC_ITEM_size, &node_size);
	    freemem = freemem + node_size;
        struct.set_w(pm, PMALLOC_freemem, &freemem);

        ; Add to pm->available
        insert_item(pm + PMALLOC_available, node);

        ; Merge around current
        merge(pm, node);
    }

    sub merge(uword pm, uword node) {
        uword node_prev;
        uword node_prev_size;
        uword node_next;
        uword node_size;

        struct.get_w(node, PMALLOC_ITEM_prev, &node_prev);
        struct.get_w(node_prev, PMALLOC_ITEM_size, &node_prev_size);
        while (node_prev != ptr.NULL) and (node != node_prev + SIZEOF_PMALLOC_ITEM + node_prev_size) {
            node = node_prev;
            struct.get_w(node, PMALLOC_ITEM_prev, &node_prev);
            struct.get_w(node_prev, PMALLOC_ITEM_size, &node_prev_size);
        }

        struct.get_w(node, PMALLOC_ITEM_next, &node_next);
        struct.get_w(node, PMALLOC_ITEM_size, &node_size);
        while node_next == node + SIZEOF_PMALLOC_ITEM + node_size {
            uword node_next_size;
            struct.get_w(node_next, PMALLOC_ITEM_size, &node_next_size)
            uword temp_node_size = node_next_size + SIZEOF_PMALLOC_ITEM

            uword freemem;
            struct.get_w(pm, PMALLOC_freemem, &freemem);
            freemem = freemem + SIZEOF_PMALLOC_ITEM;
            struct.set_w(pm, PMALLOC_freemem, &freemem);

            remove_item(pm + PMALLOC_available, node_next);

            uword totalnodes;
            struct.get_w(pm, PMALLOC_totalnodes, &totalnodes);
            totalnodes--;
            struct.set_w(pm, PMALLOC_totalnodes, &totalnodes);

            node_size = node_size + temp_node_size
            struct.set_w(node, PMALLOC_ITEM_size, &node_size);               

            struct.get_w(node, PMALLOC_ITEM_next, &node_next);         
        }


    }

    ; root = **root
    sub insert_item(uword root, uword node) {        
        uword xRoot;
        ptr.get_w(root, &xRoot);

        ; There is no root
        if xRoot == ptr.NULL {
            xRoot = node;                        
            struct.set_wi(node, PMALLOC_ITEM_prev, ptr.NULL);
            struct.set_wi(node, PMALLOC_ITEM_next, ptr.NULL);                        
            ptr.set_w(root, &xRoot);
            return;
        }        

        ; New block is before root
        if node < xRoot {          
            uword oldroot = xRoot;
            struct.set_w(oldroot, PMALLOC_ITEM_prev, &node);
            struct.set_w(node, PMALLOC_ITEM_next, &oldroot);
            struct.set_wi(node, PMALLOC_ITEM_prev, ptr.NULL);
            xRoot = node;
            ptr.set_w(root, &xRoot);
        } else {            
            uword current = xRoot;
            uword current_next;

            ; Figure out where the new block belongs
            struct.get_w(current, PMALLOC_ITEM_next, &current_next);            
            while (current_next != ptr.NULL) and (node > current_next) {
                current = current_next;
                struct.get_w(current, PMALLOC_ITEM_next, &current_next);
            }

            ; New block is at the end of the list
            if current_next == ptr.NULL {                
                struct.set_w(node, PMALLOC_ITEM_prev, &current);
                struct.set_wi(node, PMALLOC_ITEM_next, ptr.NULL);
                struct.set_w(current, PMALLOC_ITEM_next, &node);

            ; New block is in the middle of the list
            } else {                
                uword oldnext;
                struct.get_w(current, PMALLOC_ITEM_next, &oldnext);
                struct.set_w(current, PMALLOC_ITEM_next, &node);
                struct.set_w(node, PMALLOC_ITEM_prev, &current);
                struct.set_w(node, PMALLOC_ITEM_next, &oldnext);
                struct.set_w(oldnext, PMALLOC_ITEM_prev, &node);
            }
        }        
    }

    ; root = **root
    sub remove_item(uword root, uword node) {        
        uword node_prev;
        uword node_next;
        uword xRoot;        

        struct.get_w(node, PMALLOC_ITEM_next, &node_next);
        struct.get_w(node, PMALLOC_ITEM_prev, &node_prev);
        ptr.get_w(root, &xRoot);

        ; Remove the node
        if node_prev != ptr.NULL struct.set_w(node_prev, PMALLOC_ITEM_next, &node_next);                
        if node_next != ptr.NULL struct.set_w(node_next, PMALLOC_ITEM_prev, &node_prev);                

        ; Fixup root if the node was root
        if (node == xRoot) {
            if node_prev != ptr.NULL {
                xRoot = node_prev
            } else {
                xRoot = node_next
            }
            ptr.set_w(root, &xRoot);
        }

        ; Clear the next and previous pointers
        struct.set_wi(node, PMALLOC_ITEM_next, ptr.NULL);
        struct.set_wi(node, PMALLOC_ITEM_prev, ptr.NULL);
    }
}
