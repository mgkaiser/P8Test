# P8Test

## struct.p8

> Library containing helper functions for near pointers

### struct

> helper functions for managing near structures

## fstruct.p8

> Library containing helper functions for far pointers and structures

### fstruct

> Helper functions for managing far structures

### **fptr**

>Helper functions for managing far pointers

#### **const ubyte SIZEOF_FPTR = 3;**

>Constant size of a far pointer

#### **byte[] NULL = [0,0,0];**

>A null far pointer

#### **asmsub b2p(ubyte bank @A, uword ptr @R1, uword fptr @R0) clobbers (Y)**

>Takes a "bank" and a "ptr" and returns a "fptr"

#### **sub isnull(ubyte[fptr.SIZEOF_FPTR] ptr1) -> bool**

>Takes "ptr1" and returns "true" if it is null, otherwise "false"

#### **sub compare(ubyte[fptr.SIZEOF_FPTR] ptr1, ubyte[fptr.SIZEOF_FPTR] ptr2) -> byte**

>Compares ptr1 and ptr2
>
>>If ptr1 == ptr1 returns compare_equal
>>
>>If ptr1 > ptr2 returns compare_greater
>>
>>If ptr1 < ptr2 returns compare_less
>>

#### **asmsub set(uword fptr @R0, uword valuePointer @R1) clobbers (Y)**

> Copy the far pointer stored at the memory location "valuePointer" points to the memory location pointed to by "fptr"
>
> In other words this copies a far pointer value from a memory location pointed to by the near pointer "valuePointer" to the memory location pointed to by the far pointer "fptr"

#### **asmsub get(uword fptr @R0, uword valuePointer @R1) clobbers (Y)**

> Copy the far pointer stored at the memory location "fptr" points to to the memory location pointed to by "valuePointer"
>
> In other words this copies a far pointer value from a memory location pointed to by the far pointer "fptr" to the memory location pointed to by the near pointer "valuePointer"

#### **asmsub memcopy_in(uword fptr @R0, uword valuePointer @R1, ubyte count @X) clobbers (Y)**

> Copy "count" bytes from the memory address the near pointer "valuePointer" points to the memory address "fptr" points to

#### **asmsub memcopy_out(uword fptr @R0, uword valuePointer @R1, ubyte count @X) clobbers (Y)**

> Copy "count" bytes from the memory address "fptr" points to the memory address the near pointer "valuePointer" points to

## fmalloc.p8

> Library containing supporting structures and functions for far memory allocation

### fmalloc_root

> Structure, stored in near memory, to store the headers and statistics for "fmalloc"

#### **const ubyte SIZEOF_FMALLOC = $0c**

> Constant size of fmalloc_root structure
**
#### **sub available_get(uword ptr, uword result)**

>

#### **sub available_set(uword ptr, uword value)**

>

#### **sub assigned_get(uword ptr, uword result)**

>

#### **sub assigned_set(uword ptr, uword value)**

>

#### **sub freemem_get(uword ptr, uword result)**

>

#### **sub freemem_set(uword ptr, uword value)**

>

#### **sub freemem_set_wi(uword ptr, uword value)**

>

#### **sub totalmem_get(uword ptr, uword result)**

>

#### **sub totalmem_set(uword ptr, uword value)**

>

#### **sub totalmem_set_wi(uword ptr, uword value)**

>

#### **sub totalnodes_get(uword ptr, uword result)**

>

#### **sub totalnodes_set(uword ptr, uword value)**

>

#### **sub totalnodes_set_wi(uword ptr, uword value)**

>

### fmalloc_item

### fmalloc

## linkedlist.p8

### linkedlist_root

### linkedlist_item

### linkedlist

