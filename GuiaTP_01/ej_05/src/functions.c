#include "../inc/functions.h"

int i=45;

__attribute__(( section(".functions"))) byte __fast_memcpy_rom(dword* src,dword *dst,dword length)
{

    i++;
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
    return status;
}