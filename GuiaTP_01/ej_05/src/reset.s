USE16                  ;decodifica el codigo para instrucciones de 16 bits
section .resetVector

EXTERN start16
GLOBAL reset

reset:
    cli                  ;clear interrupts
    cld                  ;clear directions para la copia de memoria
    jmp start16
    halted:
        hlt
        jmp halted
end:
