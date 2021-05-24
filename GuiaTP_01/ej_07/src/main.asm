EXTERN CS_SEL_32
EXTERN __TECLADO_ISR_VMA

GLOBAL data_teclado
GLOBAL data_timer

GLOBAL Head_Pointer
GLOBAL Tail_Pointer

GLOBAL kernel32_code_size
GLOBAL kernel32_init
EXTERN pool_teclado
EXTERN __completa_ring_buffer
EXTERN __DATOS_VMA
EXTERN __DIGITOS_VMA  
EXTERN __ring_buffer_init
EXTERN __ring_buffer_clear
EXTERN tabla_digitos_init
EXTERN __VIDEO_VGA
EXTERN __screen_buffer_init
EXTERN task01_main
EXTERN __tiempo_iniciar
EXTERN __DATOS_TIMER_VMA
EXTERN __DATOS_SCH_VMA

section .kernel32
USE32

%include "inc/utils.h"

kernel32_init:
    
    xor eax,eax
    xor ebx,ebx
    xor ecx,ecx
    xor edx,edx

    push __DATOS_VMA
    call __ring_buffer_init
    add esp,4

    push __DATOS_VMA
    call __ring_buffer_clear        
    add esp,4
    
    push __DIGITOS_VMA
    call tabla_digitos_init        
    add esp,4

    push __VIDEO_VGA
    call __screen_buffer_init         
    add esp,4

    push __DATOS_TIMER_VMA ;ocupa desde 0x210050 - 0x210056
    call __tiempo_iniciar
    add esp,4

   ; push __DATOS_SCH_VMA
   ; push __DIGITOS_VMA
   ; call task01_main
   ; add esp,8

    ciclo:
        hlt
        push __DATOS_SCH_VMA
        push __DIGITOS_VMA
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

