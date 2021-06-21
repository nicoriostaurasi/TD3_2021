/**
 * @file timer.c
 * @author Nicolas Rios Taurasi (nicoriostaurasi@frba.utn.edu.ar)
 * @brief Contiene las rutinas de Timer
 * @version 0.1
 * @date 14-06-2021
 * 
 * @copyright Copyright (c) 2021
 * 
 */

#include "../inc/scheduler.h"

//----------------------------------------------------------
//                   TIMER
//----------------------------------------------------------

/*----------------------------------------------------------
 * __tiempo_iniciar
 * __Systick_Handler
 *----------------------------------------------------------*/

/**
 * @brief Funcion de inicio a Systick timer
 * @return nada
 * @param tiempos* tp, VMA de la Estructura de Timer
 */
__attribute__((section(".functions"))) void __tiempo_iniciar(tiempos *tp)
{
    tp->base = 0x00; //en nuestro caso 100mS
    tp->milisegundos = 0x0000;
    tp->segundos = 0x00;
    tp->minutos = 0x00;
    tp->horas = 0x00;
}

/**
 * @brief Funcion de handler de Systick
 * @return nada
 * @param tiempos* tp, VMA de la Estructura de Tiempos 
 */
__attribute__((section(".functions"))) void __Systick_Handler(tiempos *tp)
{

    tp->base++;
//    asm("xchg %%bx,%%bx"::);
//    __Scheduler_Handler((sch_buffer *)&__DATOS_SCH_VMA_LIN);

    if (tp->base >= 50)
    {
       // __Scheduler_Handler(TAREA_1, (sch_buffer *)&__DATOS_SCH_VMA_LIN);
       // __Scheduler_Handler(TAREA_2, (sch_buffer *)&__DATOS_SCH_VMA_LIN);
        tp->base = 0x00;
        tp->milisegundos = tp->milisegundos + 5;
        if (tp->milisegundos >= 1000)
        {
            tp->milisegundos = 0x0000;
            tp->segundos++;
            if (tp->segundos >= 60)
            {
                tp->segundos = 0x00;
                tp->minutos++;
                if (tp->minutos >= 60)
                {
                    tp->minutos = 0x00;
                    tp->horas++;
                    if (tp->horas >= 24)
                    {
                        tp->horas = 0x00;
                    }
                }
            }
        }
    }
}

//----------------------------------------------------------
//                   SCHEDULER
//----------------------------------------------------------

/*----------------------------------------------------------
 * __Scheduler_Handler
 *----------------------------------------------------------*/

/**
 * @brief Funcion para manejar distintas tareas
 * @return nada
 * @param byte Tarea
 * @param sch_buffer* sc_p, VMA de la Estructura de Scheduler
 */
__attribute__((section(".functions"))) void __Scheduler_Handler(sch_buffer *sc_p)
{
 //     asm("xchg %%bx,%%bx"::);
      sc_p->ContadorTarea1++;
      sc_p->ContadorTarea2++;

      if( sc_p->ContadorTarea2<=20 && sc_p->ContadorTarea2<=50 )
      {
      sc_p->TareaProxima = TAREA_4;
      guardar_contexto(sc_p);          
      }

      if(sc_p->ContadorTarea2>=20)
      {
      //asm("xchg %%bx,%%bx"::);
      sc_p->TareaProxima = TAREA_2;
      sc_p->ContadorTarea2=0;
      guardar_contexto(sc_p);
      }

      if(sc_p->ContadorTarea1>=50)
      {
     // asm("xchg %%bx,%%bx"::);
      sc_p->TareaProxima = TAREA_1;
      sc_p->ContadorTarea1=0;
      guardar_contexto(sc_p);
      }
}

__attribute__((section(".functions"))) void __Scheduler_init(sch_buffer *sc_p)
{
    sc_p->TareaActual=TAREA_1;
}

__attribute__((section(".functions"))) void guardar_contexto(sch_buffer* sc_p)
{
//   asm("xchg %%bx,%%bx"::);
   if(sc_p->TareaActual == sc_p->TareaProxima)
   {
       //no hago nada me tengo que ir de la interrupcion
   }
   else
   {
/*       asm("xchg %%bx,%%bx"::);
       asm("nop"::);
       asm("nop"::);
       asm("nop"::);
       asm("nop"::);
       asm("xchg %%bx,%%bx"::);
  */  
       guardar_contexto_especifico(sc_p);
   }
}

__attribute__((section(".functions"))) void guardar_contexto_especifico(sch_buffer* sc_p)
{
//    asm("xchg %%bx,%%bx"::);
    if( (sc_p->TareaActual) == TAREA_1 )
    {
//    asm("xchg %%bx,%%bx"::);
 //   guardar_contexto_tarea_1();
    cambiar_tarea(sc_p);
    }
    
    if( (sc_p->TareaActual) == TAREA_2)
    {
//    guardar_contexto_tarea_2();
    cambiar_tarea(sc_p);
    }

    if( (sc_p->TareaActual) == TAREA_4)
    {
//    guardar_contexto_tarea_4();
    cambiar_tarea(sc_p);
    }
    
}

__attribute__((section(".functions"))) void cambiar_tarea(sch_buffer* sc_p)
{
 //   asm("xchg %%bx,%%bx"::);

    if( (sc_p->TareaProxima) == TAREA_1 )
    {
//    asm("xchg %%bx,%%bx"::);
//    cargar_contexto_tarea_1();
    }
    
    if( (sc_p->TareaProxima) == TAREA_2)
    {
  //  asm("xchg %%bx,%%bx"::);

//    cargar_contexto_tarea_2();
    }

    if( (sc_p->TareaProxima) == TAREA_4)
    {
//    asm("xchg %%bx,%%bx"::);
    
//    cargar_contexto_tarea_4();
    }
    sc_p->TareaActual = sc_p->TareaProxima;
}