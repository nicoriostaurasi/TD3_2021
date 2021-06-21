/**
 * @file functions.h
 * @author Nicolas Rios Taurasi (nicoriostauasi@frba.utn.edu.ar)
 * @brief  Includes generales de utilidad
 * @version 0.1
 * @date 2021-05-31
 * 
 * @copyright Copyright (c) 2021
 * 
 */
#define ERROR_DEFECTO 0
#define EXITO 1
#define CANT_GDTS 4
//https://stanislavs.org/helppc/make_codes.html        
#define TECLA_ENTER 0x9C
#define TECLA_1     0x82
#define TECLA_2     0x83
#define TECLA_3     0x84
#define TECLA_4     0x85
#define TECLA_5     0x86
#define TECLA_6     0x87
#define TECLA_7     0x88
#define TECLA_8     0x89
#define TECLA_9     0x8A
#define TECLA_0     0x8B
#define LONG_BUFFER 16
#define CANT_DIGITOS 50 //;Mismo define en simd.asm
#define TAREA_1 1
#define TAREA_2 2
#define TAREA_4 4
extern long unsigned __SYS_TABLES_32_VMA_LIN;
extern long unsigned __DATOS_VMA_LIN;
extern long unsigned __DIGITOS_VMA_LIN;
extern long unsigned __VIDEO_VGA_LIN;
extern long unsigned __DATOS_SCH_VMA_LIN;
extern long unsigned __DATOS_CONVERSION_VMA_LIN;
extern long unsigned __DATOS_IMPRESION_VMA_LIN;
extern long unsigned __DATOS_TIMER_VMA_LIN;
extern long unsigned __PAGE_TABLES_VMA_LIN;


//https://en.wikipedia.org/wiki/C_data_types#
typedef long unsigned direccion;
typedef unsigned char byte; //8bits
typedef unsigned short bits16;
typedef unsigned long dword; //32 bits
typedef unsigned long long bits64;//64 bits

typedef struct tabla_digitos        //Se carga en 0x00200000
{
    bits64 promedio;                // 8
    bits64 sumatoria;               // 8
    bits64 digito[CANT_DIGITOS];    // 8*100
    byte indice;                    // 1
}tabla_digitos;                     // 816 BYTES

//https://embeddedartistry.com/blog/2017/05/17/creating-a-circular-buffer-in-c-and-c/

typedef struct ring_buffer  //Se carga en: 0x00210000 - 0x00210023
{

    byte* cabeza;        //puntero a cabeza             4                         
    byte* cola;          //puntero a la cola            4
    byte buffer[LONG_BUFFER];//buffer                   16
    byte* inicio;        //puntero al inicio            4
    byte* fin;           //puntero al fin               4
    byte progreso;       //cantidad de datos ingresados 1
    byte longitud;       //longitud en elementos        1
    byte longitud_en_bytes;//                           1
    byte tam_elemento;   //tamaño de cada elemento      1
}ring_buffer;                                          //36 BYTES

//Data_TECLADO              //Se carga en: 0x00210030 1 BYTE 

typedef struct tiempos      //Se carga en: 0x00210050 - 0x00210055 
{
    byte base;              // 1
    bits16 milisegundos;    // 2
    byte segundos;          // 1
    byte minutos;           // 1
    byte horas;             // 1
}tiempos;                   // 6 BYTES   

typedef struct promedio_data      //Se carga en: 0x00210060 - 0x00210067  
{
    bits64 promedio;            // 8
}promedio_data;                 // 8 BYTES   

typedef struct sch_buffer   //Se carga en: 0x00210070
{
    byte TareaActual;            //1
    byte TareaProxima;            //1
    byte ContadorTarea1;            //1
    byte ContadorTarea2;            //1
}sch_buffer;

typedef struct data_conv   //Se carga en: 0x00210090
{
    bits64 dividendo;            //8
    bits64 resultado;            //8
    bits64 divisor;              //8   
}data_conv;

/*
typedef struct data_show   //Se carga en: 0x00210110
{
    bits64 aux_resto;            //8
    bits64 aux_div;              //8
}data_show;
*/


typedef struct screen_buffer
{
    bits16 buffer[25][80];
}screen_buffer;

byte __fast_memcpy( dword*,dword *,dword);
void __carga_GDT(dword,dword,dword,dword);
void __carga_IDT(dword,dword,dword,dword);
void __chequeo_tecla(byte);
void __ring_buffer_init(ring_buffer*);
void __ring_buffer_clear(ring_buffer*);
void ring_buffer_push(ring_buffer*,byte);
void tabla_digitos_init(tabla_digitos*);
void sup_tabla_digitos_completar(ring_buffer*);
void tabla_digitos_completar(tabla_digitos*,bits64,bits64);
void __screen_buffer_init(screen_buffer *);
void __screen_buffer_print(byte,byte,screen_buffer *,char*,byte);
void __screen_buffer_printc(byte,byte,screen_buffer *,char);
void __tiempo_iniciar(tiempos*);
void __carga_DTP(dword, bits16, dword, byte, byte, byte, byte, byte, byte, byte);
void __carga_TP (dword, bits16, dword, byte, byte, byte, byte, byte, byte, byte, byte, byte);
dword __carga_CR3(dword,dword);
void __pagina_rom(void);
void __clean_dir(bits16,dword*);
void __levanto_pagina(void);