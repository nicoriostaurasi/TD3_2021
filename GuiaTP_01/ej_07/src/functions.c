#include "../inc/functions.h"

/*Función de copia en memoria para utilizar desde RAM*/
__attribute__(( section(".functions"))) byte __fast_memcpy(dword* src,dword *dst,dword length)
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

/*Funcion de inicio a Systick timer*/
__attribute__(( section(".functions")))void __tiempo_iniciar(tiempos* tp)
{
    tp->base=0x00;//en nuestro caso 100mS
    tp->milisegundos=0x0000;
    tp->segundos=0x00;
    tp->minutos=0x00;
    tp->horas=0x00;
}

/*Funcion para manejar distintas tareas*/
__attribute__(( section(".functions"))) void __Scheduler_Handler(byte Tarea,sch_buffer* sc_p)
{
    if(Tarea==TAREA_1)
    {
        sc_p->Tarea1=0x01;
    }
}

/*Funcion de handler de Systick*/
__attribute__(( section(".functions"))) void __Systick_Handler(tiempos* tp) 
{
    tp->base++;
    if(tp->base>=5)
    {   
        __Scheduler_Handler(TAREA_1,(sch_buffer*)&__DATOS_SCH_VMA);
        tp->base=0x00;
        tp->milisegundos=tp->milisegundos+5;
        if(tp->milisegundos>=1000)
        {
            tp->milisegundos=0x0000;
            tp->segundos++;
            if(tp->segundos>=60)
            {
                tp->segundos=0x00;
                tp->minutos++;
                if(tp->minutos>=60)
                {
                    tp->minutos=0x00;
                    tp->horas++;
                    if(tp->horas>=24)
                    {
                        tp->horas=0x00;
                    }
                }    
            }
        }
    }
}

/*Función de carga de GDT*/
__attribute__(( section(".functions"))) void __carga_GDT(dword offsetGDT,
                                                        dword base,
                                                        dword limite,
                                                        dword atributos)
{
//asm("xchg %%bx,%%bx"::);
*(&__SYS_TABLES_32_VMA+2*offsetGDT)=(limite & 0x0000FFFF)|((base & 0x0000FFFF)<<16) ; // parte baja - parte alta
*((&__SYS_TABLES_32_VMA+2*offsetGDT)+1)=((base & 0x00FF0000)>>16)|((atributos & 0x000000FF)<<8)|(limite & 0x000F0000)|((atributos & 0x000000F00)<<12)|(base & 0xFF000000);
}

/*Funcion de carga de IDT*/
__attribute__(( section(".functions"))) void __carga_IDT(dword offsetIDT,
                                                        dword selector,
                                                        dword atributos,
                                                        dword offset)
{
*((&__SYS_TABLES_32_VMA+2*CANT_GDTS+2*offsetIDT))=(offset&0x00000FFFF)|((selector&0x0000FFFF)<<16); // parte baja - parte alta
*((&__SYS_TABLES_32_VMA+2*CANT_GDTS+2*offsetIDT)+1)=((atributos & 0x000000FF)<<8)|(offset&0xFFFF0000);
}

/*Funcion para inicializar la tabla de digitos*/
__attribute__(( section(".functions"))) void tabla_digitos_init(tabla_digitos* td_p)
{
    
    static int i=0;
    //asm("xchg %%bx,%%bx"::);
    td_p->promedio=0x00; //FFFF_FFFF_FFFF_FFFF
    //asm("xchg %%bx,%%bx"::);
    td_p->indice=0x00;
    for(i=0;i<CANT_DIGITOS;i++)
    {
        td_p->digito[i]=0x00;
    }
}

/*Funcion para ingresar un numero en la tabla*/
__attribute__(( section(".functions"))) void tabla_digitos_completar(tabla_digitos* td_p,bits64 dato_alto,bits64 dato_bajo)
{   
    static bits64 aux=0;
    static bits64 exponente=1;
    static int i=0;
    
    exponente=1;
    aux=0;

    for(i=0;i<8;i++)
    {
    aux=aux+exponente*((dato_bajo>>(8*i)) & 0xFF);
    exponente=exponente*10;
    }

    for(i=0;i<8;i++)
    {
    aux=aux+exponente*((dato_alto>>(8*i)) & 0xFF);
    exponente=exponente*10;
    }
    td_p->digito[td_p->indice]=aux;
    td_p->indice++;

    if(td_p->indice>=CANT_DIGITOS)
    td_p->indice=0;

}

/*Funcion para inicializar el ring buffer de teclado*/
__attribute__(( section(".functions"))) void __ring_buffer_init(ring_buffer* rb_p)
{
    rb_p->tam_elemento = sizeof(byte);
    rb_p->longitud=LONG_BUFFER*(rb_p->tam_elemento);
    rb_p->longitud_en_bytes=(rb_p->longitud)*(rb_p->tam_elemento);
    rb_p->inicio=rb_p->buffer;
    rb_p->fin=(byte*)(rb_p->buffer+LONG_BUFFER-1);
    rb_p->progreso=0;
    rb_p->cabeza=rb_p->inicio;
    rb_p->cola=rb_p->inicio;
}

/*Funcion para limpiar el ring buffer de teclado*/
__attribute__(( section(".functions"))) void __ring_buffer_clear(ring_buffer* rb_p)
{
    static int i=0;
    rb_p->progreso=0;
    rb_p->cola=rb_p->inicio;

    for(i=0;i<rb_p->longitud;i++)
    {
    rb_p->buffer[i]=0x00;
    }
}

/*Funcion para preparar el pase a tabla_digitos_completar*/
__attribute__(( section(".functions"))) void sup_tabla_digitos_completar(ring_buffer* rb_p)
{
    static bits64 parte_baja=0x0000000000000000;
    static bits64 parte_alta=0x0000000000000000;
    static int i=0;
    parte_alta=0x0000000000000000;
    parte_baja=0x0000000000000000;
    
    for(i=0;i<8;i++)
    {
    parte_baja = (byte)rb_p->buffer[7-i] | (parte_baja<<8);
    }
    for(i=0;i<8;i++)
    {
    parte_alta =  (byte)rb_p->buffer[15-i] | (parte_alta<<8);
    }

    tabla_digitos_completar( (tabla_digitos*)&__DIGITOS_VMA, parte_alta,parte_baja);
    //asm("xchg %%bx,%%bx"::);
}

/*Función para pushear dentro del ring buffer de teclado*/
__attribute__(( section(".functions"))) void ring_buffer_push(ring_buffer* rb_p,byte tecla_recibida)
{
    static int i=0;

    for(i=0;i<LONG_BUFFER-1;i++)
    {
        rb_p->buffer[LONG_BUFFER-1-i]=rb_p->buffer[LONG_BUFFER-2-i];
    }
    
    rb_p->buffer[0]=tecla_recibida;
    
    rb_p->cola=(byte*)(rb_p->buffer+LONG_BUFFER-1-rb_p->progreso);  
    
    rb_p->progreso++;

    if(rb_p->progreso == rb_p->longitud)
    {
    sup_tabla_digitos_completar((ring_buffer*)&__DATOS_VMA);
    __ring_buffer_clear((ring_buffer*) &__DATOS_VMA);
    }
}

/*Función para chequear que la tecla ingresada sea valida*/
__attribute__(( section(".functions"))) void __chequeo_tecla(byte tecla)
{
    tecla=(0x000000FF)&tecla;
    switch (tecla)
    {
    case TECLA_0:
        {
        ring_buffer_push((ring_buffer*) &__DATOS_VMA,0x00);
        break;
        }

    case TECLA_1:
        {
        ring_buffer_push((ring_buffer*) &__DATOS_VMA,0x01);
        break;
        }
    case TECLA_2:
        {
        ring_buffer_push((ring_buffer*) &__DATOS_VMA,0x02);
        break;
        }
    case TECLA_3:
        {
        ring_buffer_push((ring_buffer*) &__DATOS_VMA,0x03);

        break;
        }
   case TECLA_4:
        {
        ring_buffer_push((ring_buffer*) &__DATOS_VMA,0x04);

       // asm("xchg %%bx,%%bx"::);
        break;
        }
    case TECLA_5:
        {

        ring_buffer_push((ring_buffer*) &__DATOS_VMA,0x05);
       // asm("xchg %%bx,%%bx"::);
        break;
        }
    case TECLA_6:
        {

        ring_buffer_push((ring_buffer*) &__DATOS_VMA,0x06);
       // asm("xchg %%bx,%%bx"::);
        break;
        }
    case TECLA_7:
        {

        ring_buffer_push((ring_buffer*) &__DATOS_VMA,0x07);
       // asm("xchg %%bx,%%bx"::);
        break;
        }
    case TECLA_8:
        {
       // asm("xchg %%bx,%%bx"::);

        ring_buffer_push((ring_buffer*) &__DATOS_VMA,0x08);
        break;
        }
    case TECLA_9:
        {
       // asm("xchg %%bx,%%bx"::);

        ring_buffer_push((ring_buffer*) &__DATOS_VMA,0x09);
        break;
        }
    case TECLA_ENTER:
        {
        sup_tabla_digitos_completar((ring_buffer*)&__DATOS_VMA);
        __ring_buffer_clear((ring_buffer*) &__DATOS_VMA);       
        break;
        }
    default:
        break;
    }
    
}

/*Función para inicializar buffer de pantalla*/
__attribute__(( section(".functions"))) void __screen_buffer_init(screen_buffer *sb_p)
{
    //buffer[25][80]
    //buffer[F][C]
    static int i=0;
    static int j=0;
    for(i=0;i<25;i++)//Filas
    {
        for(j=0;j<80;j++)//columnas
        {
        sb_p->buffer[i][j]=0x0F00;//inicializo todo en caracteres blanco
        }
    }
     __screen_buffer_print(5,1,sb_p,"Ejercicio N#7 - Rutina Temporizada y Controladora de video",58);
     __screen_buffer_print(5,10,sb_p,"Promedio: 0x",12);
     __screen_buffer_print(5,22,sb_p,"Rios Taurasi Nicolas - TD3 UTN FRBA - CL 2021",45);
     
//     task_show_VGA();     
}

/*Funcion para escribir un caracter unicamente*/
__attribute__(( section(".functions"))) void __screen_buffer_printc(byte X,byte Y,screen_buffer *sb_p,char caracter)
{
    static byte inY=0;
    static byte inX=0;
    inY=Y;
    inX=X;
    sb_p->buffer[inY][inX]=0x0F00|(caracter & 0xFF);
}


/*Función para escribir ciertos pixeles de pantalla*/
__attribute__(( section(".functions"))) void __screen_buffer_print(byte inicioX,byte inicioY,screen_buffer *sb_p,char* buffer,byte caracteres)
{
    static byte inY=0;
    static byte inX=0;
    static int i=0;
    inY=inicioY;
    inX=inicioX;
    for(i=0;i<caracteres;i++)
    {
    sb_p->buffer[inY][inX+i]=sb_p->buffer[inY][inX+i]|(buffer[i] & 0xFF);
    }
}
