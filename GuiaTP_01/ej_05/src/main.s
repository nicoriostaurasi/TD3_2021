section .kernel32
USE32
GLOBAL kernel32_code_size
GLOBAL kernel32_init

kernel32_code_size EQU (kernel32_end-kernel32_init)

kernel32_init:


    .guard
    hlt
    jmp .guard

kernel32_end: