USE16

EXTERN start16

section .resetVector
inicio:                          
        cli                  ;clear interrupts
        cld                  ;clear directions para la copia de memoria
        jmp start16
    halted:
        hlt
        jmp halted

align 16
;resetVector_size EQU $ - inicio