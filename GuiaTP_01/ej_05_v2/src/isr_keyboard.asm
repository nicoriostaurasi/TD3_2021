%include "inc/utils.h"

GLOBAL pool_teclado
GLOBAL ISR00_Handler_DE_off
GLOBAL ISR02_Handler_NMI_off
GLOBAL ISR03_Handler_BP_off
GLOBAL ISR04_Handler_OF_off
GLOBAL ISR05_Handler_BR_off
GLOBAL ISR06_Handler_UD_off
GLOBAL ISR07_Handler_NM_off
GLOBAL ISR08_Handler_DF_off
GLOBAL ISR10_Handler_TS_off
GLOBAL ISR11_Handler_NP_off
GLOBAL ISR12_Handler_SS_off
GLOBAL ISR13_Handler_GP_off
GLOBAL ISR14_Handler_PF_off
GLOBAL ISR16_Handler_MF_off
GLOBAL ISR17_Handler_AC_off
GLOBAL ISR18_Handler_MC_off
GLOBAL ISR19_Handler_XM_off

OFFSET_HANDLER equ 0x00100000

ISR00_Handler_DE_off equ (ISR00_Handler_DE-OFFSET_HANDLER)
ISR02_Handler_NMI_off equ (ISR01_Handler_DB-OFFSET_HANDLER)
ISR03_Handler_BP_off equ (ISR03_Handler_BP-OFFSET_HANDLER)
ISR04_Handler_OF_off equ (ISR04_Handler_OF-OFFSET_HANDLER)
ISR05_Handler_BR_off equ (ISR05_Handler_BR-OFFSET_HANDLER)
ISR06_Handler_UD_off equ (ISR06_Handler_UD-OFFSET_HANDLER)
ISR07_Handler_NM_off equ (ISR07_Handler_NM-OFFSET_HANDLER)
ISR08_Handler_DF_off equ (ISR08_Handler_DF-OFFSET_HANDLER)
ISR10_Handler_TS_off equ (ISR10_Handler_TS-OFFSET_HANDLER)
ISR11_Handler_NP_off equ (ISR11_Handler_NP-OFFSET_HANDLER)
ISR12_Handler_SS_off equ (ISR12_Handler_SS-OFFSET_HANDLER)
ISR13_Handler_GP_off equ (ISR13_Handler_GP-OFFSET_HANDLER)
ISR14_Handler_PF_off equ (ISR14_Handler_PF-OFFSET_HANDLER)
ISR16_Handler_MF_off equ (ISR16_Handler_MF-OFFSET_HANDLER)
ISR17_Handler_AC_off equ (ISR17_Handler_AC-OFFSET_HANDLER)
ISR18_Handler_MC_off equ (ISR18_Handler_MC-OFFSET_HANDLER)
ISR19_Handler_XM_off equ (ISR19_Handler_XM-OFFSET_HANDLER)

section .teclado_and_ISR

USE32
    pool_teclado:                       ;fuente: https://wiki.osdev.org/%228042%22_PS/2_Controller#Status_Register
                                        ;https://marte.unican.es/projects/angelmunozcantera/Anexo_Manejo_8042.pdf
    xor eax,eax               	        ;Clean EAX
	in al,CTRL_PORT_8042            	;Consulto actividad
	push eax
    and eax,0x01
    cmp eax,0x01
    pop eax
    jne pool_teclado

	in al,PORT_A_8042					;Leo tecla del buffer
	push eax
    and eax,0x80
    cmp eax,0x80               	        ;BIT 7=1 lee actividad de teclado
    pop eax
    jne pool_teclado 					 

	key_U:                              ;#UD: Opcode Fetch							
		cmp al,TECLA_U  	
        jne key_I
        ;xchg bx,bx
        jmp	0xFFFFFFFFF 							

	key_I: 							     ;#DE:division error, debe ser #DF: Doble falta
		cmp al,TECLA_I 		
        ;aun no se generarla
		jne key_S
        mov edx, 0        		 
		mov eax, 0x47			
		mov esi, 0
		div esi
                
	key_S: 							    ;#SS: Falta en el Stack Segment
		cmp al,TECLA_S 		
        ;aun no se generarla	
		jne key_A 					

	key_A: 							    ;#AC: Aligment check
		cmp al,TECLA_A 		
        ;aun no se generarla	
        jne key_out 					

	key_out: 							;Fin programa
		cmp al,TECLA_ESC 			
        jne pool_teclado
        ;xchg bx,bx
        jmp .guard 

    .guard:                             
    xchg bx,bx      
    hlt
    jmp .guard


ISR00_Handler_DE:
    mov dl,0xFF
    hlt

ISR01_Handler_DB:
    mov dl,0x01
    hlt

ISR02_Handler_NMI:
    mov dl,0x02
    hlt

ISR03_Handler_BP:
    mov dl,0x03
    hlt

ISR04_Handler_OF:
    mov dl,0x04
    hlt

ISR05_Handler_BR:
    mov dl,0x05
    hlt

ISR06_Handler_UD:
    mov dl,0x06
    hlt

ISR07_Handler_NM:
    mov dl,0x07
    hlt

ISR08_Handler_DF:
    mov dl,0x08
    hlt

ISR10_Handler_TS:
    mov dl,0x0A
    hlt

ISR11_Handler_NP:
    mov dl,0x0B
    hlt

ISR12_Handler_SS:
    mov dl,0x0C
    hlt

ISR13_Handler_GP:
    mov dl,0x0D
    hlt

ISR14_Handler_PF:
    mov dl,0x0E
    hlt

ISR15_Handler_RES:
    mov dl,0x0F
    hlt

ISR16_Handler_MF:
    mov dl,0x10
    hlt

ISR17_Handler_AC:
    mov dl,0x11
    hlt

ISR18_Handler_MC:
    mov dl,0x12
    hlt

ISR19_Handler_XM:
    mov dl,0x13
    hlt