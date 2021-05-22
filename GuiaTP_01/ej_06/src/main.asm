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
EXTERN __ring_buffer_init
EXTERN __ring_buffer_clear

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


    ciclo:
        jmp ciclo
    bloqueado:
        hlt
        jmp bloqueado


section .data



USE32
times 25 dq 0x00

data_teclado:
db 0xFF

times 15 db 0x00
 
data_timer:
dw 0x0000

times 7 dw 0x0000
