#include "functions.h"

void __Systick_Handler(tiempos*);
void __Scheduler_Handler(sch_buffer*);
void __Scheduler_init(sch_buffer*);
void guardar_contexto(sch_buffer*);
void guardar_contexto_especifico(sch_buffer*);
void cambiar_tarea(sch_buffer*);
