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
    /*por ahora solo acumula, despues promediare*/
    static int i=0;
    td_p->promedio=0x0000000000000000;
    //td_p->promedio=0xFFFFFFFFFFFFFFFF;
    for(i=0;i<td_p->indice;i++)
    {
    td_p->promedio=td_p->promedio+td_p->digito[i];
    }
}
/*
D->t



*/