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
EXTERN CS_SEL_32
EXTERN __TECLADO_ISR_VMA

GLOBAL data_teclado
GLOBAL cr2_ram

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
EXTERN task01_main
EXTERN __tiempo_iniciar
EXTERN __DATOS_TIMER_VMA_LIN
EXTERN __DATOS_SCH_VMA_LIN

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


    ciclo:
        hlt
        ;poolea la tarea 1 viendo si fue llamada por el scheduler
        push __DATOS_SCH_VMA_LIN
        push __DIGITOS_VMA_LIN
        call task01_main
        add esp,8        
        jmp ciclo

section .data
USE32
reserva_buffer:
times 36 db 0x00

times 12 db 0x00

data_teclado: ; lo cargo en 0x00210030
db 0xFF

reserva_out:
times 15 db 0x00
times 16 db 0x00

reserva_ram_timer:
times 16 db 0x00

reserva_ram_promedio:
times 16 db 0x00

reserva_ram_sch:
times 16 db 0x00

reserva_ram_conv:
times 16 db 0x00

cr2_ram:
db 0xFF
times 16 db 0x00


