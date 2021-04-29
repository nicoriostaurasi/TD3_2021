USE16
section .resetVector

EXTERN start16
GLOBAL reset

reset:
    cli
    cld
    jmp start16
    halted:
        hlt
        jmp halted
end: