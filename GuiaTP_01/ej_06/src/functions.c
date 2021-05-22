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

/*Función para pushear dentro del ring buffer de teclado*/
__attribute__(( section(".functions"))) void ring_buffer_push(ring_buffer* rb_p,byte tecla_recibida)
{
    rb_p->buffer[rb_p->progreso]=tecla_recibida;
    rb_p->cola=(byte*)(rb_p->buffer+rb_p->progreso);  
    rb_p->progreso++;
    if(rb_p->progreso == rb_p->longitud)
    {
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
        __ring_buffer_clear((ring_buffer*) &__DATOS_VMA);       
        break;
        }
    default:
        break;
    }
    
}

