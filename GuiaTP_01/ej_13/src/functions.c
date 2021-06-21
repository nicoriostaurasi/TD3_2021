/**
 * @file    functions.c
 * @author  Nicolas Rios Taurasi (nicoriostaurasi@frba.utn.edu.ar)
 * @brief   Funciones en c de utilidad general en el TP
 * @version 1.1
 * @date    2021-05-31
 * 
 * @copyright Copyright (c) 2021
 * 
 */

#include "../inc/functions.h"

/*----------------------------------------------------------
 *FUNCIONES GENERALES 
 __fast_memcpy
 __clean_dir 
 *----------------------------------------------------------*/

/*---------------------------------------------------------- 
 * PAGINACION
 * __pagina_rom
 * __carga_DTP
 * __carga_TP
 * __carga_CR3
 * __levanto_pagina
 *----------------------------------------------------------*/

/*---------------------------------------------------------- 
 * TIMER
 * __tiempo_iniciar
 * __Systick_Handler
 *----------------------------------------------------------*/

/*----------------------------------------------------------  
 * SCHEDULER
 * __Scheduler_Handler
 *----------------------------------------------------------*/

/*---------------------------------------------------------- 
 * TABLAS DE SISTEMA
 * __carga_GDT
 * __carga_IDT
 *----------------------------------------------------------*/

/*---------------------------------------------------------- 
 *DIGITOS
 * tabla_digitos_init
 * tabla_digitos_completar
 * sup_tabla_digitos_completar
 *----------------------------------------------------------*/

/*---------------------------------------------------------- 
 *RING BUFFER
 * __ring_buffer_init
 * __ring_buffer_clear
 * ring_buffer_push
 *----------------------------------------------------------*/

/*----------------------------------------------------------  
 *PANTALLA
 * __screen_buffer_init
 * __screen_buffer_printc
 * __screen_buffer_print
 *----------------------------------------------------------*/

/*----------------------------------------------------------  
 *TECLADO
 * __chequeo_tecla
 *----------------------------------------------------------*/

//----------------------------------------------------------
//                   FUNCIONES GENERALES
//----------------------------------------------------------

/*----------------------------------------------------------
 __fast_memcpy
 __clean_dir 
 *----------------------------------------------------------*/

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
__attribute__((section(".functions"))) byte __fast_memcpy(dword *src, dword *dst, dword length)
{
    byte status = ERROR_DEFECTO;
    if (length > 0)
    {
        while (length)
        {
            length--;
            *dst++ = *src++;
        }
        status = EXITO;
    }
    return (status);
}

/**
 * @brief Funcion para limpiar un bloque de memoria RAM
 * 
 * @return nada
 * @param bits16 cantidad de bytes
 * @param dword* origen
 *  
 */
__attribute__((section(".functions"))) void __clean_dir(bits16 tamanio, dword *origen)
{
    if (tamanio > 0)
    {
        while (tamanio)
        {
            tamanio--;
            *origen = 0x00;
            origen++;
        }
    }
}

//----------------------------------------------------------
//                   PAGINACION
//----------------------------------------------------------

/*----------------------------------------------------------
 * __pagina_rom
 * __carga_DTP
 * __carga_TP
 * __carga_CR3
 * __levanto_pagina
 *----------------------------------------------------------*/

/**
 * @brief Funcion para paginar los 64K de RAM
 * 
 * @param nada
 * @return nada
 */
__attribute__((section(".functions"))) void __pagina_rom(void)
{
    byte i = 0;
    for (i = 0; i < 16; i++)
    {
        __carga_TP(0x410000, 0x3F0 + i, 0xFFFF0000 + i * 0x1000, 0, 0, 0, 0, 0, 0, 0, 0, 1);
        //0x10000+0x1000+0x1000*0x3FF
    }
}

/**
 * @brief Función para cargar un directorio de tablas de pagina
 * @return nada
 * 
 * @param dword  Inicio de la DPT
 * @param bits16 Bits 31-22 de la Dirección
 * @param dword  Inicio de las TP
 * @param byte   Tamaño de Página   4K:0   No 4K:1
 * @param byte   Accedida           SI:1     NO:0
 * @param byte   PCD                SI:1     NO:0
 * @param byte   PWT                SI:1     NO:0
 * @param byte   US/SUP             SUP:0    US:1
 * @param byte   R/RW               R:0      RW:1
 * @param byte   Presente:          SI:1     NO:0
 * 
 */
