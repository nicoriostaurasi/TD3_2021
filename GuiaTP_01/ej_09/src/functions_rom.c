/**
 * @file functions_rom.c
 * @author Nicolas Rios Taurasi (nicoriostaurasi@frba.utn.edu.ar)
 * @brief 
 * @version 1.1
 * @date 2021-06-01
 * 
 * @copyright Copyright (c) 2021
 * 
 */

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