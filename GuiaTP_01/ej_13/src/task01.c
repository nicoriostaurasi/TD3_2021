/**
 * @file task01.c
 * @author Nicolas Rios Tauasi (nicoriostaurasi@frba.utn.edu.ar)
 * @brief Tarea 1
 * @version 1.1
 * @date 2021-05-31
 * 
 * @copyright Copyright (c) 2021
 * 
 */

#include "../inc/task01.h"

/**
 * @brief Variable dummy para no harcodear la copia de .data
 * 
 */
__attribute__(( section(".data")))int dummy_task01;

/**
 * @brief Variable para no harcodear la copia de .rodata
 * 
 */
__attribute__(( section(".rodata")))int dummy_task01_rodata;

/**
 * @brief Variable para hacer las conversiones de division
 * 
 */
__attribute__(( section(".data")))data_conv buffer_conv_T1;

/**
 * @brief Variable para hacer las presentacion en pantalla
 * 
 */
__attribute__(( section(".data")))bits64 promedio_global;

/**
 * @brief Funcion Principal
 * @return nada
 * @param tabla_digitos* td_p
 */
__attribute__(( section(".functions_task01"))) void task01_main(tabla_digitos* td_p)
{
      task_promedio(td_p);
      task_show_VGA(td_p);
      task_show_time((tiempos*) &__DATOS_TIMER_VMA_LIN);
      //task_read_mem(td_p);
}

/**
 * @brief Función encargada de leer una posicion de memoria RAM
 * @param tabla_digitos* td_p
 * 
 * @return nada
 */
__attribute__(( section(".functions_task01"))) void task_read_mem(tabla_digitos* td_p)
{
    byte aux;
    dword auxd;
    //lee hasta la posicion 0x1FFFFFFF = 536870912B = 512MB
    if(promedio_global < 0x1FFFFFFF)
    {   
    auxd=&promedio_global;
    aux=task01_read_k(auxd,1);
    }
}

/**
 * @brief Variable para hacer el syscall para imprimir
 * 
 */
__attribute__(( section(".functions_task01"))) void task_01_print(byte inicioX,
                                                                  byte inicioY,
                                                                  byte* buffer,
                                                                  byte caracteres)
{
    static byte inY = 0;
    static byte inX = 0;
    static int i = 0;
    inY = inicioY;
    inX = inicioX;
    for (i = 0; i < caracteres; i++)
    {
        task01_print_k(inX+i,inY,buffer[i]);    
    }
}




/**
 * @brief Funcion que imprime el tiempo en pantalla
 * @return nada
 * @param tiempos* t_p
 */
__attribute__(( section(".functions_task01"))) void task_show_time(tiempos* t_p)
{
    static byte seg,min,hor;
    static byte aux;
    static byte i;
    //---seg=t_p->segundos;
    seg=task01_read_k(&(t_p->segundos),1);
    task_01_print(47,24,"Tiempo de ejecucion:",20);

    for(i=0;i<2;i++)
    {
    aux=seg%10;
    seg=seg/10;
    //__screen_buffer_printc(75-i,24,(screen_buffer*) &__VIDEO_VGA_LIN,aux+48);
    task01_print_k(75-i,24,aux+48);
    }
    task01_print_k(73,24,':');
    min=task01_read_k(&(t_p->minutos),1);

    for(i=0;i<2;i++)
    {
    aux=min%10;
    min=min/10;
    task01_print_k(72-i,24,aux+48);
    }
    task01_print_k(70,24,':');
    hor=task01_read_k(&(t_p->horas),1);

    for(i=0;i<2;i++)
    {
    aux=hor%10;
    hor=hor/10;
    task01_print_k(69-i,24,aux+48);
    }

}

/**
 * @brief Tarea para mostrar un numero de 64 bits en pantalla
 * @return nada
 * @param tabla_digitos* td_p
 */
__attribute__(( section(".functions_task01"))) void task_show_VGA_64(tabla_digitos* td_p)
{
    static byte aux=0;    
    static bits64 palabra_aux_resto,palabra_aux_div;
    static int i=0;
    static data_conv* dc_p;
    dc_p=(data_conv*)(&__DATOS_CONVERSION_VMA_LIN);
    palabra_aux_resto=td_p->promedio;
    palabra_aux_div=td_p->promedio;

    for(i=0;i<16;i++)
    {
    dc_p->dividendo=0x0000000000000000;
    dc_p->divisor=0x0000000000000000;
    dc_p->resultado=0x0000000000000000;
    
    dc_p->dividendo=palabra_aux_div;
    dc_p->divisor=0xA;
    my_division64(dc_p);
    palabra_aux_resto=dc_p->resultado;

    palabra_aux_resto=palabra_aux_div-10*palabra_aux_resto;
    if(palabra_aux_resto != 0)
    {
    aux= 0x0F & (palabra_aux_resto);
    }
    else
    {
    aux=0;
    }
    dc_p->dividendo=0x0000000000000000;
    dc_p->divisor=0x0000000000000000;
    dc_p->resultado=0x0000000000000000;

    dc_p->dividendo=palabra_aux_div;
    dc_p->divisor=0xA;
    my_division64(dc_p);
    palabra_aux_div=dc_p->resultado;

    if(aux>=10)
    {
       aux=aux/2; 
    }

    __screen_buffer_printc(16+5+11-i,13,(screen_buffer*) &__VIDEO_VGA_LIN,aux+48);
    aux=0;
    }
}

