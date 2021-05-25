#include "../inc/task01.h"

/*Funcion Principal*/
__attribute__(( section(".functions_task01"))) void task01_main(tabla_digitos* td_p,sch_buffer* sc_p)
{
    if(sc_p->Tarea1 == 0x01)
    {
    task_promedio(td_p);
    task_show_VGA(td_p);    
    sc_p->Tarea1 = 0x00;
    }
}

/*Funcion que recibe el dato de 64 bits y lo dibuja en pantalla*/
__attribute__(( section(".functions_task01"))) void task_show_VGA(tabla_digitos* td_p)
{
    static dword parte_alta=0,parte_baja=0; //palabras de 32 bits
    static byte aux=0;
    static int i=0;
    parte_alta=(td_p->promedio & 0xFFFFFFFF00000000)>>32;
    parte_baja=(td_p->promedio) & 0x00000000FFFFFFFF;
    for(i=0;i<8;i++)
    {
    aux=parte_baja%16;
    parte_baja=parte_baja/16;
    if(aux>=10)
    {
    aux=aux+7;
    }
    __screen_buffer_printc(16+5+11-i,10,(screen_buffer*) &__VIDEO_VGA,aux+48);
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
    __screen_buffer_printc(8+5+11-i,10,(screen_buffer*) &__VIDEO_VGA,aux+48);
    }
}



__attribute__(( section(".functions_task01"))) void task_promedio(tabla_digitos* td_p)
{
    /*acumula y promedia*/
    static int i=0;
    td_p->promedio=0x0000000000000000;
    td_p->sumatoria=0x0000000000000000;
    for(i=0;i<td_p->indice;i++)
    {
    td_p->sumatoria=td_p->sumatoria+td_p->digito[i];
    }
    if(td_p->indice == 0)
    {
        td_p->promedio=0x00;
    }
    else
    {
        my_division64_promedio(td_p);
    }
}

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
