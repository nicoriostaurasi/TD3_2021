;/**
; * @file isr_keyboard.asm
; * @author Nicolas Rios Taurasi (nicoriostaurasi@frba.utn.edu.ar)
; * @brief Handler de Interrupciones y Teclado
; * @version 1.1
; * @date 01-06-2021
; * 
; * @copyright Copyright (c) 2021
; * 
; */
%include "inc/utils.h"
%include "inc/processor-flags.h"

EXTERN DS_SEL_32
EXTERN CS_SEL_32

EXTERN __carga_GDT
EXTERN __carga_IDT
EXTERN data_teclado
EXTERN direccion_carga_local_main
EXTERN cr2_ram_main

EXTERN TareaActual
EXTERN __FPU_TASK_02_LIN
EXTERN __FPU_TASK_03_LIN
%define Tarea_1 1
%define Tarea_2 2
%define Tarea_4 4
%define Tarea_3 3

PAG_PCD_YES equ 1       ; cachable                          
PAG_PCD_NO  equ 0       ; no cachable
PAG_PWT_YES equ 1       ; 1 se escribe en cache y ram       
PAG_PWT_NO  equ 0       ; 0 
PAG_P_YES   equ 1       ; 1 presente
PAG_P_NO    equ 0       ; 0 no presente
PAG_RW_W    equ 1       ; 1 lectura y escritura
PAG_RW_R    equ 0       ; 0 solo lectura
PAG_US_SUP  equ 0       ; 0 supervisor
PAG_US_US   equ 1       ; 1 usuario  
PAG_D       equ 0       ; modificacion en la pagina
PAG_PAT     equ 0       ; PAT                   
PAG_G_YES   equ 0       ; Global                 
PAG_A       equ 0       ; accedida
PAG_PS_4K   equ 0       ; tamaño de pagina de 4KB
EXTERN __PAGE_TABLES_VMA_LIN
EXTERN __PAGE_TABLES_VMA_TASK01_LIN
EXTERN __carga_DTP
EXTERN __carga_TP


EXTERN __chequeo_tecla
EXTERN __DATOS_TIMER_VMA_LIN
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
GLOBAL ISR14_Handler_PF_Basico
GLOBAL ISR16_Handler_MF
GLOBAL ISR17_Handler_AC
GLOBAL ISR18_Handler_MC
GLOBAL ISR19_Handler_XM

GLOBAL IRQ00_Handler
GLOBAL IRQ01_Handler

GLOBAL Syscall_Handler

EXTERN __STACK_END_32_T1
EXTERN __TSS_TASK_01_LIN
EXTERN tarea_1_falla

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

    UD:
        jmp	0xFFFFFFFFF 							

	key_I: 							     ;#DF: Doble falta
		cmp al,TECLA_I 		
        jne key_S
        push ISR00_Handler_DE ;offset (handler)
        push 0x0000000F ;atributos
                        ;P=0 Presente en el segmento
                        ;DPL=00, Nivel de prioridad Kernel
                        ;Bit 12: 0 por defecto 
                        ;D=1 Gate 32 bits 
                        ;Bits 10-8: 111 por defecto
        push CS_SEL_32  ;selector
        push 0x00000000 ;offsetIDT   
        call __carga_IDT
        add esp,16        ;para mantener el stack en la misma posición
        mov ecx,0x00
        mov eax,0x01
        div ecx                
	key_S: 							    ;#SS: Falta en el Stack Segment
		cmp al,TECLA_S 		
		jne key_A

        push 0x00000C12 ;atributos -> reconfiguro para un segmento no presente
        push 0x000FFFFF ;limite
        push 0x00000000 ;base
        push 0x00000002 ;offset   
        call __carga_GDT
        add esp,16
        mov ax,DS_SEL_32
        mov ss,ax
        
	key_A: 							    ;#AC: Aligment check
		cmp al,TECLA_A 		
        jne key_out 		
        mov eax,cr0
        or eax,X86_CR0_AM
        mov cr0,eax
        mov dword eax,[__TSS_TASK_01_LIN+9*04] ;EFLAGS
        or eax,0x40202
        mov dword [__STACK_END_32_T1-3*04],eax        
        mov dword eax,tarea_1_falla ;EIP
        mov dword [__STACK_END_32_T1-5*04],eax
        sti
        
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
    clts        ;CLear Task Switch Flag in CR0
    
    cmp byte [TareaActual],Tarea_2
    je Tarea2Uso
    cmp byte [TareaActual],Tarea_3
    je Tarea3Uso
    
    jmp Fin_NM

    Tarea2Uso:
    fxsave  &__FPU_TASK_03_LIN
    fxrstor &__FPU_TASK_02_LIN
    jmp Fin_NM

    Tarea3Uso:
    fxsave  &__FPU_TASK_02_LIN
    fxrstor &__FPU_TASK_03_LIN
    jmp Fin_NM

    Fin_NM:

    iret

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

