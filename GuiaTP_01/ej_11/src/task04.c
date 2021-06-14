/**
 * @file task04.c
 * @author Nicolas Rios Taurasi (nicoriostaurasi@frba.utn.edu.ar)
 * @brief Funciones Tarea 4
 * @version 0.1
 * @date 09-06-2021
 * 
 * @copyright Copyright (c) 2021
 * 
 */

#include "../inc/task04.h"


/**
 * @brief Variable dummy para no harcodear la copia de .data
 * 
 */
__attribute__(( section(".data")))int dummy_task04_d;

/**
 * @brief Variable dummy para no harcodear la copia de .rodata
 * 
 */
__attribute__(( section(".rodata")))int dummy_task04_rd;


/**
 * @brief Variable dummy para no harcodear la copia de .rodata
 * 
 */
__attribute__(( section(".bss")))int dummy_task04_b;


/**
 * @brief Funcion principal Tarea 4
 * @param Nada
 * @return Nada
 * 
 */
__attribute__(( section(".functions_task04"))) void my_task_04(void)
{
    asm("hlt"::);
}