__attribute__((section(".functions"))) void __carga_DTP(dword init_dpt,
                                                        bits16 entry,
                                                        dword init_pt,
                                                        byte _ps,
                                                        byte _a,
                                                        byte _pcd,
                                                        byte _pwt,
                                                        byte _us,
                                                        byte _rw,
                                                        byte _p)
{
    dword dpte = 0;
    dword *dst = (dword *)init_dpt;

    dpte |= (init_pt & 0xFFFFF000);
    dpte |= (_ps << 7);
    dpte |= (_a << 5);
    dpte |= (_pcd << 4);
    dpte |= (_pwt << 3);
    dpte |= (_us << 2);
    dpte |= (_rw << 1);
    dpte |= (_p << 0);

    *(dst + entry) = dpte;
}

/**
 * @brief Funcion para cargar una TP
 * 
 * @return nada
 * 
 * @param dword init_pt         Inicio de la Tabla de Paginas  
 * @param bits16 entry,         Offset dentro de la Tabla de Paginas (bits 21 a 12)
 * @param dword init_pag,       Direccion de Mapeo 
 * @param byte Global           SI:1     NO:0
 * @param byte PAT          
 * @param byte Dirty            
 * @param byte Accedida         SI:1     NO:0   
 * @param byte PCD              SI:1     NO:0   
 * @param byte PWT              SI:1     NO:0   
 * @param byte US/SUP           SUP:0    US:1   
 * @param byte R/RW             R:0      RW:1   
 * @param byte Presente         SI:1     NO:0   
 */
__attribute__((section(".functions"))) void __carga_TP(dword init_pt,
                                                       bits16 entry,
                                                       dword init_pag,
                                                       byte _g,
                                                       byte _pat,
                                                       byte _d,
                                                       byte _a,
                                                       byte _pcd,
                                                       byte _pwt,
                                                       byte _us,
                                                       byte _rw,
                                                       byte _p)
{
    dword pte = 0;

    dword *dst = (dword *)init_pt;

    pte |= (init_pag & 0xFFFFF000);
    pte |= (_g << 8);
    pte |= (_pat << 7);
    pte |= (_d << 6);
    pte |= (_a << 5);
    pte |= (_pcd << 4);
    pte |= (_pwt << 3);
    pte |= (_us << 2);
    pte |= (_rw << 1);
    pte |= (_p << 0);

    *(dst + entry) = pte;
}

/**
 * @brief Funcion para cargar el CR3
 * @return dword eax para cargar cr3
 * @param dword Atributos
 * @param dword Direccion de Inicio DTP 
 */
__attribute__((section(".functions"))) dword __carga_CR3(dword atributos, dword direccion)
{
    dword aux;

    aux = (direccion & 0xFFFFF000) | (atributos & 0x18);
    return aux;
}

/**
 * @brief Función para paginar todos los 4MB correspondientes a las Tablas de Páginas 
 * 
 * @return nada
 * @param nada
 */
__attribute__((section(".functions"))) void __levanto_pagina(void)
{

    bits16 i = 0;
    for (i = 0; i < 1024; i++)
    {
        __carga_TP(0x00011000, 0x010 + i, 0x0010000 + i*0x1000, 0, 0, 0, 0, 0, 0, 0, 1, 1);
        //0x10000+0x1000+0x1000*0x000
        //0x10000+0x1000+0x1000*0x3FF
    }
 
}

//----------------------------------------------------------
//                   TABLAS DE SISTEMA
//----------------------------------------------------------

/*----------------------------------------------------------
 * __carga_GDT
 * __carga_IDT
 *----------------------------------------------------------*/

/**
 * @brief Función de carga de GDT
 * @return nada
 * @param dword offsetGDT
 * @param dword base 
 * @param dword limite
 * @param dword atributos
 */
