;SECTION .sys_table_idt_32 

;LALTA equ 0x10

;IDT:                    ; pag 3018 Listado
                        ; pag 3027 Formato IDT
;ISR00_idt EQU $-IDT              ;Divide Error
;    dw ISR00_Handler_DE_off;Bits 15-0:  Offset dentro del segmento parte baja
;    dw CS_SEL_32        ;Bits 31-16: Segmento de Referencia
                        ;Segunda palabra Dir+4
;    db 0x00             ;Bits 7-4: 000 por defecto 
                        ;Bits 4-0: (Reservados)
;    db 10001111b       ;P=1 Presente en el segmento
                        ;DPL=00, Nivel de prioridad Kernel
                        ;Bit 12: 0 por defecto 
                        ;D=1 Gate 32 bits 
                        ;Bits 10-8: 111 por defecto
;    dw LALTA             ;Bits 31-16: Offset dentro del segmento parte alta 

;ISR01_idt EQU $-IDT               ;Debug Exception (Reservada)
;	dq 0x0000           ;Reservados

;ISR02_idt EQU $-IDT              ;Nonmaskable External Interrupt
;    dw ISR02_Handler_NMI_off;Bits 15-0:  Offset dentro del segmento parte baja
;    dw CS_SEL_32        ;Bits 31-16: Segmento de Referencia
                        ;Segunda palabra Dir+4
;    db 0x00             ;Bits 7-4: 000 por defecto 
                        ;Bits 4-0: (Reservados)
;    db 10001111b        ;P=1 Presente en el segmento
                        ;DPL=00, Nivel de prioridad Kernel
                        ;Bit 12: 0 por defecto 
                        ;D=1 Gate 32 bits 
                        ;Bits 10-8: 111 por defecto
;    dw LALTA             ;Bits 31-16: Offset dentro del segmento parte alta 

;ISR03_idt EQU $-IDT              ;Nonmaskable External Interrupt
;    dw ISR03_Handler_BP_off ;Bits 15-0:  Offset dentro del segmento parte baja
;    dw CS_SEL_32        ;Bits 31-16: Segmento de Referencia
                        ;Segunda palabra Dir+4
;    db 0x00             ;Bits 7-4: 000 por defecto 
                        ;Bits 4-0: (Reservados)
;    db 10001111b        ;P=1 Presente en el segmento
                        ;DPL=00, Nivel de prioridad Kernel
                        ;Bit 12: 0 por defecto 
                        ;D=1 Gate 32 bits 
                        ;Bits 10-8: 111 por defecto
;    dw LALTA             ;Bits 31-16: Offset dentro del segmento parte alta

;ISR04_idt EQU $-IDT              ;Nonmaskable External Interrupt
;    dw ISR04_Handler_OF_off ;Bits 15-0:  Offset dentro del segmento parte baja
;    dw CS_SEL_32        ;Bits 31-16: Segmento de Referencia
                        ;Segunda palabra Dir+4
;    db 0x00             ;Bits 7-4: 000 por defecto 
                        ;Bits 4-0: (Reservados)
;    db 10001111b        ;P=1 Presente en el segmento
                        ;DPL=00, Nivel de prioridad Kernel
                        ;Bit 12: 0 por defecto 
                        ;D=1 Gate 32 bits 
                        ;Bits 10-8: 111 por defecto
;    dw LALTA             ;Bits 31-16: Offset dentro del segmento parte alta

;ISR05_idt EQU $-IDT              ;Nonmaskable External Interrupt
;    dw ISR05_Handler_BR_off ;Bits 15-0:  Offset dentro del segmento parte baja
;    dw CS_SEL_32        ;Bits 31-16: Segmento de Referencia
                        ;Segunda palabra Dir+4
;    db 0x00             ;Bits 7-4: 000 por defecto 
                        ;Bits 4-0: (Reservados)
;    db 10001111b        ;P=1 Presente en el segmento
                        ;DPL=00, Nivel de prioridad Kernel
                        ;Bit 12: 0 por defecto 
                        ;D=1 Gate 32 bits 
                        ;Bits 10-8: 111 por defecto
;    dw LALTA             ;Bits 31-16: Offset dentro del segmento parte alta

;ISR06_idt EQU $-IDT              ;Nonmaskable External Interrupt;;
;    dw ISR06_Handler_UD_off ;Bits 15-0:  Offset dentro del segmento parte baja
;    dw CS_SEL_32        ;Bits 31-16: Segmento de Referencia
                        ;Segunda palabra Dir+4
;    db 0x00             ;Bits 7-4: 000 por defecto 
                        ;Bits 4-0: (Reservados)
;    db 10001111b        ;P=1 Presente en el segmento
                        ;DPL=00, Nivel de prioridad Kernel
                        ;Bit 12: 0 por defecto 
                        ;D=1 Gate 32 bits 
                        ;Bits 10-8: 111 por defecto
;    dw LALTA             ;Bits 31-16: Offset dentro del segmento parte alta

