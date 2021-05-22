EXTERN CS_SEL_32
EXTERN __TECLADO_ISR_VMA

GLOBAL kernel32_code_size
GLOBAL kernel32_init
EXTERN pool_teclado

section .kernel32
USE32

kernel32_init:
    
 ;  xchg bx,bx
    xor eax,eax
    xor ebx,ebx
    xor ecx,ecx
    xor edx,edx
    jmp pool_teclado
    ciclo
        nop
        jmp ciclo


    bloqueado:
        hlt
        jmp bloqueado