__attribute__((section(".functions"))) void __carga_GDT(dword offsetGDT,
                                                        dword base,
                                                        dword limite,
                                                        dword atributos)
{
    //asm("xchg %%bx,%%bx"::);
    *(&__SYS_TABLES_32_VMA_LIN + 2 * offsetGDT) = (limite & 0x0000FFFF) | ((base & 0x0000FFFF) << 16); // parte baja - parte alta
    *((&__SYS_TABLES_32_VMA_LIN + 2 * offsetGDT) + 1) = ((base & 0x00FF0000) >> 16) | ((atributos & 0x000000FF) << 8) | (limite & 0x000F0000) | ((atributos & 0x000000F00) << 12) | (base & 0xFF000000);
}

/**
 * @brief Funcion de carga de IDT
 * @return nada
 * @param dword offsetIDT
 * @param dword selector
 * @param dword atributos
 * @param dword offset
 */
__attribute__((section(".functions"))) void __carga_IDT(dword offsetIDT,
                                                        dword selector,
                                                        dword atributos,
                                                        dword offset)
{
    *((&__SYS_TABLES_32_VMA_LIN + 2 * CANT_GDTS + 2 * offsetIDT)) = (offset & 0x00000FFFF) | ((selector & 0x0000FFFF) << 16); // parte baja - parte alta
    *((&__SYS_TABLES_32_VMA_LIN + 2 * CANT_GDTS + 2 * offsetIDT) + 1) = ((atributos & 0x000000FF) << 8) | (offset & 0xFFFF0000);
}

//----------------------------------------------------------
//                   DIGITOS
//----------------------------------------------------------

/*----------------------------------------------------------
 * tabla_digitos_init
 * tabla_digitos_completar
 * sup_tabla_digitos_completar
 *----------------------------------------------------------*/

/**
 * @brief Funcion para inicializar la tabla de digitos
 * @return nada
 * @param tabla_digitos* td_p VMA de la estructura de tabla de digitos
 */
__attribute__((section(".functions"))) void tabla_digitos_init(tabla_digitos *td_p)
{
    static int i = 0;
    td_p->promedio = 0x00;
    td_p->indice = 0x00;
    for (i = 0; i < CANT_DIGITOS; i++)
    {
        td_p->digito[i] = 0x00;
    }

}

/**
 * @brief Funcion para ingresar un numero en la tabla, como son datos de 128 bits debo pasarlo de a partes
 * @return nada
 * @param tabla_digitos* td_p VMA de la estructura a la tabla de digitos
 * @param bits64 Parte alta
 * @param bits64 Parte baja
 */
__attribute__((section(".functions"))) void tabla_digitos_completar(tabla_digitos *td_p,
                                                                    bits64 dato_alto,
                                                                    bits64 dato_bajo)
{
    static bits64 aux = 0;
    static bits64 exponente = 1;
    static int i = 0;

    exponente = 1;
    aux = 0;

    for (i = 0; i < 8; i++)
    {
        aux = aux + exponente * ((dato_bajo >> (8 * i)) & 0xFF);
        exponente = exponente * 10;
    }

    for (i = 0; i < 8; i++)
    {
        aux = aux + exponente * ((dato_alto >> (8 * i)) & 0xFF);
        exponente = exponente * 10;
    }
    td_p->digito[td_p->indice] = aux;
    td_p->indice++;

    if (td_p->indice >= CANT_DIGITOS)
        {
        td_p->indice = 0;

        for (i = 0; i < CANT_DIGITOS; i++)
        {
        td_p->digito[i] = 0x00;
        }

        }

}

/**
 * @brief Funcion para preparar el pase a tabla_digitos_completar
 * @param ring_buffer* rb_p, VMA del inicio de la estructura de Ring Buffer
 * @return nada
 */
__attribute__((section(".functions"))) void sup_tabla_digitos_completar(ring_buffer *rb_p)
{
    static bits64 parte_baja = 0x0000000000000000;
    static bits64 parte_alta = 0x0000000000000000;
    static int i = 0;
    parte_alta = 0x0000000000000000;
    parte_baja = 0x0000000000000000;

    for (i = 0; i < 8; i++)
    {
        parte_baja = (byte)rb_p->buffer[7 - i] | (parte_baja << 8);
    }
    for (i = 0; i < 8; i++)
    {
        parte_alta = (byte)rb_p->buffer[15 - i] | (parte_alta << 8);
    }

    tabla_digitos_completar((tabla_digitos *)&__DIGITOS_VMA_LIN, parte_alta, parte_baja);
    //asm("xchg %%bx,%%bx"::);
}

