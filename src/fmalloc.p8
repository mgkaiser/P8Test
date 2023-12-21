%import struct
%import fstruct

fmalloc_root {
    
    const ubyte SIZEOF_FMALLOC      = $0c;
    const ubyte FMALLOC_available   = $00; ubyte[3]
    const ubyte FMALLOC_assigned    = $03; ubyte[3]
    const ubyte FMALLOC_freemem     = $06; uword
    const ubyte FMALLOC_totalmem    = $08; uword
    const ubyte FMALLOC_totalnodes  = $0a; uword  

    ; We need at least 24 bit addition to correctly reflect freemem and totalmem..... oops.
    ; Maybe also 24bit for nodes?  Can we really have more than 65535 nodes?  I think performance nosedives if we do  

    sub available_get(uword ptr, uword result) {        
        struct.get(ptr, FMALLOC_available, fptr.SIZEOF_FPTR, result);
    }

    sub available_set(uword ptr, uword value) {
        struct.set(ptr, FMALLOC_available, fptr.SIZEOF_FPTR, value);
    }

    ; Never used
    ;sub assigned_get(uword ptr, uword result) {        
    ;    struct.get(ptr, FMALLOC_assigned, fptr.SIZEOF_FPTR, result);
    ;}

    sub assigned_set(uword ptr, uword value) {
        struct.set(ptr, FMALLOC_assigned, fptr.SIZEOF_FPTR, value);
    }

    sub freemem_get(uword ptr, uword result) {        
        struct.get_w(ptr, FMALLOC_freemem, result);
    }

    sub freemem_set(uword ptr, uword value) {
        struct.set_w(ptr, FMALLOC_freemem, value);
    }

    sub freemem_set_wi(uword ptr, uword value) {
        struct.set_wi(ptr, FMALLOC_freemem, value);
    }

    sub totalmem_get(uword ptr, uword result) {        
        struct.get_w(ptr, FMALLOC_totalmem, result);
    }

    sub totalmem_set(uword ptr, uword value) {
        struct.set_w(ptr, FMALLOC_totalmem, value);
    }

    sub totalmem_set_wi(uword ptr, uword value) {
        struct.set_wi(ptr, FMALLOC_totalmem, value);
    }

    sub totalnodes_get(uword ptr, uword result) {        
        struct.get_w(ptr, FMALLOC_totalnodes, result);
    }

    sub totalnodes_set(uword ptr, uword value) {
        struct.set_w(ptr, FMALLOC_totalnodes, value);
    }

    sub totalnodes_set_wi(uword ptr, uword value) {
        struct.set_wi(ptr, FMALLOC_totalnodes, value);
    }    

}

fmalloc_item {
    const ubyte SIZEOF_FMALLOC_ITEM = $08;
    const ubyte FMALLOC_ITEM_prev   = $00; ubyte[3]
    const ubyte FMALLOC_ITEM_next   = $03; ubyte[3]
    const ubyte FMALLOC_ITEM_size   = $06; uword

    sub next_get(ubyte[3] ptr, uword result) {        
        fstruct.get(ptr, FMALLOC_ITEM_next, fptr.SIZEOF_FPTR, result);
    }

    sub next_set(ubyte[3] ptr, uword value) {
        fstruct.set(ptr, FMALLOC_ITEM_next, fptr.SIZEOF_FPTR, value);
    }

    sub prev_get(ubyte[3] ptr, uword result) {        
        fstruct.get(ptr, FMALLOC_ITEM_prev, fptr.SIZEOF_FPTR, result);
    }

    sub prev_set(ubyte[3] ptr, uword value) {
        fstruct.set(ptr, FMALLOC_ITEM_prev, fptr.SIZEOF_FPTR, value);
    }

    sub size_get(ubyte[3] ptr, uword result) {        
        fstruct.get_w(ptr, FMALLOC_ITEM_size, result);
    }

    sub size_set(ubyte[3] ptr, uword value) {
        fstruct.set_w(ptr, FMALLOC_ITEM_size, value);
    }

    ; Never used
    ;sub size_set_wi(ubyte[3] ptr, uword value) {
    ;    fstruct.set_wi(ptr, FMALLOC_ITEM_size, value);
    ;}    
}