/**
 * @brief Funcion que divide operandos de 64
 * @return nada
 * @param data_conv* dc_p
 */
__attribute__(( section(".functions_task01")))void my_division64(data_conv* dc_p)
{
    static byte i=0;
    static bits64 a64,b64,r64aux,a64aux;         //      a64/b64
    a64=dc_p->dividendo;   
    b64=dc_p->divisor;
    r64aux=0x0000000000000000;
    a64aux=0x0000000000000000;    
    for(i=0;i<64;i++)
    {
        //if
        a64aux=a64aux | ( ( a64>>(64-1-i) ) & ( 0x01 ) );
        if(a64aux>=b64)
        {
        r64aux=r64aux|0x1;            
        a64aux=a64aux-b64;
        }
        r64aux=r64aux<<1;
        a64aux=a64aux<<1;
    }
    r64aux=r64aux>>1;
    dc_p->resultado=r64aux;
}

/**
 * @brief Funcion que recibe el dato de 64 bits y lo dibuja en pantalla 
 * @return nada
 * @param tabla_digitos* td_p
 */
__attribute__(( section(".functions_task01"))) void task_show_VGA(tabla_digitos* td_p)
{
    static dword parte_alta=0,parte_baja=0; //palabras de 32 bits
    static byte aux=0;
    static int i=0;
    parte_alta=(promedio_global & 0xFFFFFFFF00000000)>>32;
    parte_baja=(promedio_global) & 0x00000000FFFFFFFF;
    
    for(i=0;i<8;i++)
    {
    aux=parte_baja%16;
    parte_baja=parte_baja/16;
    if(aux>=10)
    {
    aux=aux+7;
    }
    //__screen_buffer_printc(16+5+15-i,10,(screen_buffer*) &__VIDEO_VGA_LIN,aux+48);
    task01_print_k(16+5+15-i,10,aux+48);
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
    //__screen_buffer_printc(8+5+15-i,10,(screen_buffer*) &__VIDEO_VGA_LIN,aux+48);
    task01_print_k(8+5+15-i,10,aux+48);
    }
}


/**
 * @brief Funcion que calcula el promedio de la tabla de digitos
 * @return nada
 * @param tabla_digitos* td_p
 */
__attribute__(( section(".functions_task01"))) void task_promedio(tabla_digitos* td_p)
{
    /*acumula y promedia*/
    static int i=0;
    static int j=0;
    static bits64 sumatoria=0x0;
    static bits64 promedio=0x0;
    data_conv* dc_p;
    promedio=0x0000000000000000;
    sumatoria=0x0000000000000000;
    j=task01_read_k(&(td_p->indice),1);
    for(i=0;i<j;i++)
    {
    sumatoria=sumatoria+task01_read_k(&(td_p->digito[i]),4);
    }
    if(j == 0)
    {
        promedio=0x00;
    }
    else
    {
        dc_p=&buffer_conv_T1;
        dc_p->dividendo=0x0000000000000000;
        dc_p->divisor=0x0000000000000000;
        dc_p->resultado=0x0000000000000000;
        dc_p->dividendo=sumatoria;
        dc_p->divisor=j;
        my_division64(dc_p);
        promedio=dc_p->resultado;
        promedio_global=promedio;
    }    
}

/**
 * @brief Funcion que hace la división de un numero de 64 bits, unicamente en la tabla de digitos
 * @return nada
 * @param tabla_digitos* td_p
 */
__attribute__(( section(".functions_task01"))) void my_division64_promedio(tabla_digitos* td_p)
{
    static byte i=0;
    static bits64 a64,b64,r64aux,a64aux;         //      a64/b64
    a64=td_p->sumatoria;   
    b64=td_p->indice;
    r64aux=0x0000000000000000;
    a64aux=0x0000000000000000;

    for(i=0;i<64;i++)
    {
        //if
        a64aux=a64aux | ( ( a64>>(64-1-i) ) & ( 0x01 ) );
        if(a64aux>=b64)
        {
        r64aux=r64aux|0x1;            
        a64aux=a64aux-b64;
        }
        r64aux=r64aux<<1;
        a64aux=a64aux<<1;
    }
    r64aux=r64aux>>1;
    td_p->promedio=r64aux;
}