//----------------------------------------------------------
//                   RING BUFFER
//----------------------------------------------------------

/*----------------------------------------------------------
 * __ring_buffer_init
 * __ring_buffer_clear
 * ring_buffer_push
 *----------------------------------------------------------*/

/**
 * @brief Funcion para inicializar el ring buffer de teclado
 * @param ring_buffer* rb_p, Inicio a la estructura del Ring Buffer
 * @return nada
 */
__attribute__((section(".functions"))) void __ring_buffer_init(ring_buffer *rb_p)
{
    rb_p->tam_elemento = sizeof(byte);
    rb_p->longitud = LONG_BUFFER * (rb_p->tam_elemento);
    rb_p->longitud_en_bytes = (rb_p->longitud) * (rb_p->tam_elemento);
    rb_p->inicio = rb_p->buffer;
    rb_p->fin = (byte *)(rb_p->buffer + LONG_BUFFER - 1);
    rb_p->progreso = 0;
    rb_p->cabeza = rb_p->inicio;
    rb_p->cola = rb_p->inicio;
}

/**
 * @brief Funcion para limpiar el ring buffer de teclado
 * @param ring_buffer* VMA del Ring Buffer de teclado
 * @return nada
 */
__attribute__((section(".functions"))) void __ring_buffer_clear(ring_buffer *rb_p)
{
    static int i = 0;
    rb_p->progreso = 0;
    rb_p->cola = rb_p->inicio;

    for (i = 0; i < rb_p->longitud; i++)
    {
        rb_p->buffer[i] = 0x00;
    }
}

/**
 * @brief Función para pushear dentro del ring buffer de teclado
 * @param ring_buffer* rb_p   VMA de inicio del Ring Buffer
 * @param byte tecla_recibida Tecla recibida ya chequeada
 * @return nada
 * 
 */
__attribute__((section(".functions"))) void ring_buffer_push(ring_buffer *rb_p, byte tecla_recibida)
{
    static int i = 0;

    for (i = 0; i < LONG_BUFFER - 1; i++)
    {
        rb_p->buffer[LONG_BUFFER - 1 - i] = rb_p->buffer[LONG_BUFFER - 2 - i];
    }

    rb_p->buffer[0] = tecla_recibida;

    rb_p->cola = (byte *)(rb_p->buffer + LONG_BUFFER - 1 - rb_p->progreso);

    rb_p->progreso++;

    if (rb_p->progreso == rb_p->longitud)
    {
        sup_tabla_digitos_completar((ring_buffer *)&__DATOS_VMA_LIN);
        __ring_buffer_clear((ring_buffer *)&__DATOS_VMA_LIN);
    }
}

//----------------------------------------------------------
//                   PANTALLA
//----------------------------------------------------------

/*----------------------------------------------------------
 * __screen_buffer_init
 * __screen_buffer_printc
 * __screen_buffer_print
 *----------------------------------------------------------*/

/**
 * @brief Función para inicializar buffer de pantalla
 * @param screen_buffer* sb_p, recibe el inicio de la VMA de la estructura de Pantalla
 * @return nada
 */
__attribute__((section(".functions"))) void __screen_buffer_init(screen_buffer *sb_p)
{
    //buffer[25][80]
    //buffer[F][C]
    static int i = 0;
    static int j = 0;
    for (i = 0; i < 25; i++) //Filas
    {
        for (j = 0; j < 80; j++) //columnas
        {
            sb_p->buffer[i][j] = 0x1E00; //inicializo todo en caracteres blanco
        }
    }
    __screen_buffer_print(18, 1, sb_p, "Ejercicio N#13 - Niveles de Privilegio", 38);
    __screen_buffer_print(5, 10, sb_p, "Promedio  T1: 0x", 16);
    __screen_buffer_print(5, 11, sb_p, "Sumatoria T2: 0x", 16);
    __screen_buffer_print(5, 12, sb_p, "Sumatoria T3: 0x", 16);
    __screen_buffer_print(5, 22, sb_p, "Rios Taurasi Nicolas - TD3 UTN FRBA - CL 2021", 45);
}

/**
 * @brief Funcion para escribir un caracter unicamente
 * @return nada
 * @param byte X
 * @param byte Y
 * @param screen_buffer* sb_p recibe el inicio de la VMA de la estructura de Pantalla
 * @param char caracter
 */
__attribute__((section(".functions"))) void __screen_buffer_printc(byte X,
                                                                   byte Y,
                                                                   screen_buffer *sb_p,
                                                                   char caracter)
{
    static byte inY = 0;
    static byte inX = 0;
    inY = Y;
    inX = X;
    sb_p->buffer[inY][inX] = 0x1E00  | (caracter & 0xFF);
}

/**
 * @brief Función para escribir ciertos pixeles de pantalla
 * @return nada
 * @param byte inicioX
 * @param byte inicioY
 * @param screen_buffer *sb_p
 * @param char* buffer
 * @param byte cantidad de caracteres
 */
__attribute__((section(".functions"))) void __screen_buffer_print(byte inicioX,
                                                                  byte inicioY,
                                                                  screen_buffer *sb_p, char *buffer,
                                                                  byte caracteres)
{
    static byte inY = 0;
    static byte inX = 0;
    static int i = 0;
    inY = inicioY;
    inX = inicioX;
    for (i = 0; i < caracteres; i++)
    {
        sb_p->buffer[inY][inX + i] = 0x1E00 | (buffer[i] & 0xFF);
    }
}

//----------------------------------------------------------
//                   TECLADO
//----------------------------------------------------------

/*----------------------------------------------------------
 *__chequeo_tecla
 *----------------------------------------------------------*/

/**
 * @brief Función para chequear que la tecla ingresada sea valida
 * @return nada
 * @param byte tecla
 */
__attribute__((section(".functions"))) void __chequeo_tecla(byte tecla)
{
    tecla = (0x000000FF) & tecla;
    switch (tecla)
    {
    case TECLA_0:
    {
        ring_buffer_push((ring_buffer *)&__DATOS_VMA_LIN, 0x00);
        break;
    }

    case TECLA_1:
    {
        ring_buffer_push((ring_buffer *)&__DATOS_VMA_LIN, 0x01);
        break;
    }
    case TECLA_2:
    {
        ring_buffer_push((ring_buffer *)&__DATOS_VMA_LIN, 0x02);
        break;
    }
    case TECLA_3:
    {
        ring_buffer_push((ring_buffer *)&__DATOS_VMA_LIN, 0x03);

        break;
    }
    case TECLA_4:
    {
        ring_buffer_push((ring_buffer *)&__DATOS_VMA_LIN, 0x04);

        // asm("xchg %%bx,%%bx"::);
        break;
    }
    case TECLA_5:
    {

        ring_buffer_push((ring_buffer *)&__DATOS_VMA_LIN, 0x05);
        // asm("xchg %%bx,%%bx"::);
        break;
    }
    case TECLA_6:
    {

        ring_buffer_push((ring_buffer *)&__DATOS_VMA_LIN, 0x06);
        // asm("xchg %%bx,%%bx"::);
        break;
    }
    case TECLA_7:
    {

        ring_buffer_push((ring_buffer *)&__DATOS_VMA_LIN, 0x07);
        // asm("xchg %%bx,%%bx"::);
        break;
    }
    case TECLA_8:
    {
        // asm("xchg %%bx,%%bx"::);

        ring_buffer_push((ring_buffer *)&__DATOS_VMA_LIN, 0x08);
        break;
    }
    case TECLA_9:
    {
        // asm("xchg %%bx,%%bx"::);

        ring_buffer_push((ring_buffer *)&__DATOS_VMA_LIN, 0x09);
        break;
    }
    case TECLA_ENTER:
    {
        sup_tabla_digitos_completar((ring_buffer *)&__DATOS_VMA_LIN);
        __ring_buffer_clear((ring_buffer *)&__DATOS_VMA_LIN);
        break;
    }
    default:
        break;
    }
}
