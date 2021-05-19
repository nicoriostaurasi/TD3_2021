EXTERN  EXCEPTION_DUMMY
GLOBAL  CS_SEL_16
GLOBAL  CS_SEL_32
GLOBAL  DS_SEL_16
GLOBAL  DS_SEL_32
GLOBAL  _gdtr
GLOBAL  _idtr
GLOBAL  _gdtr16


EXTERN ISR_Baja
EXTERN ISR00_Handler_DE_off
EXTERN ISR00_Handler_DE

EXTERN ISR02_Handler_NMI_off
EXTERN ISR03_Handler_BP_off
EXTERN ISR04_Handler_OF_off
EXTERN ISR05_Handler_BR_off
EXTERN ISR06_Handler_UD_off
EXTERN ISR07_Handler_NM_off
EXTERN ISR08_Handler_DF_off

EXTERN ISR10_Handler_TS_off
EXTERN ISR11_Handler_NP_off
EXTERN ISR12_Handler_SS_off
EXTERN ISR13_Handler_GP_off
EXTERN ISR14_Handler_PF_off

EXTERN ISR16_Handler_MF_off
EXTERN ISR17_Handler_AC_off
EXTERN ISR18_Handler_MC_off
EXTERN ISR19_Handler_XM_off


%define BOOT_SEG 0xF0000
SECTION .sys_table_gdt_16
GDT16:
NULL_SEL_16    equ $-GDT16
    dq 0x0
CS_SEL_16   equ $-GDT16   ;Segmento de Codigo de 16 bits
                        ;Base: 0xFFFF0000
                        ;Limite: 0x0FFFF  = 64KB 
    dw 0xFFFF           ;Limit 15-0
    dw 0x0000           ;Base 15-0
    db 0x00             ;Base 23-16
    db 10011010b        ;Atributos:
                        ;P=1 Presente en el segmento
                        ;DPL=00 Privilegio nivel 0 - Kernel
                        ;S=1 Descriptor de Codigo/Datos
                        ;D/C=1   Segmento de Codigo 
                        ;C=0 No puede ser invocado
                        ;R=1 No legible
                        ;A=0 por defecto No Accedido
    db 11001111b        ;G=1 Maximo offset = Limite*0x1000+0xFFF
                        ;D/B=1 Big, segmento de 32 bits
                        ;L=0 No 64 bits nativo
                        ;AVL=0 No utilizado
                        ;Limit 19-16
    db 0x00             ;Base 31-24
DS_SEL_16   equ $-GDT16   ;Segmento de Datos
                        ;Base: 0x00000000
                        ;Limite: 0xFFFFF = 1MB
    dw 0xFFFF           ;Limit 15-0
    dw 0x0000           ;Base 15-0
    db 0x00             ;Base 23-16
    db 10010010b        ;Atributos:
                        ;P=1 Presente en el segmento
                        ;DPL=00 Privilegio nivel 0 - Kernel
                        ;S=1 Descriptor de Codigo/Datos
                        ;D/C=0 Segmento de Datos 
                        ;ED=0 Segmento de datos comun
                        ;W=1 Escribible
                        ;A=0 por defecto No Accedido
    db 11001111b        ;G=1 Maximo offset = Limite*0x1000+0xFFF
                        ;D/B=1 Big, Segmento de 32
                        ;L=0 No 64 bits nativo
                        ;AVL=0 No utilizado
                        ;Limit 19-16
    db 0x00             ;Base 31-24
GDT16_LENGTH EQU $-GDT16
_gdtr16:
    dw GDT16_LENGTH-1
    dd 0x000FFD00

SECTION .sys_table_gdt_32

GDT:
NULL_SEL    equ $-GDT
    dq 0x0
