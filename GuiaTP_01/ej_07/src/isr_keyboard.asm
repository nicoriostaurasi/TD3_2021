%include "inc/utils.h"

EXTERN DS_SEL_32
EXTERN CS_SEL_32

EXTERN __carga_GDT
EXTERN __carga_IDT
EXTERN data_teclado
EXTERN data_timer
EXTERN __chequeo_tecla
EXTERN __DATOS_TIMER_VMA
EXTERN __Systick_Handler
GLOBAL pool_teclado

GLOBAL ISR00_Handler_DE
GLOBAL ISR02_Handler_NMI
GLOBAL ISR03_Handler_BP
GLOBAL ISR04_Handler_OF
GLOBAL ISR05_Handler_BR
GLOBAL ISR06_Handler_UD
GLOBAL ISR07_Handler_NM
GLOBAL ISR08_Handler_DF
GLOBAL ISR10_Handler_TS
GLOBAL ISR11_Handler_NP
GLOBAL ISR12_Handler_SS
GLOBAL ISR13_Handler_GP
GLOBAL ISR14_Handler_PF
GLOBAL ISR16_Handler_MF
GLOBAL ISR17_Handler_AC
GLOBAL ISR18_Handler_MC
GLOBAL ISR19_Handler_XM

GLOBAL IRQ00_Handler
GLOBAL IRQ01_Handler

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
;        xchg bx,bx
    UD:
        jmp	0xFFFFFFFFF 							

	key_I: 							     ;#DF: Doble falta
		cmp al,TECLA_I 		
        ;aun no se generarla
                
	key_S: 							    ;#SS: Falta en el Stack Segment
		cmp al,TECLA_S 		
		jne key_A
;        xchg bx,bx
        ;reconfiguro el DS
        push 0x00000C12 ;atributos -> recofinguro para un segmento no presente
        push 0x000FFFFF ;limite
        push 0x00000000 ;base
        push 0x00000002 ;offset   
        call __carga_GDT
        add esp,16
        mov ax,DS_SEL_32
        mov ss,ax
        
	key_A: 							    ;#AC: Aligment check
		cmp al,TECLA_A 		
        ;aun no se generarla	
        jne key_out 		
        xchg bx,bx

        
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

IRQ00_Handler:
                                        ;clear PIC 
    ;xchg bx,bx
    ;pushad
    ;xor eax,eax
    ;mov dword eax, [data_timer]
    ;inc eax
    ;mov dword [data_timer], eax
    push __DATOS_TIMER_VMA
    call __Systick_Handler
    add esp,4

    mov al, 0x20                        ;limpio la interrupcion del pic 
    out 0x20, al
    ;popad
    iret

IRQ01_Handler:
    
    pushad                            ;pusheo EAX para no perder info
    xor eax,eax               	        ;Clean EAX
;    xchg bx,bx
    in al,PORT_A_8042                   ;leo el puerto
    bt eax,7
    jnc limpio_buffer

    mov byte [data_teclado],al          ;muevo la tecla al buffer

    push eax
    call __chequeo_tecla
    add esp,4

    jmp limpio
    limpio_buffer:
    mov byte [data_teclado],0x00        ;reseteo la tecla del buffer
    
    limpio:                             ;clear PIC 
    mov al, 0x20                        ;limpio la interrupcion del pic 
    out 0x20, al

    popad                             ;devuelvo eax
    iret