fmalloc {        
    ;const ubyte FMALLOC_ITEM_next   = $03; ubyte[3]    
    
    sub init(uword pm) {        
        fmalloc_root.available_set(pm, &fptr.NULL);
        fmalloc_root.assigned_set(pm, &fptr.NULL);
        fmalloc_root.freemem_set_wi(pm, 0);
        fmalloc_root.totalmem_set_wi(pm, 0);
        fmalloc_root.totalnodes_set_wi(pm, 0);   
    }

    ; DO NOT ADD THE SAME BLOCK MORE THAN ONCE!!!!
    sub addblock(uword pm, ubyte[fptr.SIZEOF_FPTR] ptr, uword size) {     
        
        ; Get the usable size of the block
        uword usableSize = size - fmalloc_item.SIZEOF_FMALLOC_ITEM;
        fmalloc_item.size_set(ptr, &usableSize)        

        ; Update freemem and totalmem
        uword freemem;
        fmalloc_root.freemem_get(pm, &freemem);        
        freemem = freemem + usableSize;
        fmalloc_root.freemem_set(pm, &freemem);        

        uword totalmem;
        fmalloc_root.totalmem_get(pm, &totalmem);        
        totalmem = totalmem + usableSize;
        fmalloc_root.totalmem_set(pm, &totalmem);        

        ; Add it to the available heap
        insert_item(pm + fmalloc_root.FMALLOC_available, ptr);        

        ; update totalnodes        
        uword totalnodes;
        fmalloc_root.totalnodes_get(pm, &totalnodes);        
        totalnodes++;
        fmalloc_root.totalnodes_set(pm, &totalnodes);        

        ;dump_fmalloc(pm);    
        ;walkAvailableChain(pm);
    }   

    sub malloc(uword pm, uword size, ubyte[fptr.SIZEOF_FPTR] result)   {
        ubyte[fptr.SIZEOF_FPTR] current;                
        uword current_size;
        uword freemem;
        uword temp_result;

        ; Round the requested size up to the nearest multiple of 8
        size += fmalloc_item.SIZEOF_FMALLOC_ITEM        
        size = (size + 7) & -8;        
        size -= fmalloc_item.SIZEOF_FMALLOC_ITEM

        ; Find a suitable block
        fmalloc_root.available_get(pm, &current)                
        fmalloc_item.size_get(current, &current_size);                                
        while fptr.notequal(&current, &fptr.NULL) and (current_size < size) {            
            fmalloc_item.next_get(current, &current);
            fmalloc_item.size_get(current, &current_size);
        }
        
        ; If there's nothing suitable, we're either out of memory or fragged.
        if fptr.isnull(&current) {
            result[0] = 0;
            result[1] = 0;
            result[2] = 0;            
        }

        ; Remove it from pm->available	          
        remove_item(pm + fmalloc_root.FMALLOC_available, current);        

	    ; Add to pm->assigned	            
        insert_item(pm + fmalloc_root.FMALLOC_assigned, current);           
        
        ; If it's not the exact size..        
        if current_size != size {            

            ; Add a free block that's the remainder size
            ubyte[fptr.SIZEOF_FPTR] newfree;
            temp_result = mkword (current[2], current[1]) + fmalloc_item.SIZEOF_FMALLOC_ITEM + size;
            newfree[0] = current[0];
            newfree[1] = lsb(temp_result);
            newfree[2] = msb(temp_result);            
            uword new_size = current_size - fmalloc_item.SIZEOF_FMALLOC_ITEM - size;            
            fmalloc_item.size_set(newfree, &new_size)
            ubyte[fptr.SIZEOF_FPTR] current_next;            
            fmalloc_item.next_get(current, &current_next);            
            fmalloc_item.next_set(newfree, &current_next);
            fmalloc_item.next_set(current, &fptr.NULL);            

            ; Change pm->assigned size
            current_size = size;            
            fmalloc_item.size_set(current, &current_size);

            ; Put the new block back into the available list
            insert_item(pm + fmalloc_root.FMALLOC_available, newfree);

            ; We've lost a bit of overhead making the new node   
            fmalloc_root.freemem_get(pm, &freemem);            
            freemem = freemem - fmalloc_item.SIZEOF_FMALLOC_ITEM;
            fmalloc_root.freemem_set(pm, &freemem);            

            ; update totalnodes        
            uword totalnodes;
            fmalloc_root.totalnodes_get(pm, &totalnodes);            
            totalnodes++;
            fmalloc_root.totalnodes_set(pm, &totalnodes);            

            ; Merge around newfree
		    ;merge(pm, newfree);
        }

        ; Reduce the amount of free memory                
        fmalloc_root.freemem_get(pm, &freemem);            
        freemem = freemem - current_size;
        fmalloc_root.freemem_set(pm, &freemem);            

        ; Return the pointer to the user                
        temp_result = mkword (current[2], current[1]) + fmalloc_item.SIZEOF_FMALLOC_ITEM;
        
        result[0] = current[0];
        result[1] = lsb(temp_result);
        result[2] = msb(temp_result);                            
    }

    sub free(uword pm, ubyte[fptr.SIZEOF_FPTR] ptr)
    {
        ; Match stdlib free() NULL interface
        if fptr.isnull(&ptr) return;

        ; Get the node of this memory
        ubyte[fptr.SIZEOF_FPTR] node;
        uword temp_result = mkword (ptr[2], ptr[1]) - fmalloc_item.SIZEOF_FMALLOC_ITEM;
        node[0] = ptr[0];                
        node[1] = lsb(temp_result);
        node[2] = msb(temp_result);
        
        ; Remove it from pm->assigned
        remove_item(pm + fmalloc_root.FMALLOC_assigned, node);	

        uword freemem;
        uword node_size;        
        fmalloc_root.freemem_get(pm, &freemem);                    
        fmalloc_item.size_get(node, &node_size);
	    freemem = freemem + node_size;        
        fmalloc_root.freemem_set(pm, &freemem);            

        ; Add to pm->available
        insert_item(pm + fmalloc_root.FMALLOC_available, node);

        ; Merge around current
        merge(pm, node);
    }

    sub merge(uword pm, ubyte[fptr.SIZEOF_FPTR] node) {
        ubyte[fptr.SIZEOF_FPTR] node_prev;
        uword node_prev_size;
        ubyte[fptr.SIZEOF_FPTR] node_next;
        uword node_size;
        uword temp_result;
        ubyte[fptr.SIZEOF_FPTR] temp_ptr

        ; Scan backward for contiguous blocks        
        fmalloc_item.prev_get(node, &node_prev)  ;
        fmalloc_item.size_get(node_prev, &node_prev_size);
        temp_result = mkword (node_prev[2], node_prev[1]) + fmalloc_item.SIZEOF_FMALLOC_ITEM + node_prev_size;
        temp_ptr[0] = node_prev[0];
        temp_ptr[1] = lsb(temp_result);
        temp_ptr[2] = msb(temp_result);

        while (fptr.isnull(&node_prev) != true) and (fptr.notequal(&node, &temp_ptr)) {        
            node[0] = node_prev[0];
            node[1] = node_prev[1];
            node[2] = node_prev[2];                    
            fmalloc_item.prev_get(node, &node_prev)  ;
            fmalloc_item.size_get(node_prev, &node_prev_size);
            temp_result = mkword (node_prev[2], node_prev[1]) + fmalloc_item.SIZEOF_FMALLOC_ITEM + node_prev_size;
            temp_ptr[0] = node_prev[0];
            temp_ptr[1] = lsb(temp_result);
            temp_ptr[2] = msb(temp_result);
        }

        ; Scan forward and merge free blocks        
        fmalloc_item.next_get(node, &node_next);  
        fmalloc_item.size_get(node, &node_size);
        temp_result = mkword (node[2], node[1]) + fmalloc_item.SIZEOF_FMALLOC_ITEM + node_size;
        temp_ptr[0] = node[0];
        temp_ptr[1] = lsb(temp_result);
        temp_ptr[2] = msb(temp_result);

        while fptr.equal(&node_next, &temp_ptr) {                
            uword node_next_size;            
            fmalloc_item.size_get(node_next, &node_next_size);
            uword temp_node_size = node_next_size + fmalloc_item.SIZEOF_FMALLOC_ITEM

            uword freemem;            
            fmalloc_root.freemem_get(pm, &freemem);            
            freemem = freemem + fmalloc_item.SIZEOF_FMALLOC_ITEM;            
            fmalloc_root.freemem_set(pm, &freemem);            

            remove_item(pm + fmalloc_root.FMALLOC_available, node_next);

            uword totalnodes;            
            fmalloc_root.totalnodes_get(pm, &totalnodes); 
            totalnodes--;            
            fmalloc_root.totalnodes_set(pm, &totalnodes); 

            node_size = node_size + temp_node_size            
            fmalloc_item.size_set(node, &node_size);         
                    
            fmalloc_item.next_get(node, &node_next);                          
            fmalloc_item.size_get(node, &node_size);         
            temp_result = mkword (node[2], node[1]) + fmalloc_item.SIZEOF_FMALLOC_ITEM + node_size;
            temp_ptr[0] = node[0];
            temp_ptr[1] = lsb(temp_result);
            temp_ptr[2] = msb(temp_result);       
        }
    }

    ; root = **root
    sub insert_item(uword root, ubyte[fptr.SIZEOF_FPTR] node) {        
        ubyte[fptr.SIZEOF_FPTR] xRoot;
        struct.get(root, 0, fptr.SIZEOF_FPTR, &xRoot);            

        ; There is no root
        if fptr.isnull(&xRoot) {                        
            xRoot[0]=node[0];
            xRoot[1]=node[1];
            xRoot[2]=node[2];
            fmalloc_item.prev_set(node, &fptr.NULL);
            fmalloc_item.next_set(node, &fptr.NULL);            
            struct.set(root, 0, fptr.SIZEOF_FPTR, &xRoot);        
            return;
        }   
        
        ; New block is before root
        if fptr.compare(node, xRoot) == fptr.compare_less {  
            ubyte[fptr.SIZEOF_FPTR] oldroot;            
            oldroot=xRoot;            
            fmalloc_item.prev_set(oldroot, node);            
            fmalloc_item.next_set(node, &oldroot);                        
            fmalloc_item.prev_set(node, &fptr.NULL); 
            xRoot[0]=node[0];
            xRoot[1]=node[1];
            xRoot[2]=node[2];     
            ;xRoot = node;                     
            struct.set(root, 0, fptr.SIZEOF_FPTR, &xRoot);        
        } else {                  

            ubyte[fptr.SIZEOF_FPTR] current;
            ubyte[fptr.SIZEOF_FPTR] current_next;
                        
            current = xRoot;                   

            ; Figure out where the new block belongs            
            fmalloc_item.next_get(current, &current_next);                                                          
            
            while (fptr.isnull(&current_next) != true) and (fptr.compare(current_next,node) == fptr.compare_less) {                                                        
                current[0] = current_next[0]; 
                current[1] = current_next[1]; 
                current[2] = current_next[2];                                                       
                fmalloc_item.next_get(current, &current_next);                                                                                       
            }
            
            ; New block is at the end of the list
            if fptr.isnull(&current_next) {                                                    
                fmalloc_item.prev_set(node, &current);                                                  
                fmalloc_item.next_set(node, &fptr.NULL);    
                fmalloc_item.next_set(current, node);                                    
            ; New block is in the middle of the list
            } else {                                
                ubyte[fptr.SIZEOF_FPTR] oldnext;                
                fmalloc_item.next_get(current, &oldnext);                                                                                                  
                fmalloc_item.next_set(current, node);                                                                                  
                fmalloc_item.prev_set(node, &current);                                                                                  
                fmalloc_item.next_set(node, &oldnext);                                                                                  
                fmalloc_item.prev_set(oldnext, node);                                                                                                                          
            }
        }        
    } 

    ; root = **root
    sub remove_item(uword root, ubyte[fptr.SIZEOF_FPTR] node) {        
        ubyte[fptr.SIZEOF_FPTR] node_prev;
        ubyte[fptr.SIZEOF_FPTR] node_next;
        ubyte[fptr.SIZEOF_FPTR] xRoot;        
                
        fmalloc_item.next_get(node, &node_next);                                                                                                                          
        fmalloc_item.prev_get(node, &node_prev);                                                                                                                          
        struct.get(root, 0, fptr.SIZEOF_FPTR, &xRoot);      

        ; Remove the node        
        if fptr.isnull(&node_prev) != true {            
            fmalloc_item.next_set(node_prev, &node_next); 
        }
        if fptr.isnull(&node_next) != true {            
            fmalloc_item.prev_set(node_next, &node_prev);                                                                                                                          
        }
                
        ; Fixup root if the node was root
        if fptr.equal(node, xRoot) {  
            if fptr.isnull(&node_prev) != true {
                xRoot = node_prev;                
            } else {
                xRoot = node_next;                
            }
            struct.set(root, 0, fptr.SIZEOF_FPTR, &xRoot); 
        }

        ; Clear the next and previous pointers        
        fmalloc_item.next_set(node, &fptr.NULL);  
        fmalloc_item.prev_set(node, &fptr.NULL);  
    }
    
}