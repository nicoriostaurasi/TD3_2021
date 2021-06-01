#include "../inc/functions_rom.h"

/**
 * @return 1 si es todo OK, 0 Error
 * 
 * @brief Función de copia en memoria para utilizar desde RAM 
 * 
 * @param dword* Memoria origen, 
 * @param dword* Memoria destino, 
 * @param dword Cantidad de bytes.
 * 
 */
__attribute__(( section(".functions_rom"))) byte __fast_memcpy_rom(dword*src,dword *dst,dword length)
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