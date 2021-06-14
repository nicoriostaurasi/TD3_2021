/**
 * @file functions_rom.h
 * @author Nicolas Rios Taurasi (nicoriostaurasi@frba.utn.edu.ar)
 * @brief 
 * @version 1.1
 * @date 2021-06-01
 * 
 * @copyright Copyright (c) 2021
 * 
 */
#define ERROR_DEFECTO 0
#define EXITO 1

typedef unsigned char byte;
typedef unsigned long dword;

byte __fast_memcpy_rom( dword*,dword *,dword);