CS_SEL_32   equ $-GDT   ;Segmento de Codigo de 32 bits
                        ;Base: 0x0000FFFF
                        ;Limite: 0xFFFFF  = 1MB
    dw 0xFFFF           ;Limit 15-0
    dw 0x0000           ;Base 15-0
    db 0x00             ;Base 23-16
    db 10011001b        ;Atributos:
                        ;P=1 Presente en el segmento
                        ;DPL=00 Privilegio nivel 0 - Kernel
                        ;S=1 Descriptor de Codigo/Datos
                        ;D/C=1 Segmento de Codigo 
                        ;C=0 No puede ser invocado
                        ;R=0 No legible
                        ;A=1 por defecto Accedido
    db 11001111b        ;G=1 Maximo offset = Limite*0x1000+0xFFF
                        ;D/B=1 Big, Segmento de 32
                        ;L=0 No 64 bits nativo
                        ;AVL=0 No utilizado
                        ;Limit 19-16
    db 0x00             ;Base 31-24
DS_SEL_32   equ $-GDT   ;Segmento de Datos
                        ;Base: 0x00000000
                        ;Limite: 0xFFFFF = 1MB
    dw 0xFFFF           ;Limit 15-0
    dw 0x0000           ;Base 15-0
    db 0x00             ;Base 23-16
    db 10010010b        ;Atributos:
                        ;P=1 Presente en el segmento
                        ;DPL=00 Privilegio nivel 0 - Kernel
                        ;S=1 Descriptor de Codigo/Datos
                        ;D/C=0 Segmento de Datos 
                        ;ED=0 Segmento de datos comun
                        ;W=1 Escribible
                        ;A=0 por defecto No Accedido
    db 11001111b        ;G=1 Maximo offset = Limite*0x1000+0xFFF
                        ;D/B=1 Big, Segmento de 32
                        ;L=0 No 64 bits nativo
                        ;AVL=0 No utilizado
                        ;Limit 19-16
    db 0x00             ;Base 31-24
GDT_LENGTH EQU $-GDT
_gdtr:
    dw GDT_LENGTH-1
    dd GDT


SECTION .sys_table_idt_32 progbits alloc noexec nowrite

;https://www.csee.umbc.edu/courses/undergraduate/CMSC313/spring05/burt_katz/lectures/Lect10/structuresInAsm.html
struc   IDT_struct_t
	.offset_15_0_0      resw    1
    .code_31_16_0       resw    1
    .attributos_7_0_1   resb    1
    .attributos_15_8_1  resb    1
    .offset_31_16_1     resw    1
endstruc
LALTA equ 0x10

IDT:                    ; pag 3018 Listado
                        ; pag 3027 Formato IDT
ISR00_idt EQU $-IDT              ;Divide Error
    ;dw 0x204E           ;Bits 15-0:  Offset dentro del segmento parte baja
    dw ISR00_Handler_DE_off
    dw CS_SEL_32        ;Bits 31-16: Segmento de Referencia
                        ;Segunda palabra Dir+4
    db 0x00             ;Bits 7-4: 000 por defecto 
                        ;Bits 4-0: (Reservados)
    db 10001111b        ;P=1 Presente en el segmento
                        ;DPL=00, Nivel de prioridad Kernel
                        ;Bit 12: 0 por defecto 
                        ;D=1 Gate 32 bits 
                        ;Bits 10-8: 111 por defecto
    dw 0x10             ;Bits 31-16: Offset dentro del segmento parte alta 

ISR01_idt EQU $-IDT               ;Debug Exception (Reservada)
	dq 0x0000           ;Reservados

ISR02_idt EQU $-IDT              ;Nonmaskable External Interrupt
    dw ISR02_Handler_NMI_off;Bits 15-0:  Offset dentro del segmento parte baja
    dw CS_SEL_32        ;Bits 31-16: Segmento de Referencia
                        ;Segunda palabra Dir+4
    db 0x00             ;Bits 7-4: 000 por defecto 
                        ;Bits 4-0: (Reservados)
    db 10001111b        ;P=1 Presente en el segmento
                        ;DPL=00, Nivel de prioridad Kernel
                        ;Bit 12: 0 por defecto 
                        ;D=1 Gate 32 bits 
                        ;Bits 10-8: 111 por defecto
    dw LALTA             ;Bits 31-16: Offset dentro del segmento parte alta 

