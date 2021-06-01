#include "../inc/task01.h"

/*Funcion Principal*/
__attribute__(( section(".functions_task01"))) void task01_main(tabla_digitos* td_p,sch_buffer* sc_p)
{
    if(sc_p->Tarea1 == 0x01)
    {
    task_promedio(td_p);
    task_show_VGA(td_p);
    task_show_time((tiempos*) &__DATOS_TIMER_VMA);    
    sc_p->Tarea1 = 0x00;
    }
}

__attribute__(( section(".functions_task01"))) void task_show_time(tiempos* t_p)
{
    static byte seg,min,hor;
    static byte aux;
    static byte i;
    seg=t_p->segundos;
    
    __screen_buffer_print(47,24,(screen_buffer*) &__VIDEO_VGA,"Tiempo de ejecucion:",20);

    for(i=0;i<2;i++)
    {
    aux=seg%10;
    seg=seg/10;
    __screen_buffer_printc(75-i,24,(screen_buffer*) &__VIDEO_VGA,aux+48);
    }
    __screen_buffer_printc(73,24,(screen_buffer*) &__VIDEO_VGA,':');
    min=t_p->minutos;
    for(i=0;i<2;i++)
    {
    aux=min%10;
    min=min/10;
    __screen_buffer_printc(72-i,24,(screen_buffer*) &__VIDEO_VGA,aux+48);
    }
    __screen_buffer_printc(70,24,(screen_buffer*) &__VIDEO_VGA,':');
    hor=t_p->horas;
    for(i=0;i<2;i++)
    {
    aux=hor%10;
    hor=hor/10;
    __screen_buffer_printc(69-i,24,(screen_buffer*) &__VIDEO_VGA,aux+48);
    }

}


__attribute__(( section(".functions_task01"))) void task_show_VGA_64(tabla_digitos* td_p)
{
    static byte aux=0;    
    static bits64 palabra_aux_resto,palabra_aux_div;
    static int i=0;
    static data_conv* dc_p;
    dc_p=(data_conv*)(&__DATOS_CONVERSION_VMA);
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

    __screen_buffer_printc(16+5+11-i,13,(screen_buffer*) &__VIDEO_VGA,aux+48);
    aux=0;
    }
}
 /*Funcion que divide operandos de 64*/
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
    data_conv* dc_p;
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
        dc_p=(data_conv*)(&__DATOS_CONVERSION_VMA);
        dc_p->dividendo=0x0000000000000000;
        dc_p->divisor=0x0000000000000000;
        dc_p->resultado=0x0000000000000000;
        dc_p->dividendo=td_p->sumatoria;
        dc_p->divisor=td_p->indice;
        my_division64(dc_p);
        td_p->promedio=dc_p->resultado;
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
