;/**
; * @file main.asm
; * @author Nicolas Rios Taurasi (nicoriostaurasi@frba.utn.edu.ar)
; * @brief Flujo principal
; * @version 1.1
; * @date 01-06-2021
; * 
; * @copyright Copyright (c) 2021
; * 
; */

GLOBAL data_teclado
GLOBAL cr2_ram_main
GLOBAL direccion_carga_local_main

GLOBAL kernel32_code_size
GLOBAL kernel32_init
EXTERN pool_teclado
EXTERN __completa_ring_buffer
EXTERN __DATOS_VMA_LIN
EXTERN __DIGITOS_VMA_LIN  
EXTERN __ring_buffer_init
EXTERN __ring_buffer_clear
EXTERN tabla_digitos_init
EXTERN __VIDEO_VGA_LIN
EXTERN __screen_buffer_init
EXTERN __tiempo_iniciar
EXTERN __DATOS_TIMER_VMA_LIN
EXTERN __DATOS_SCH_VMA_LIN
EXTERN __MEMORIA_FISICA_DINAMICA
EXTERN __Scheduler_init
EXTERN __DATOS_SCH_VMA_LIN
EXTERN __TSS_INIT
EXTERN __TSS_SYS_INIT
EXTERN TSS_SEL
EXTERN __TSS_TASK_01_LIN
EXTERN __STACK_END_32_T1

section .kernel32
USE32

%include "inc/utils.h"
%include "inc/processor-flags.h"

kernel32_init:

    ;reinicio los GPR
    xor eax,eax
    xor ebx,ebx
    xor ecx,ecx
    xor edx,edx
 
    ;Inicio la direccion de carga dinamica como lo pide el enunciado
    mov dword [direccion_carga_local_main],__MEMORIA_FISICA_DINAMICA
        
    ;Inicializo el ring buffer
    push __DATOS_VMA_LIN
    call __ring_buffer_init
    add esp,4
    
    ;Limpio el ring buffer
    push __DATOS_VMA_LIN
    call __ring_buffer_clear        
    add esp,4

    ;Inicio los digitos
    push __DIGITOS_VMA_LIN
    call tabla_digitos_init        
    add esp,4

    ;Inicio la pantalla
    push __VIDEO_VGA_LIN
    call __screen_buffer_init         
    add esp,4

    ;Inicio la estructura de tiempo
    push __DATOS_TIMER_VMA_LIN ;ocupa desde 0x210050 - 0x210056
    call __tiempo_iniciar
    add esp,4
    
    ;Inicio la estructura de Scheduler
    push __DATOS_SCH_VMA_LIN  
    call __Scheduler_init
    add esp,4   


    ;Inicio las TSS
    call __TSS_INIT
    call __TSS_SYS_INIT

    xor eax,eax
    mov ax,TSS_SEL
    ltr ax

    mov byte[TareaActual],255

    ;Descomentar para ver la generacion de faltas
    ;jmp pool_teclado

    mov ebp,esp
    sti
    hlt        

    idle_kernel:
        hlt
    jmp idle_kernel

section .data
USE32
reserva_buffer:
times 36 db 0x00

times 12 db 0x00

data_teclado: ; lo cargo en 0x00200030
db 0xFF

reserva_out:
times 15 db 0x00
times 16 db 0x00

reserva_ram_timer:
times 16 db 0x00

reserva_ram_promedio:
times 16 db 0x00

reserva_ram_sch:
times 32 db 0x00

reserva_ram_conv:
times 16 db 0x00
times 16 db 0x00
times 16 db 0x00

times 64 db 0x00

direccion_carga_local_main:
dd 0x0A000000
;times 16 db 0x00
align 32
cr2_ram_main:
dd 0x00000000
align 32


GLOBAL ContadorTarea2,ContadorTarea1,ContadorTarea3,TareaActual,TareaProxima
ContadorTarea1:
db 0x00
align 32
ContadorTarea2:
db 0x00
align 32
ContadorTarea3:
db 0x00
align 32
TareaActual:
db 0x00
align 32
TareaProxima:
db 0x00
align 32

GLOBAL tarea_1_falla
section .functions_task01
    tarea_1_falla:
    mov dword[0x0121000F],0xFFFF