;ISR07_idt EQU $-IDT              ;Nonmaskable External Interrupt;
;;    dw ISR07_Handler_NM_off ;Bits 15-0:  Offset dentro del segmento parte baja
 ;   dw CS_SEL_32        ;Bits 31-16: Segmento de Referencia
                        ;Segunda palabra Dir+4
 ;   db 0x00             ;Bits 7-4: 000 por defecto 
                        ;Bits 4-0: (Reservados)
 ;   db 10001111b        ;P=1 Presente en el segmento
                        ;DPL=00, Nivel de prioridad Kernel
                        ;Bit 12: 0 por defecto 
                        ;D=1 Gate 32 bits 
                        ;Bits 10-8: 111 por defecto
 ;   dw LALTA             ;Bits 31-16: Offset dentro del segmento parte alta

;ISR08_idt EQU $-IDT              ;Nonmaskable External Interrupt
;    dw ISR08_Handler_DF_off ;Bits 15-0:  Offset dentro del segmento parte baja
;    dw CS_SEL_32        ;Bits 31-16: Segmento de Referencia
                        ;Segunda palabra Dir+4
;    db 0x00             ;Bits 7-4: 000 por defecto 
                        ;Bits 4-0: (Reservados)
;    db 10001111b        ;P=1 Presente en el segmento
                        ;DPL=00, Nivel de prioridad Kernel
                        ;Bit 12: 0 por defecto 
                        ;D=1 Gate 32 bits 
                        ;Bits 10-8: 111 por defecto
;    dw LALTA             ;Bits 31-16: Offset dentro del segmento parte alta

;ISR09_idt EQU $-IDT              ;Reservada
    dq 0x0000           ;Reservados

;ISR10_idt EQU $-IDT              ;Nonmaskable External Interrupt
;    dw ISR10_Handler_TS_off ;Bits 15-0:  Offset dentro del segmento parte baja
;    dw CS_SEL_32        ;Bits 31-16: Segmento de Referencia
                        ;Segunda palabra Dir+4
;    db 0x00             ;Bits 7-4: 000 por defecto 
                        ;Bits 4-0: (Reservados)
;    db 10001111b        ;P=1 Presente en el segmento
                        ;DPL=00, Nivel de prioridad Kernel
                        ;Bit 12: 0 por defecto 
                        ;D=1 Gate 32 bits 
                        ;Bits 10-8: 111 por defecto
;    dw LALTA             ;Bits 31-16: Offset dentro del segmento parte alta

;ISR11_idt EQU $-IDT              ;Nonmaskable External Interrupt
;    dw ISR11_Handler_NP_off ;Bits 15-0:  Offset dentro del segmento parte baja
;    dw CS_SEL_32        ;Bits 31-16: Segmento de Referencia
                        ;Segunda palabra Dir+4
;    db 0x00             ;Bits 7-4: 000 por defecto 
                        ;Bits 4-0: (Reservados)
;    db 10001111b        ;P=1 Presente en el segmento
                        ;DPL=00, Nivel de prioridad Kernel
                        ;Bit 12: 0 por defecto 
                        ;D=1 Gate 32 bits 
                        ;Bits 10-8: 111 por defecto
;    dw LALTA             ;Bits 31-16: Offset dentro del segmento parte alta

;ISR12_idt EQU $-IDT              ;Nonmaskable External Interrupt
;    dw ISR12_Handler_SS_off ;Bits 15-0:  Offset dentro del segmento parte baja
;    dw CS_SEL_32        ;Bits 31-16: Segmento de Referencia
                        ;Segunda palabra Dir+4
;    db 0x00             ;Bits 7-4: 000 por defecto 
                        ;Bits 4-0: (Reservados)
;    db 10001111b        ;P=1 Presente en el segmento
                        ;DPL=00, Nivel de prioridad Kernel
                        ;Bit 12: 0 por defecto 
                        ;D=1 Gate 32 bits 
                        ;Bits 10-8: 111 por defecto
;    dw LALTA             ;Bits 31-16: Offset dentro del segmento parte alta

;ISR13_idt EQU $-IDT              ;Nonmaskable External Interrupt
;    dw ISR13_Handler_GP_off ;Bits 15-0:  Offset dentro del segmento parte baja
;    dw CS_SEL_32        ;Bits 31-16: Segmento de Referencia
                        ;Segunda palabra Dir+4
;    db 0x00             ;Bits 7-4: 000 por defecto 
                        ;Bits 4-0: (Reservados)
;    db 10001111b        ;P=1 Presente en el segmento
                        ;DPL=00, Nivel de prioridad Kernel
                        ;Bit 12: 0 por defecto 
                        ;D=1 Gate 32 bits 
                        ;Bits 10-8: 111 por defecto
;    dw LALTA             ;Bits 31-16: Offset dentro del segmento parte alta

;ISR14_idt EQU $-IDT              ;Nonmaskable External Interrupt
;    dw ISR14_Handler_PF_off ;Bits 15-0:  Offset dentro del segmento parte baja
;    dw CS_SEL_32        ;Bits 31-16: Segmento de Referencia
                        ;Segunda palabra Dir+4
