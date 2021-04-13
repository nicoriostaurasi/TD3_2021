SECTIONS
{
    .Init16 0xFFFF0000 : /*VMA*/
        AT(0xFFFF0000)   /*LMA*/
    {
        *(.Init16);
    }

    .Init32 0xFFFF4000 : /*VMA*/
        AT(0xFFFF4000)   /*LMA*/
    {
        *(.Init32);
    }

    .Reset 0xFFFFFFF0 : /*VMA*/
        AT(0xFFFFFFF0)  /*LMA*/
    {
        *.(Reset);
    }
}