ISR14_Handler_PF_Basico:
    mov dl,0x0E
    hlt

ISR14_Handler_PF:
    cli                         ;deshabilito interrupciones para no romper todo               
    pusha

    mov eax, cr2                ;Almaceno CR2 como recomienda la PPT
    mov dword [cr2_ram_main], eax    
    mov eax, [esp+8*4]          ;pushee 8 registros el error code quedo defasado
    and eax, 0x1F               ;rescato los ultimos 5 bits del error code          
    bt eax,0                    ;Bit 0 = 0 No presente             
    jnc PF_P                    ;                             
    bt eax,1                    ;Bit 1 = 0 Permisos de Lectura/Escritura         
    jnc PF_RW                   ;                              
    bt eax,2                    ;Bit 2 = 0 Permiso de privilegio
    jnc PF_US                   ;
    bt eax,4                    ;Bit 4 = 0 Instruction Fetch                             
    jnc PF_ID
    jc FIN_PF 

PF_P:
    ;creo la DTP correspondiente
    ;en esta rutina conformo la siguiente expresión:
    ;__PAGE_TABLES_VMA_LIN+0x5000+(0x1000)*(0xFFC00000 & CR2_RAM)>>22
    mov ebx, dword [cr2_ram_main]            ;cargo cr2 en ebx           
    and ebx, 0xFFC00000                 ;obtengo los bits 31-22
    shr ebx, 22                         ;lo shifteo hacia la derecha 22 veces
    ;en ebx tengo la entrada dentro de la DTP
    mov eax, ebx                        ;cargo en eax los bits 31-22
    mov ecx, 0x1000                     ;multiplico por 0x1000 para tener la DTP alineada
    mul ecx                             ;almaceno el valor en eax        
    add eax, 0x5000                     ;le sumo 0x5000 a eax
    add eax, __PAGE_TABLES_VMA_TASK01_LIN      ;le sumo el inicio de la DTP a eax
    ;fin de la rutina
    ;en eax tengo la direccion de carga de las TP
    push PAG_P_YES          
    push PAG_RW_W
    push PAG_US_SUP
    push PAG_PWT_NO
    push PAG_PCD_NO
    push PAG_A
    push PAG_PS_4K
    push dword(eax)                             
    push ebx                                    
    push dword(__PAGE_TABLES_VMA_TASK01_LIN)                
    call __carga_DTP
    add esp,40
    ;en esta rutina conformo la siguiente expresión:
    ;(0x002FF000 & CR2_RAM)>>12
    mov ebx, dword [cr2_ram_main]            ;cargo CR2 en ebx           
    and ebx, 0x003FF000                 ;obtengo los bits 21-12
    shr ebx, 12                         ;lo shifteo hacia la derecha 12 veces
    mov eax, ebx                        ;cargo en eax los bits 21-12
    
    ;en esta rutina conformo la siguiente expresión:
    ;__PAGE_TABLES_VMA_LIN+0x1000+(0x1000)*(0xFFC00000 & CR2_RAM)>>22
    mov eax, dword [cr2_ram_main]            ;cargo CR2 en eax
    and eax, 0xFFC00000                 ;obtengo los bits 31-22
    shr eax, 22                         ;lo shifteo hacia la derecha 22 veces
    mov ecx, 0x1000                     ;multiplico por 0x1000 para tener la DTP alineada
    mul ecx                             ;almaceno el resultado en eax
    add eax, 0x1000                     ;le agrego 0x1000 a eax
    add eax, __PAGE_TABLES_VMA_LIN      ;le agrego el inicio de la DTP a eax
    push PAG_P_YES
    push PAG_RW_W
    push PAG_US_SUP
    push PAG_PWT_NO
    push PAG_PCD_NO
    push PAG_A
    push PAG_D
    push PAG_PAT
    push PAG_G_YES
    ;inicia en 0x0A00-0000 y se incrementa cada 0x1000
    xor ecx,ecx
    mov dword ecx,[direccion_carga_local_main]
    push dword(ecx) 
    add ecx,0x1000
    mov dword [direccion_carga_local_main],ecx
    
    push ebx                                          
    push dword(eax)        
    call __carga_TP 
    add esp,48
    mov dh,0x1

    jmp FIN_PF

