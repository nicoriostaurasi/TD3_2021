BITS 16
GLOBAL Reset
EXTERN Init16

SECTION .Reset
Reset:  ;0xfffffff0
    cli  ;  FFFFFFF1 (1)
    jmp Init16; FFFF FFF3 (2)
    ALIGN 16