ISR03_idt EQU $-IDT              ;Nonmaskable External Interrupt
    dw ISR03_Handler_BP_off ;Bits 15-0:  Offset dentro del segmento parte baja
    dw CS_SEL_32        ;Bits 31-16: Segmento de Referencia
                        ;Segunda palabra Dir+4
    db 0x00             ;Bits 7-4: 000 por defecto 
                        ;Bits 4-0: (Reservados)
    db 10001111b        ;P=1 Presente en el segmento
                        ;DPL=00, Nivel de prioridad Kernel
                        ;Bit 12: 0 por defecto 
                        ;D=1 Gate 32 bits 
                        ;Bits 10-8: 111 por defecto
    dw LALTA             ;Bits 31-16: Offset dentro del segmento parte alta

ISR04_idt EQU $-IDT              ;Nonmaskable External Interrupt
    dw ISR04_Handler_OF_off ;Bits 15-0:  Offset dentro del segmento parte baja
    dw CS_SEL_32        ;Bits 31-16: Segmento de Referencia
                        ;Segunda palabra Dir+4
    db 0x00             ;Bits 7-4: 000 por defecto 
                        ;Bits 4-0: (Reservados)
    db 10001111b        ;P=1 Presente en el segmento
                        ;DPL=00, Nivel de prioridad Kernel
                        ;Bit 12: 0 por defecto 
                        ;D=1 Gate 32 bits 
                        ;Bits 10-8: 111 por defecto
    dw LALTA             ;Bits 31-16: Offset dentro del segmento parte alta

ISR05_idt EQU $-IDT              ;Nonmaskable External Interrupt
    dw ISR05_Handler_BR_off ;Bits 15-0:  Offset dentro del segmento parte baja
    dw CS_SEL_32        ;Bits 31-16: Segmento de Referencia
                        ;Segunda palabra Dir+4
    db 0x00             ;Bits 7-4: 000 por defecto 
                        ;Bits 4-0: (Reservados)
    db 10001111b        ;P=1 Presente en el segmento
                        ;DPL=00, Nivel de prioridad Kernel
                        ;Bit 12: 0 por defecto 
                        ;D=1 Gate 32 bits 
                        ;Bits 10-8: 111 por defecto
    dw LALTA             ;Bits 31-16: Offset dentro del segmento parte alta

ISR06_idt EQU $-IDT              ;Nonmaskable External Interrupt
    dw ISR06_Handler_UD_off ;Bits 15-0:  Offset dentro del segmento parte baja
    dw CS_SEL_32        ;Bits 31-16: Segmento de Referencia
                        ;Segunda palabra Dir+4
    db 0x00             ;Bits 7-4: 000 por defecto 
                        ;Bits 4-0: (Reservados)
    db 10001111b        ;P=1 Presente en el segmento
                        ;DPL=00, Nivel de prioridad Kernel
                        ;Bit 12: 0 por defecto 
                        ;D=1 Gate 32 bits 
                        ;Bits 10-8: 111 por defecto
    dw LALTA             ;Bits 31-16: Offset dentro del segmento parte alta

ISR07_idt EQU $-IDT              ;Nonmaskable External Interrupt
    dw ISR07_Handler_NM_off ;Bits 15-0:  Offset dentro del segmento parte baja
    dw CS_SEL_32        ;Bits 31-16: Segmento de Referencia
                        ;Segunda palabra Dir+4
    db 0x00             ;Bits 7-4: 000 por defecto 
                        ;Bits 4-0: (Reservados)
    db 10001111b        ;P=1 Presente en el segmento
                        ;DPL=00, Nivel de prioridad Kernel
                        ;Bit 12: 0 por defecto 
                        ;D=1 Gate 32 bits 
                        ;Bits 10-8: 111 por defecto
    dw LALTA             ;Bits 31-16: Offset dentro del segmento parte alta

ISR08_idt EQU $-IDT              ;Nonmaskable External Interrupt
    dw ISR08_Handler_DF_off ;Bits 15-0:  Offset dentro del segmento parte baja
    dw CS_SEL_32        ;Bits 31-16: Segmento de Referencia
                        ;Segunda palabra Dir+4
    db 0x00             ;Bits 7-4: 000 por defecto 
                        ;Bits 4-0: (Reservados)
    db 10001111b        ;P=1 Presente en el segmento
                        ;DPL=00, Nivel de prioridad Kernel
                        ;Bit 12: 0 por defecto 
                        ;D=1 Gate 32 bits 
                        ;Bits 10-8: 111 por defecto
    dw LALTA             ;Bits 31-16: Offset dentro del segmento parte alta

ISR09_idt EQU $-IDT              ;Reservada
    dq 0x0000           ;Reservados

ISR10_idt EQU $-IDT              ;Nonmaskable External Interrupt
    dw ISR10_Handler_TS_off ;Bits 15-0:  Offset dentro del segmento parte baja
    dw CS_SEL_32        ;Bits 31-16: Segmento de Referencia
                        ;Segunda palabra Dir+4
    db 0x00             ;Bits 7-4: 000 por defecto 
                        ;Bits 4-0: (Reservados)
    db 10001111b        ;P=1 Presente en el segmento
                        ;DPL=00, Nivel de prioridad Kernel
                        ;Bit 12: 0 por defecto 
                        ;D=1 Gate 32 bits 
                        ;Bits 10-8: 111 por defecto
    dw LALTA             ;Bits 31-16: Offset dentro del segmento parte alta

ISR11_idt EQU $-IDT              ;Nonmaskable External Interrupt
    dw ISR11_Handler_NP_off ;Bits 15-0:  Offset dentro del segmento parte baja
    dw CS_SEL_32        ;Bits 31-16: Segmento de Referencia
                        ;Segunda palabra Dir+4
    db 0x00             ;Bits 7-4: 000 por defecto 
                        ;Bits 4-0: (Reservados)
    db 10001111b        ;P=1 Presente en el segmento
                        ;DPL=00, Nivel de prioridad Kernel
                        ;Bit 12: 0 por defecto 
                        ;D=1 Gate 32 bits 
                        ;Bits 10-8: 111 por defecto
    dw LALTA             ;Bits 31-16: Offset dentro del segmento parte alta

ISR12_idt EQU $-IDT              ;Nonmaskable External Interrupt
    dw ISR12_Handler_SS_off ;Bits 15-0:  Offset dentro del segmento parte baja
    dw CS_SEL_32        ;Bits 31-16: Segmento de Referencia
                        ;Segunda palabra Dir+4
    db 0x00             ;Bits 7-4: 000 por defecto 
                        ;Bits 4-0: (Reservados)
    db 10001111b        ;P=1 Presente en el segmento
                        ;DPL=00, Nivel de prioridad Kernel
                        ;Bit 12: 0 por defecto 
                        ;D=1 Gate 32 bits 
                        ;Bits 10-8: 111 por defecto
    dw LALTA             ;Bits 31-16: Offset dentro del segmento parte alta

ISR13_idt EQU $-IDT              ;Nonmaskable External Interrupt
    dw ISR13_Handler_GP_off ;Bits 15-0:  Offset dentro del segmento parte baja
    dw CS_SEL_32        ;Bits 31-16: Segmento de Referencia
                        ;Segunda palabra Dir+4
    db 0x00             ;Bits 7-4: 000 por defecto 
                        ;Bits 4-0: (Reservados)
    db 10001111b        ;P=1 Presente en el segmento
                        ;DPL=00, Nivel de prioridad Kernel
                        ;Bit 12: 0 por defecto 
                        ;D=1 Gate 32 bits 
                        ;Bits 10-8: 111 por defecto
    dw LALTA             ;Bits 31-16: Offset dentro del segmento parte alta

