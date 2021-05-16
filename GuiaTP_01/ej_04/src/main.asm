section .kernel32
USE32
GLOBAL kernel32_code_size
GLOBAL kernel32_init

kernel32_init:

    xchg bx,bx          ;MB(5)
    nop
    nop
    .guard:
    hlt
    jmp .guard