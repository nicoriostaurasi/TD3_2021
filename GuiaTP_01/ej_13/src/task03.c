/**
 * @file task03.c
 * @author Nicolas Rios Taurasi (nicoriostaurasi@frba.utn.edu.ar)
 * @brief Funciones Tarea 3
 * @version 0.1
 * @date 09-06-2021
 * 
 * @copyright Copyright (c) 2021
 * 
 */

#include "../inc/task03.h"


/**
 * @brief Variable dummy para no harcodear la copia de .data
 * 
 */
__attribute__(( section(".data")))int dummy_task03;

/**
 * @brief Variable para la sumatoria
 * 
 */
__attribute__(( section(".data")))bits64 sumatoria_t3;

__attribute__(( section(".data")))tabla_digitos tabla_t3; 

/**
 * @brief Variable dummy para no harcodear la copia de .rodata
 * 
 */
__attribute__(( section(".rodata")))int dummy_task03_2;


/**
 * @brief Funcion principal de la tarea 3
 * @param tabla_digitos* td_p, puntero a la tabla de digitos
 * @return nada
 */
__attribute__(( section(".functions_task03"))) void task03_main(tabla_digitos* td_p)
{
    sumatoria_t3 =  0x0000000000000000;
    task03_copy_digit(td_p);
    task_03_show_VGA(td_p);
}


__attribute__(( section(".functions_task03"))) void task03_copy_digit(tabla_digitos* td_p)
{
    static int j=0;
    static int i=0;
    static bits64 aux=0;
    j=task03_read_k(&(td_p->indice),1);
    for(i=0;i<j;i++)
    {
        aux=0;
        aux=task03_read_k(&(td_p->digito[i]),4);
        (&tabla_t3)->digito[i]=aux;        
    }
    if (j =! 0)
    {
       sumatoria_t3 = suma_quad_word(&tabla_t3);   
    }
}

/**
 * @brief Función que realiza la sumatoria de la tabla de digitos
 * @param tabla_digitos* td_p, puntero a la tabla de digitos
 * @return nada
 * 
 */
__attribute__(( section(".functions_task03"))) void task03_sumatoria(tabla_digitos* td_p)
{
    /*acumula*/
    static int i=0;
    td_p->sumatoria=0x0000000000000000;
    for(i=0;i<td_p->indice;i++)
    {
    td_p->sumatoria=td_p->sumatoria+td_p->digito[i];
    }
}


/**
 * @brief Funcion que imprime en pantalla la sumatoria
 * @param tabla_digitos* td_p
 * @return nada
 */
__attribute__(( section(".functions_task03"))) void task_03_show_VGA(tabla_digitos* td_p)
{
    static dword parte_alta=0,parte_baja=0; //palabras de 32 bits
    static byte aux=0;
    static int i=0;
    parte_alta=(sumatoria_t3 & 0xFFFFFFFF00000000)>>32;
    parte_baja=(sumatoria_t3) & 0x00000000FFFFFFFF;
    for(i=0;i<8;i++)
    {
    aux=parte_baja%16;
    parte_baja=parte_baja/16;
    if(aux>=10)
    {
    aux=aux+7;
    }
    //__screen_buffer_printc(16+5+15-i,12,(screen_buffer*) &__VIDEO_VGA_LIN,aux+48);
    task03_print_k(16+5+15-i,12,aux+48);
    }

    aux=0;
    
    for(i=0;i<8;i++)
    {
    aux=parte_alta%16;
    parte_alta=parte_alta/16;
    if(aux>=10)
    {
    aux=aux+7;
    }
    //__screen_buffer_printc(8+5+15-i,12,(screen_buffer*) &__VIDEO_VGA_LIN,aux+48);
    task03_print_k(8+5+15-i,12,aux+48);
    }
}