PF_RW:
    mov dh,0x2
    jmp FIN_PF

PF_US:
    mov dh,0x4
    jmp FIN_PF

PF_ID:
    mov dh,0x8
    jmp FIN_PF

FIN_PF:
    mov al, 0x20        
    out 0x20, al
    popa
    mov edx,0x0E

    pop eax
    sti
    iretd

ISR15_Handler_RES:
    mov dl,0x0F
    hlt

ISR16_Handler_MF:
    mov dl,0x10
    hlt

ISR17_Handler_AC:
    cli
    mov dl,0x11
    hlt

ISR18_Handler_MC:
    mov dl,0x12
    hlt

ISR19_Handler_XM:
    mov dl,0x13
    hlt

GLOBAL return_scheduler_ASM
EXTERN scheduler_ASM

IRQ00_Handler:
    ;EOI
    mov al, 0x20                        ;limpio la interrupcion del pic 
    out 0x20, al
    jmp scheduler_ASM
return_scheduler_ASM:
    push __DATOS_TIMER_VMA_LIN
    call __Systick_Handler
    add esp,4
    iret



IRQ01_Handler:

    pushad                            ;pusheo EAX para no perder info
    xor eax,eax               	      ;Clean EAX
    in al,PORT_A_8042                 ;leo el puerto
    bt eax,7                          ;con esto chequeo que es una pulsacion de tecla
    jnc limpio_buffer

    mov byte [data_teclado],al        ;muevo la tecla al buffer

    push eax
    call __chequeo_tecla
    add esp,4

    jmp limpio
    limpio_buffer:
    mov byte [data_teclado],0x00       ;reseteo la tecla del buffer
    
    limpio:                            ;clear PIC 
    mov al, 0x20                       ;limpio la interrupcion del pic 
    out 0x20, al

    popad                              ;devuelvo eax
    iret

GLOBAL TD3_Halt,TD3_Print,TD3_Read
TD3_Halt equ 81
TD3_Print equ 82
TD3_Read equ 83

Syscall_Handler:
    sti
;    xchg bx,bx
    cmp eax,TD3_Halt
    je syscall_hlt
    cmp eax,TD3_Print
    je syscall_print
    cmp eax,TD3_Read
    je syscall_read
    jmp fin_syscall

    syscall_read:
    read_byte:
    cmp ecx,1
    jne read_word
    mov byte eax,[ebx]
    jmp fin_syscall

    read_word:
    cmp ecx,2
    jne read_dword
    mov word eax,[ebx]
    jmp fin_syscall

    read_dword:
    cmp ecx,3
    jne read_qword
    mov dword eax,[ebx]
    jmp fin_syscall

    read_qword:
    cmp ecx,4
    jne read_error
    mov qword eax,[ebx]
    jmp fin_syscall

    read_error:
    mov eax,-1
    jmp fin_syscall

    syscall_print:
    EXTERN __screen_buffer_printc
    EXTERN __VIDEO_VGA_LIN
    push edx
    push __VIDEO_VGA_LIN    
    push ecx
    push ebx
    call __screen_buffer_printc 
    add esp,16
    jmp fin_syscall
    syscall_hlt:    
    hlt

    fin_syscall:
    iret