ISR14_idt EQU $-IDT              ;Nonmaskable External Interrupt
    dw ISR14_Handler_PF_off ;Bits 15-0:  Offset dentro del segmento parte baja
    dw CS_SEL_32        ;Bits 31-16: Segmento de Referencia
                        ;Segunda palabra Dir+4
    db 0x00             ;Bits 7-4: 000 por defecto 
                        ;Bits 4-0: (Reservados)
    db 10001111b        ;P=1 Presente en el segmento
                        ;DPL=00, Nivel de prioridad Kernel
                        ;Bit 12: 0 por defecto 
                        ;D=1 Gate 32 bits 
                        ;Bits 10-8: 111 por defecto
    dw LALTA             ;Bits 31-16: Offset dentro del segmento parte alta

ISR15_idt EQU $-IDT              ;Nonmaskable External Interrupt
    dq 0x0000           ;Reservados

ISR16_idt EQU $-IDT              ;Nonmaskable External Interrupt
    dw ISR16_Handler_MF_off ;Bits 15-0:  Offset dentro del segmento parte baja
    dw CS_SEL_32        ;Bits 31-16: Segmento de Referencia
                        ;Segunda palabra Dir+4
    db 0x00             ;Bits 7-4: 000 por defecto 
                        ;Bits 4-0: (Reservados)
    db 10001111b        ;P=1 Presente en el segmento
                        ;DPL=00, Nivel de prioridad Kernel
                        ;Bit 12: 0 por defecto 
                        ;D=1 Gate 32 bits 
                        ;Bits 10-8: 111 por defecto
    dw LALTA             ;Bits 31-16: Offset dentro del segmento parte alta

ISR17_idt EQU $-IDT              ;Nonmaskable External Interrupt
    dw ISR17_Handler_AC_off ;Bits 15-0:  Offset dentro del segmento parte baja
    dw CS_SEL_32        ;Bits 31-16: Segmento de Referencia
                        ;Segunda palabra Dir+4
    db 0x00             ;Bits 7-4: 000 por defecto 
                        ;Bits 4-0: (Reservados)
    db 10001111b        ;P=1 Presente en el segmento
                        ;DPL=00, Nivel de prioridad Kernel
                        ;Bit 12: 0 por defecto 
                        ;D=1 Gate 32 bits 
                        ;Bits 10-8: 111 por defecto
    dw LALTA             ;Bits 31-16: Offset dentro del segmento parte alta

ISR18_idt EQU $-IDT              ;Nonmaskable External Interrupt
    dw ISR18_Handler_MC_off ;Bits 15-0:  Offset dentro del segmento parte baja
    dw CS_SEL_32        ;Bits 31-16: Segmento de Referencia
                        ;Segunda palabra Dir+4
    db 0x00             ;Bits 7-4: 000 por defecto 
                        ;Bits 4-0: (Reservados)
    db 10001111b        ;P=1 Presente en el segmento
                        ;DPL=00, Nivel de prioridad Kernel
                        ;Bit 12: 0 por defecto 
                        ;D=1 Gate 32 bits 
                        ;Bits 10-8: 111 por defecto
    dw LALTA             ;Bits 31-16: Offset dentro del segmento parte alta

ISR19_idt EQU $-IDT              ;Nonmaskable External Interrupt
    dw ISR19_Handler_XM_off ;Bits 15-0:  Offset dentro del segmento parte baja
    dw CS_SEL_32        ;Bits 31-16: Segmento de Referencia
                        ;Segunda palabra Dir+4
    db 0x00             ;Bits 7-4: 000 por defecto 
                        ;Bits 4-0: (Reservados)
    db 10001111b        ;P=1 Presente en el segmento
                        ;DPL=00, Nivel de prioridad Kernel
                        ;Bit 12: 0 por defecto 
                        ;D=1 Gate 32 bits 
                        ;Bits 10-8: 111 por defecto
    dw LALTA            ;Bits 31-16: Offset dentro del segmento parte alta

ISR20to31_idt EQU $-IDT
    times 12 dq 0x0000  ;Reservados

ISR32to46_idt EQU $-IDT
    times 15 dq 0x0000  ;Usuario


IDT_LENGTH EQU $-IDT
_idtr:
    dw IDT_LENGTH-1
    dd IDT
