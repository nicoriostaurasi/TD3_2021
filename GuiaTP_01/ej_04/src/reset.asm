USE16                  ;decodifica el codigo para instrucciones de 16 bits

EXTERN start16
GLOBAL reset

section .resetVector


reset:
    cli                  ;clear interrupts
    cld                  ;clear directions para la copia de memoria
    jmp start16
    halted:
        hlt
        jmp halted

;ALIGN 16
end: