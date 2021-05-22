#include "../inc/functions.h"

__attribute__(( section(".functions"))) byte __fast_memcpy(dword* src,dword *dst,dword length)
{
    byte status = ERROR_DEFECTO;
    if(length>0)
    {
        while(length)
        {
            length--;
            *dst++=*src++;
        }
        status = EXITO;
    }
    return (status);
}

__attribute__(( section(".functions"))) void __carga_GDT(dword offsetGDT,
                                                        dword base,
                                                        dword limite,
                                                        dword atributos)
{
//asm("xchg %%bx,%%bx"::);
*(&__SYS_TABLES_32_VMA+2*offsetGDT)=(limite & 0x0000FFFF)|((base & 0x0000FFFF)<<16) ; // parte baja - parte alta
*((&__SYS_TABLES_32_VMA+2*offsetGDT)+1)=((base & 0x00FF0000)>>16)|((atributos & 0x000000FF)<<8)|(limite & 0x000F0000)|((atributos & 0x000000F00)<<12)|(base & 0xFF000000);
}

__attribute__(( section(".functions"))) void __carga_IDT(dword offsetIDT,
                                                        dword selector,
                                                        dword atributos,
                                                        dword offset)
{
*((&__SYS_TABLES_32_VMA+2*CANT_GDTS+2*offsetIDT))=(offset&0x00000FFFF)|((selector&0x0000FFFF)<<16); // parte baja - parte alta
*((&__SYS_TABLES_32_VMA+2*CANT_GDTS+2*offsetIDT)+1)=((atributos & 0x000000FF)<<8)|(offset&0xFFFF0000);
//asm("xchg %%bx,%%bx"::);
}