;    db 0x00             ;Bits 7-4: 000 por defecto 
                        ;Bits 4-0: (Reservados)
;    db 10001111b        ;P=1 Presente en el segmento
                        ;DPL=00, Nivel de prioridad Kernel
                        ;Bit 12: 0 por defecto 
                        ;D=1 Gate 32 bits 
                        ;Bits 10-8: 111 por defecto
;    dw LALTA             ;Bits 31-16: Offset dentro del segmento parte alta

;ISR15_idt EQU $-IDT              ;Nonmaskable External Interrupt;
;    dq 0x0000           ;Reservados

;ISR16_idt EQU $-IDT              ;Nonmaskable External Interrupt
;    dw ISR16_Handler_MF_off ;Bits 15-0:  Offset dentro del segmento parte baja
;    dw CS_SEL_32        ;Bits 31-16: Segmento de Referencia
                        ;Segunda palabra Dir+4
;    db 0x00             ;Bits 7-4: 000 por defecto 
                        ;Bits 4-0: (Reservados)
;    db 10001111b        ;P=1 Presente en el segmento
                        ;DPL=00, Nivel de prioridad Kernel
                        ;Bit 12: 0 por defecto 
                        ;D=1 Gate 32 bits 
                        ;Bits 10-8: 111 por defecto
;    dw LALTA             ;Bits 31-16: Offset dentro del segmento parte alta

;ISR17_idt EQU $-IDT              ;Nonmaskable External Interrupt
;    dw ISR17_Handler_AC_off ;Bits 15-0:  Offset dentro del segmento parte baja
;    dw CS_SEL_32        ;Bits 31-16: Segmento de Referencia
                        ;Segunda palabra Dir+4
;    db 0x00             ;Bits 7-4: 000 por defecto 
                        ;Bits 4-0: (Reservados)
;    db 10001111b        ;P=1 Presente en el segmento
                        ;DPL=00, Nivel de prioridad Kernel
                        ;Bit 12: 0 por defecto 
                        ;D=1 Gate 32 bits 
                        ;Bits 10-8: 111 por defecto
;    dw LALTA             ;Bits 31-16: Offset dentro del segmento parte alta

;ISR18_idt EQU $-IDT              ;Nonmaskable External Interrupt
;    dw ISR18_Handler_MC_off ;Bits 15-0:  Offset dentro del segmento parte baja
;    dw CS_SEL_32        ;Bits 31-16: Segmento de Referencia
                        ;Segunda palabra Dir+4
;    db 0x00             ;Bits 7-4: 000 por defecto 
                        ;Bits 4-0: (Reservados)
;    db 10001111b        ;P=1 Presente en el segmento
                        ;DPL=00, Nivel de prioridad Kernel
                        ;Bit 12: 0 por defecto 
                        ;D=1 Gate 32 bits 
                        ;Bits 10-8: 111 por defecto
;    dw LALTA             ;Bits 31-16: Offset dentro del segmento parte alta

;ISR19_idt EQU $-IDT              ;Nonmaskable External Interrupt
;    dw ISR19_Handler_XM_off ;Bits 15-0:  Offset dentro del segmento parte baja
;    dw CS_SEL_32        ;Bits 31-16: Segmento de Referencia
                        ;Segunda palabra Dir+4
;    db 0x00             ;Bits 7-4: 000 por defecto 
                        ;Bits 4-0: (Reservados)
;    db 10001111b        ;P=1 Presente en el segmento
                        ;DPL=00, Nivel de prioridad Kernel
                        ;Bit 12: 0 por defecto 
                        ;D=1 Gate 32 bits 
                        ;Bits 10-8: 111 por defecto
;    dw LALTA            ;Bits 31-16: Offset dentro del segmento parte alta

;ISR20to31_idt EQU $-IDT
;    times 12 dq 0x0000  ;Reservados

;ISR32_IRQ_0 EQU $-IDT
;    dq 0x00000;
;ISR32_IRQ_1 EQU $-IDT
;    dw IRQ01_Handler_off ;Bits 15-0:  Offset dentro del segmento parte baja
;    dw CS_SEL_32        ;Bits 31-16: Segmento de Referencia
                        ;Segunda palabra Dir+4
;    db 0x00             ;Bits 7-4: 000 por defecto 
                        ;Bits 4-0: (Reservados)
;    db 10001111b        ;P=1 Presente en el segmento
                        ;DPL=00, Nivel de prioridad Kernel
                        ;Bit 12: 0 por defecto 
                        ;D=1 Gate 32 bits 
                        ;Bits 10-8: 111 por defecto
;    dw LALTA            ;Bits 31-16: Offset dentro del segmento parte alta

;ISR32_IRQ_2_15 EQU $-IDT   
;    times 13 dq 0x0000  ;Usuario


;IDT_LENGTH EQU $-IDT
;;_idtr:
;    dw IDT_LENGTH-1
;    dd IDT
