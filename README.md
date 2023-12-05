# P8Test

## struct.p8
### struct

## fstruct.p8
### fstruct
### **fptr**
#### **const ubyte SIZEOF_FPTR = 3;**
> Constant size of a far pointer
#### **byte[] NULL = [0,0,0];**
> A null far pointer
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
>
#### **asmsub memcopy_out(uword fptr @R0, uword valuePointer @R1, ubyte count @X) clobbers (Y)**
>


## fmalloc.p8
### fmalloc_root
### fmalloc_item
### fmalloc

## linkedlist.p8
### linkedlist_root
### linkedlist_item
### linkedlist

