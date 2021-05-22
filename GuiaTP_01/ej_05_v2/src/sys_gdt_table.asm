;GLOBAL NULL_SEL_1
;GLOBAL  CS_SEL_32_1
;GLOBAL  DS_SEL_32_1
;GLOBAL  _gdtr

SECTION .sys_table_gdt_32
;GDT:
;NULL_SEL_1    equ $-GDT
;    dq 0x0
;CS_SEL_32_1   equ $-GDT   ;Segmento de Codigo de 32 bits
    ;dq 0x0
                        ;Base: 0x0000FFFF
                        ;Limite: 0xFFFFF  = 1MB
;    dw 0xFFFF           ;Limit 15-0
;    dw 0x0000           ;Base 15-0
;    db 0x00             ;Base 23-16
;    db 10011001b        ;Atributos:
                        ;P=1 Presente en el segmento
                        ;DPL=00 Privilegio nivel 0 - Kernel
                        ;S=1 Descriptor de Codigo/Datos
                        ;D/C=1 Segmento de Codigo 
                        ;C=0 No puede ser invocado
                        ;R=0 No legible
                        ;A=1 por defecto Accedido
;    db 11001111b        ;G=1 Maximo offset = Limite*0x1000+0xFFF
                        ;D/B=1 Big, Segmento de 32
                        ;L=0 No 64 bits nativo
                        ;AVL=0 No utilizado
                        ;Limit 19-16
;    db 0x00             ;Base 31-24
;DS_SEL_32_1   equ $-GDT   ;Segmento de Datos
    ;dq 0x0
                        ;Base: 0x00000000
                        ;Limite: 0xFFFFF = 1MB
;    dw 0xFFFF           ;Limit 15-0
;    dw 0x0000           ;Base 15-0
;    db 0x00             ;Base 23-16
;    db 10010010b        ;Atributos:
                        ;P=1 Presente en el segmento
                        ;DPL=00 Privilegio nivel 0 - Kernel
                        ;S=1 Descriptor de Codigo/Datos
                        ;D/C=0 Segmento de Datos 
                        ;ED=0 Segmento de datos comun
                        ;W=1 Escribible
                        ;A=0 por defecto No Accedido
;    db 11001111b        ;G=1 Maximo offset = Limite*0x1000+0xFFF
                        ;D/B=1 Big, Segmento de 32
                        ;L=0 No 64 bits nativo
                        ;AVL=0 No utilizado
                        ;Limit 19-16
;    db 0x00             ;Base 31-24
;GDT_LENGTH EQU $-GDT
;_gdtr:
;    dw GDT_LENGTH-1
;    dd GDT