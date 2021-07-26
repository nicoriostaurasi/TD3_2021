;/**
; * @file utils_32.asm
; * @author Nicolas Rios Taurasi (nicoriostaurasi@frba.utn.edu.ar)
; * @brief Rutinas de utilidad para inicializar
; * @version 1.1
; * @date 01-06-2021
; * 
; * @copyright Copyright (c) 2021
; * 
; */

SECTION .utils32

;Rutinas que contiene el archivo
GLOBAL init_pic
GLOBAL init_mask_pic
GLOBAL init_PIT
GLOBAL cargo_gdt_desde_codigo
GLOBAL cargo_idt_desde_codigo
GLOBAL cargo_DTP_desde_codigo
GLOBAL cargo_TP_desde_codigo
GLOBAL cargo_CR3
GLOBAL DTP_task01
GLOBAL DTP_task02
GLOBAL DTP_task03
GLOBAL DTP_task04

GLOBAL paginacion_tarea_1
GLOBAL paginacion_tarea_2
GLOBAL paginacion_tarea_3
GLOBAL paginacion_tarea_4

;Labels utiles para IDT/GDT
EXTERN CS_SEL_32
EXTERN ISR00_Handler_DE
EXTERN ISR02_Handler_NMI
EXTERN ISR03_Handler_BP
EXTERN ISR04_Handler_OF
EXTERN ISR05_Handler_BR
EXTERN ISR06_Handler_UD
EXTERN ISR07_Handler_NM
EXTERN ISR08_Handler_DF
EXTERN ISR10_Handler_TS
EXTERN ISR11_Handler_NP
EXTERN ISR12_Handler_SS
EXTERN ISR13_Handler_GP
EXTERN ISR14_Handler_PF
EXTERN ISR16_Handler_MF
EXTERN ISR17_Handler_AC
EXTERN ISR18_Handler_MC
EXTERN ISR19_Handler_XM
EXTERN IRQ00_Handler
EXTERN IRQ01_Handler
EXTERN Syscall_Handler

;Funciones de C externas
EXTERN  __carga_GDT
EXTERN  __carga_IDT
EXTERN  __carga_DTP
EXTERN  __carga_TP
EXTERN  __carga_CR3
EXTERN  __clean_dir
EXTERN  __pagina_rom
EXTERN  __levanto_pagina

;Labels para Paginación
EXTERN __PAGE_TABLES_VMA_LIN
EXTERN __PAGE_TABLES_VMA_TASK01_LIN
EXTERN __PAGE_TABLES_VMA_TASK02_LIN
EXTERN __PAGE_TABLES_VMA_TASK03_LIN
EXTERN __PAGE_TABLES_VMA_TASK04_LIN

EXTERN __PDT_Stack_Sistema
EXTERN __PDT_Sistema
EXTERN __PT_SYS_TABLES         
EXTERN __PT_TABLAS_PAGINACION  
EXTERN __PT_FUNCIONES          
EXTERN __PT_VIDEO              
EXTERN __PT_TECLADO_ISR         
EXTERN __PT_DIGITOS             
EXTERN __PT_DATOS              
EXTERN __PT_KERNEL             
EXTERN __PT_TASK_01_TEXT
EXTERN __PT_TASK_01_BSS
EXTERN __PT_TASK_01_DATA
EXTERN __PT_TASK_01_RODATA
EXTERN __PT_TASK_02_TEXT
EXTERN __PT_TASK_02_BSS
EXTERN __PT_TASK_02_DATA
EXTERN __PT_TASK_02_RODATA
EXTERN __PT_TASK_03_TEXT
EXTERN __PT_TASK_03_BSS
EXTERN __PT_TASK_03_DATA
EXTERN __PT_TASK_03_RODATA
EXTERN __PT_TASK_04_TEXT
EXTERN __PT_TASK_04_BSS
EXTERN __PT_TASK_04_DATA
EXTERN __PT_TASK_04_RODATA
EXTERN __PT_STACK_SISTEMA
EXTERN __PT_TASK_01_STACK      
EXTERN __PT_TASK_02_STACK      
EXTERN __PT_TASK_03_STACK      
EXTERN __PT_TASK_04_STACK      
EXTERN __PT_TSS_T1
EXTERN __PT_TSS_T2
EXTERN __PT_TSS_T3
EXTERN __PT_TSS_T4
EXTERN __PT_TSS_SYS
EXTERN __PT_STACK_SISTEMA_T1
EXTERN __PT_STACK_SISTEMA_T2
EXTERN __PT_STACK_SISTEMA_T3
EXTERN __PT_STACK_SISTEMA_T4

;------------------------------------------------------------------------------------------------------------
;		init_pic
;
;	Funcion: 	Inicializa el pic en cascada y le asigna el rango de tipo de interrupcion de 0x20 a 0x27 
;				y de 0x28 a 0x2F respectivamente.
;				
;------------------------------------------------------------------------------------------------------------

init_pic:
;// Inicializacion PIC N#1
  ;//ICW1:
  mov     al,0x11;//Establece IRQs activas x flanco, Modo cascada, e ICW4
  out     0x20,al
  ;//ICW2:
  mov     al,0x20   ;//Establece para el PIC#1 el valor base del Tipo de INT que recibio en el registro BH = 0x20
  out     0x21,al
  ;//ICW3:
  mov     al,0x04;//Establece PIC#1 como Master, e indica que un PIC Slave cuya Interrupcion ingresa por IRQ2
  out     0x21,al
  ;//ICW4
  mov     al,0x01;// Establece al PIC en Modo 8086
  out     0x21,al
;//Antes de inicializar el PIC N#2, deshabilitamos las Interrupciones del PIC1
  mov     al,0xFD   ;0x11111101
  out     0x21,al
;//Ahora inicializamos el PIC N#2
  ;//ICW1
  mov     al,0x11;//Establece IRQs activas x flanco, Modo cascada, e ICW4
  out     0xA0,al
  ;//ICW2
  mov     al,0x28    ;//Establece para el PIC#2 el valor base del Tipo de INT que recibio en el registro BL = 0x28
  out     0xA1,al
  ;//ICW3
  mov     al,0x02;//Establece al PIC#2 como Slave, y le indca que ingresa su Interrupcion al Master por IRQ2
  out     0xA1,al
  ;//ICW4
  mov     al,0x01;// Establece al PIC en Modo 8086
  out     0xA1,al
;Enmascaramos el resto de las Interrupciones (las del PIC#2)
  mov     al,0xFF
  out     0xA1,al
; Habilitamos la interrupcion del timer.
  mov     al,0xFC   ;0x11111100
  out     0x21,al
  ret


;------------------------------------------------------------------------------------------------------------
;		init_mask_pic
;
;	Funcion: Lee las máscaras de ambos PIC y las pone en 0xFF para deshabilitar todas las irq
;
;
;------------------------------------------------------------------------------------------------------------

init_mask_pic:
  in al,0x21
  or al,0xFF
  out 0x21,al
  
  in al,0xA1
  or al,0xFF
  out 0xA1,al
  ret

;------------------------------------------------------------------------------------------------------------
;		init_PIT
;
;	Funcion: 	Inicia el timer del PIC master
;
;				
;------------------------------------------------------------------------------------------------------------

init_PIT:

  ;fuente https://en.wikibooks.org/wiki/X86_Assembly/Programmable_Interval_Timer
  mov al, 0x36    ;0011 0110    see below   
  out 0x43, al    ;tell the PIT which channel we're setting

  mov ax, 11932  
  out 0x40, al    ;send low byte
  mov al, ah
  out 0x40, al    ;send high byte

  ret

;------------------------------------------------------------------------------------------------------------
;		cargo_gdt_desde_codigo
;
;	Funcion: 	Función para escribir la VMA donde ubico la GDT
;
;				
;------------------------------------------------------------------------------------------------------------


cargo_gdt_desde_codigo:
    
    ;descriptor nulo
    push 0x00000000 ;atributos
    push 0x00000000 ;limite OK
    push 0x00000000 ;base Ok
    push 0x00000000 ;offset   
    call __carga_GDT
    add esp,16
    ;xchg bx,bx

    ;CS_SEL_32
    ;limite:      0x000F-FFFF  
    ;base:        0x0000-0000
    ;attributos:  0x0000-0C99
                        ;G=1 Maximo offset = Limite*0x1000+0xFFF
                        ;D/B=1 Big, Segmento de 32
                        ;L=0 No 64 bits nativo
                        ;AVL=0 No utilizado

                        ;P=1 Presente en el segmento
                        ;DPL=00 Privilegio nivel 0 - Kernel
                        ;S=1 Descriptor de Codigo/Datos
                        
                        ;D/C=1 Segmento de Codigo 
                        ;C=0 No puede ser invocado
                        ;R=0 No legible
                        ;A=1 por defecto Accedido
    ;offsetGDT    0x0000-0001
    push 0x00000C99 ;atributos
    push 0x000FFFFF ;limite
    push 0x00000000 ;base
    push 0x00000001 ;offset   
    call __carga_GDT
    add esp,16
    ;xchg bx,bx

    ;DS_SEL_32
    push 0x00000C92 ;atributos
                    ;G=1 Maximo offset = Limite*0x1000+0xFFF
                    ;D/B=1 Big, Segmento de 32
                    ;L=0 No 64 bits nativo
                    ;AVL=0 No utilizado
                    
                    ;P=1 Presente en el segmento
                    ;DPL=00 Privilegio nivel 0 - Kernel
                    ;S=1 Descriptor de Codigo/Datos
                    
                    ;D/C=0 Segmento de Datos 
                    ;ED=0 Segmento de datos comun
                    ;W=1 Escribible
                    ;A=0 por defecto No Accedido
    push 0x000FFFFF ;limite
    push 0x00000000 ;base
    push 0x00000002 ;offset   
    call __carga_GDT
    add esp,16

    ;CS_SEL_32_US
    ;limite:      0x000F-FFFF  
    ;base:        0x0000-0000
    ;attributos:  0x0000-0C99
                        ;G=1 Maximo offset = Limite*0x1000+0xFFF
                        ;D/B=1 Big, Segmento de 32
                        ;L=0 No 64 bits nativo
                        ;AVL=0 No utilizado

                        ;P=1 Presente en el segmento
                        ;DPL=11 Privilegio nivel 3 - Usuario
                        ;S=1 Descriptor de Codigo/Datos
                        
                        ;D/C=1 Segmento de Codigo 
                        ;C=0 No puede ser invocado
                        ;R=0 No legible
                        ;A=1 por defecto Accedido
    ;offsetGDT    0x0000-0001
    push 0x00000CF9 ;atributos
    push 0x000FFFFF ;limite
    push 0x00000000 ;base
    push 0x00000003 ;offset   
    call __carga_GDT
    add esp,16
    ;xchg bx,bx

    ;DS_SEL_32_US
    push 0x00000CF2 ;atributos
                    ;G=1 Maximo offset = Limite*0x1000+0xFFF
                    ;D/B=1 Big, Segmento de 32
                    ;L=0 No 64 bits nativo
                    ;AVL=0 No utilizado
                    
                    ;P=1 Presente en el segmento
                    ;DPL=11 Privilegio nivel 3 - Usuario
                    ;S=1 Descriptor de Codigo/Datos
                    
                    ;D/C=0 Segmento de Datos 
                    ;ED=0 Segmento de datos comun
                    ;W=1 Escribible
                    ;A=0 por defecto No Accedido
    push 0x000FFFFF ;limite
    push 0x00000000 ;base
    push 0x00000004 ;offset   
    call __carga_GDT
    add esp,16

    ;TSS_SEL
    push 0x00000C89 ;Base: 0x011F4000
                    ;atributos
                    ;G=1 Maximo offset = Limite*0x1000+0xFFF
                    ;D/B=1 Big, Segmento de 32
                    ;L=0 No 64 bits nativo
                    ;AVL=0 No utilizado
                    
                    ;P=1 Presente en el segmento
                    ;DPL=00 Privilegio nivel 0 - Kernel
                    ;S=0 Descriptor de Codigo/Datos
                    
                    ;D/C=1 Segmento de Codigo 
                    ;ED=0 
                    ;W=0 Escribible
                    ;A=0 por defecto No Accedido
    push 0x00000067 ;limite
    push 0x011F4000 ;base
    push 0x00000005 ;offset   
    call __carga_GDT
    add esp,16

    ;xchg bx,bx

ret

;------------------------------------------------------------------------------------------------------------
;		cargo_idt_desde_codigo
;
;	Funcion: 	Función que carga la IDT en VMA.
;
;				
;------------------------------------------------------------------------------------------------------------

cargo_idt_desde_codigo:
  
 ;Divide Error
 ;xchg bx,bx
  push ISR00_Handler_DE ;offset (handler)
  push 0x0000008F ;atributos
                  ;P=1 Presente en el segmento
                  ;DPL=00, Nivel de prioridad Kernel
                  ;Bit 12: 0 por defecto 
                  ;D=1 Gate 32 bits 
                  ;Bits 10-8: 111 por defecto
  push CS_SEL_32 ;selector
  push 0x00000000;offsetIDT   
  call __carga_IDT
  add esp,16        ;para mantener el stack en la misma posición
 ; xchg bx,bx

  ;Reservada
  push 0x00000000 ;offset (handler)
  push 0x00000000 ;atributos
  push 0x00000000 ;Selector
  push 0x00000001 ;offsetIDT   
  call __carga_IDT
  add esp,16

  push ISR02_Handler_NMI ;offset (handler)
  push 0x0000008F ;atributos
  push CS_SEL_32 ;Selector
  push 0x00000002 ;offsetIDT   
  call __carga_IDT
  add esp,16

  push ISR03_Handler_BP ;offset (handler)
  push 0x0000008F ;atributos
  push CS_SEL_32 ;Selector
  push 0x00000003 ;offsetIDT   
  call __carga_IDT
  add esp,16

  push ISR04_Handler_OF ;offset (handler)
  push 0x0000008F ;atributos
  push CS_SEL_32 ;Selector
  push 0x00000004 ;offsetIDT   
  call __carga_IDT
  add esp,16

  push ISR05_Handler_BR ;offset (handler)
  push 0x0000008F ;atributos
  push CS_SEL_32 ;Selector
  push 0x00000005 ;offsetIDT   
  call __carga_IDT
  add esp,16

  push ISR06_Handler_UD ;offset (handler)
  push 0x0000008F ;atributos
  push CS_SEL_32 ;Selector
  push 0x00000006 ;offsetIDT   
  call __carga_IDT
  add esp,16

  push ISR07_Handler_NM ;offset (handler)
  push 0x0000008F ;atributos
  push CS_SEL_32 ;Selector
  push 0x00000007 ;offsetIDT   
  call __carga_IDT
  add esp,16

  push ISR08_Handler_DF ;offset (handler)
  push 0x0000008F ;atributos
  push CS_SEL_32 ;Selector
  push 0x00000008 ;offsetIDT   
  call __carga_IDT
  add esp,16

  ;Reservada
  push 0x00000000 ;offset (handler)
  push 0x00000000 ;atributos
  push 0x00000000 ;Selector
  push 0x00000009 ;offsetIDT   
  call __carga_IDT
  add esp,16

  push ISR10_Handler_TS ;offset (handler)
  push 0x0000008F ;atributos
  push CS_SEL_32 ;Selector
  push 0x0000000A ;offsetIDT   
  call __carga_IDT
  add esp,16

  push ISR11_Handler_NP ;offset (handler)
  push 0x0000008F ;atributos
  push CS_SEL_32 ;Selector
  push 0x0000000B ;offsetIDT   
  call __carga_IDT
  add esp,16

  push ISR12_Handler_SS ;offset (handler)
  push 0x0000008F ;atributos
  push CS_SEL_32 ;Selector
  push 0x0000000C ;offsetIDT   
  call __carga_IDT
  add esp,16

  push ISR13_Handler_GP ;offset (handler)
  push 0x0000008F ;atributos
  push CS_SEL_32 ;Selector
  push 0x0000000D ;offsetIDT   
  call __carga_IDT
  add esp,16

  push ISR14_Handler_PF ;offset (handler)
  push 0x0000008F ;atributos
  push CS_SEL_32 ;Selector
  push 0x0000000E ;offsetIDT   
  call __carga_IDT
  add esp,16

  push 0x00000000 ;offset (handler)
  push 0x00000000 ;atributos
  push CS_SEL_32 ;Selector
  push 0x0000000F ;offsetIDT   
  call __carga_IDT
  add esp,16

  push ISR16_Handler_MF ;offset (handler)
  push 0x0000008F ;atributos
  push CS_SEL_32 ;Selector
  push 0x00000010 ;offsetIDT   
  call __carga_IDT
  add esp,16

  push ISR17_Handler_AC ;offset (handler)
  push 0x0000008F ;atributos
  push CS_SEL_32 ;Selector
  push 0x00000011 ;offsetIDT   
  call __carga_IDT
  add esp,16

  push ISR18_Handler_MC ;offset (handler)
  push 0x0000008F ;atributos
  push CS_SEL_32 ;Selector
  push 0x00000012 ;offsetIDT   
  call __carga_IDT
  add esp,16

  push ISR19_Handler_XM ;offset (handler)
  push 0x0000008F ;atributos
  push CS_SEL_32 ;Selector
  push 0x00000013 ;offsetIDT   
  call __carga_IDT
  add esp,16

  push IRQ00_Handler ;offset (handler)
  push 0x0000008E ;atributos
  push CS_SEL_32 ;Selector
  push 0x00000020 ;offsetIDT   
  call __carga_IDT
  add esp,16

  push IRQ01_Handler ;offset (handler)
  push 0x0000008E ;atributos
  push CS_SEL_32 ;Selector
  push 0x00000021 ;offsetIDT   
  call __carga_IDT
  add esp,16

  push Syscall_Handler  ;offset(Handler)
  push 0x000000EE    ;attributos:  0x0000-0C99
                        ;P=1 Presente en el segmento
                        ;DPL=11 Privilegio nivel 3 - Usuario
                        ;S=1 Descriptor de Codigo/Datos
                        
                        ;D/C=1 Segmento de Codigo 
                        ;C=1 No puede ser invocado
                        ;R=1 No legible
                        ;A=1 por defecto Accedido

  push (CS_SEL_32)         ;Selector
  push 0x00000080
  call __carga_IDT
  add esp,16
ret

;------------------------------------------------------------------------------------------------------------
;		cargo_DTP_desde_codigo
;
;	Funcion: 	Función que carga la DTP en RAM.
;
;				
;------------------------------------------------------------------------------------------------------------

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

cargo_DTP_desde_codigo:

  ;DTP
  ;------------------------
  ;(0x0) 0x0000-0000 a 0x003F-FFFF
  ;   *Sys_tables      0x0000-0000
  ;   *Tablas de Pag.  0x0001-0000
  ;   *Rutinas         0x0005-0000
  ;   *Teclado + ISR   0x0010-0000 
  ;------------------------
  ;(0x1) 0x0040-0000 a 0x007F-FFFF
  ;   *Stack Tarea 1   0x0078-F000
  ;------------------------
  ;(0x2) 0x0080-0000 a 0x00BF-FFFF (vacia)
  ;------------------------  
  ;(0x3) 0x00C0-0000 a 0x00FF-FFFF
  ;   *RAM Video       0x00E8-0000
  ;------------------------
  ;(0x4) 0x0100-0000 a 0x013F-FFFF
  ;   *Digitos         0x0120-0000
  ;   *Datos           0x0121-0000
  ;   *Kernel          0x0122-0000
  ;   *Tarea 1 TEXT    0x0131-0000
  ;   *Tarea 1 BSS     0x0132-0000
  ;   *Tarea 1 DATA    0x0133-0000
  ;   *Tarea 1 RODATA  0x0134-0000
  ;------------------------
  ;(0x5) 0x0140-0000 a 0x017F-FFFF
  ;------------------------
  ;(0x1FC) 0x1FC0-0000 a 0x1FFF-FFFF
  ;------------------------
  ; (..)
  ;------------------------
  ;(0xFFC) 0xFFC0-0000 a 0xFFFF-FFFF
  ;   *Init ROM de 64K 0xFFFF-0000 a 0xFFFF-0FFF
  ;   *VGA INIT        0xFFFF-E000 a 0xFFFF-EFFF
  ;   *COMODIN         0xFFFF-F000 a 0xFFFF-FFFF
  ;   -INIT 32         0xFFFF-F700 a 0xFFFF-FFFF
  ;   -Funciones ROM   0xFFFF-F900 a 0xFFFF-FFFF
  ;   -Sys Tables 16   0xFFFF-FE00 a 0xFFFF-FFFF
  ;------------------------

    ;------------------------
    ; DTP (0x0) 0x0000-0000 a 0x003F-FFFF
    ;------------------------
    push PAG_P_YES          
    push PAG_RW_W
    push PAG_US_US
    push PAG_PWT_NO
    push PAG_PCD_NO
    push PAG_A
    push PAG_PS_4K
    push dword(__PAGE_TABLES_VMA_LIN+0x1000+0x1000*0x00)      
    push 0x00                               
    push dword(__PAGE_TABLES_VMA_LIN)             
    call __carga_DTP
    add esp,40

    ;------------------------
    ; DTP (0x1) 0x0040-0000 a 0x007F-FFFF
    ;------------------------
    push PAG_P_YES          
    push PAG_RW_W
    push PAG_US_US
    push PAG_PWT_NO
    push PAG_PCD_NO
    push PAG_A
    push PAG_PS_4K
    push dword(__PAGE_TABLES_VMA_LIN+0x1000+0x1000*0x01)      
    push 0x01                               
    push dword(__PAGE_TABLES_VMA_LIN)             
    call __carga_DTP
    add esp,40

    ;------------------------  
    ; DTP (0x3) 0x00C0-0000 a 0x00FF-FFFF
    ;------------------------
    push PAG_P_YES
    push PAG_RW_W
    push PAG_US_US
    push PAG_PWT_NO
    push PAG_PCD_NO
    push PAG_A
    push PAG_PS_4K
    push dword(__PAGE_TABLES_VMA_LIN+0x1000+0x1000*0x03)      
    push 0x03                               
    push dword(__PAGE_TABLES_VMA_LIN)             
    call __carga_DTP
    add esp,40

    ;------------------------
    ; DTP (0x4) 0x0100-0000 a 0x013F-FFFF
    ;------------------------
    push PAG_P_YES          
    push PAG_RW_W
    push PAG_US_US
    push PAG_PWT_NO
    push PAG_PCD_NO
    push PAG_A
    push PAG_PS_4K
    push dword(__PAGE_TABLES_VMA_LIN+0x1000+0x1000*0x04)      
    push 0x04                               
    push dword(__PAGE_TABLES_VMA_LIN)             
    call __carga_DTP
    add esp,40

    ;------------------------
    ; DTP (0x5) 0x0140-0000 a 0x017F-FFFF
    ;------------------------
    push PAG_P_YES          
    push PAG_RW_W 
    push PAG_US_US
    push PAG_PWT_NO
    push PAG_PCD_NO
    push PAG_A
    push PAG_PS_4K
    push dword(__PAGE_TABLES_VMA_LIN+0x1000+0x1000*0x05)      
    push 0x05                               
    push dword(__PAGE_TABLES_VMA_LIN)             
    call __carga_DTP
    add esp,40


    ;------------------------
    ; DTP (0x2FC) 0x1FC0-0000 a 0x1FFF-FFFF
    ;------------------------
    push PAG_P_YES          
    push PAG_RW_W
    push PAG_US_US
    push PAG_PWT_NO
    push PAG_PCD_NO
    push PAG_A
    push PAG_PS_4K
    push dword(__PAGE_TABLES_VMA_LIN+0x1000+0x1000*0x7F)      
    push 0x7F                               
    push dword(__PAGE_TABLES_VMA_LIN)            
    call __carga_DTP
    add esp,40

    ;------------------------
    ;(0xFFC) 0xFFC0-0000 a 0xFFFF-FFFF
    ;------------------------
    push PAG_P_YES          
    push PAG_RW_W
    push PAG_US_US
    push PAG_PWT_NO
    push PAG_PCD_NO
    push PAG_A
    push PAG_PS_4K
    push dword(__PAGE_TABLES_VMA_LIN+0x1000+0x1000*0x3FF)      
    push 0x3FF                               
    push dword(__PAGE_TABLES_VMA_LIN)            
    call __carga_DTP
    add esp,40
ret


;------------------------------------------------------------------------------------------------------------
;		cargo_TP_desde_codigo
;
;	Funcion: 	Función que carga la TP en RAM.
;
;				
;------------------------------------------------------------------------------------------------------------

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

cargo_TP_desde_codigo:
  call __levanto_pagina
  ;------------------------
  ;(0x0) 0x0000-0000 a 0x003F-FFFF
  ;   *Sys_tables      0x0000-0000
  ;   *Tablas de Pag.  0x0001-0000
  ;   *Rutinas         0x0005-0000
  ;   *Teclado + ISR   0x0010-0000
  ;------------------------
  
  ;-----------------------------------------------------------------
  ;1° Pagina de 4K - Sys Tables  0x0000-0000 a 0x0000-0FFF
  ;-----------------------------------------------------------------
  push PAG_P_YES
  push PAG_RW_R
  push PAG_US_SUP
  push PAG_PWT_NO
  push PAG_PCD_NO
  push PAG_A
  push PAG_D
  push PAG_PAT
  push PAG_G_YES
  push dword(__PT_SYS_TABLES)
  push 0x00
  push dword(__PAGE_TABLES_VMA_LIN+0x1000)
  call __carga_TP 
  add esp,48

  ;-----------------------------------------------------------------
  ;2° Pagina de 4K - Tablas de Paginacion  0x0001-0000 a 0x0001-0FFF
  ;-----------------------------------------------------------------
  push PAG_P_YES
  push PAG_RW_W
  push PAG_US_SUP
  push PAG_PWT_NO
  push PAG_PCD_NO
  push PAG_A
  push PAG_D
  push PAG_PAT
  push PAG_G_YES
  push dword(__PT_TABLAS_PAGINACION)
  push 0x010
  push dword(__PAGE_TABLES_VMA_LIN+0x1000)
  call __carga_TP 
  add esp,48

  ;-----------------------------------------------------------------
  ;3° Pagina de 4K - Rutinas de RAM  0x0005-0000 a 0x0005-0FFF
  ;-----------------------------------------------------------------
  push PAG_P_YES
  push PAG_RW_R
  push PAG_US_SUP
  push PAG_PWT_NO
  push PAG_PCD_NO
  push PAG_A
  push PAG_D
  push PAG_PAT
  push PAG_G_YES
  push dword(__PT_FUNCIONES)
  push 0x050
  push dword(__PAGE_TABLES_VMA_LIN+0x1000)
  call __carga_TP 
  add esp,48

  ;-----------------------------------------------------------------
  ;4° Pagina de 4K - Teclado + ISR  0x0010-0000 a 0x0010-0FFF
  ;-----------------------------------------------------------------
  push PAG_P_YES
  push PAG_RW_R
  push PAG_US_SUP
  push PAG_PWT_NO
  push PAG_PCD_NO
  push PAG_A
  push PAG_D
  push PAG_PAT
  push PAG_G_YES
  push dword(__PT_TECLADO_ISR)
  push 0x100
  push dword(__PAGE_TABLES_VMA_LIN+0x1000)
  call __carga_TP 
  add esp,48


  ;------------------------  
  ;(0x3) 0x00C0-0000 a 0x00FF-FFFF
  ;   *RAM Video       0x00E8-0000
  ;------------------------

  ;-----------------------------------------------------------------
  ;5° Pagina de 4K - RAM de Video  0x00E8-0000 a 0x00E8-0000
  ;-----------------------------------------------------------------
  push PAG_P_YES
  push PAG_RW_W
  push PAG_US_SUP
  push PAG_PWT_NO
  push PAG_PCD_NO
  push PAG_A
  push PAG_D
  push PAG_PAT
  push PAG_G_YES
  push dword(__PT_VIDEO)
  push 0x280
  push dword(__PAGE_TABLES_VMA_LIN+0x1000+(0x1000*0x03))
  call __carga_TP 
  add esp,48

  ;------------------------
  ;(0x4) 0x0100-0000 a 0x013F-FFFF
  ;   *Digitos         0x0120-0000
  ;   *Datos           0x0121-0000
  ;   *Kernel          0x0122-0000
  ;   *Tarea 1 TEXT    0x0131-0000
  ;   *Tarea 1 BSS     0x0132-0000
  ;   *Tarea 1 DATA    0x0133-0000
  ;   *Tarea 1 RODATA  0x0134-0000
  ;------------------------

  ;-----------------------------------------------------------------
  ;6° Pagina de 4K - Digitos 0x0121-0000 a 0x0121-0FFF
  ;-----------------------------------------------------------------
  push PAG_P_YES
  push PAG_RW_W
  push PAG_US_SUP
  push PAG_PWT_NO
  push PAG_PCD_NO
  push PAG_A
  push PAG_D
  push PAG_PAT
  push PAG_G_YES
  push dword(__PT_DIGITOS)
  push 0x210
  push dword(__PAGE_TABLES_VMA_LIN+0x1000+(0x1000*0x04))
  call __carga_TP 
  add esp,48

  ;-----------------------------------------------------------------
  ;7° Pagina de 4K - Datos 0x0120-0000 a 0x0120-0FFF
  ;-----------------------------------------------------------------
  push PAG_P_YES
  push PAG_RW_W
  push PAG_US_SUP
  push PAG_PWT_NO
  push PAG_PCD_NO
  push PAG_A
  push PAG_D
  push PAG_PAT
  push PAG_G_YES
  push dword(__PT_DATOS)
  push 0x200
  push dword(__PAGE_TABLES_VMA_LIN+0x1000+(0x1000*0x04))
  call __carga_TP 
  add esp,48



  ;-----------------------------------------------------------------
  ;8° Pagina de 4K - Kernel 0x0122-0000 a 0x0122-0FFF
  ;-----------------------------------------------------------------
  push PAG_P_YES
  push PAG_RW_R
  push PAG_US_SUP
  push PAG_PWT_NO
  push PAG_PCD_NO
  push PAG_A
  push PAG_D
  push PAG_PAT
  push PAG_G_YES
  push dword(__PT_KERNEL)
  push 0x220
  push dword(__PAGE_TABLES_VMA_LIN+0x1000+(0x1000*0x04))
  call __carga_TP 
  add esp,48

  ;-----------------------------------------------------------------
  ; Pagina de 4K - TSS 0x01F0-0000
  ;-----------------------------------------------------------------
  push PAG_P_YES
  push PAG_RW_W
  push PAG_US_SUP
  push PAG_PWT_NO
  push PAG_PCD_NO
  push PAG_A
  push PAG_D
  push PAG_PAT
  push PAG_G_YES
  push dword(__PT_TSS_T1)
  push 0x1F0
  push dword(__PAGE_TABLES_VMA_LIN+0x1000+(0x1000*0x04))
  call __carga_TP 
  add esp,48
  
  push PAG_P_YES
  push PAG_RW_W
  push PAG_US_SUP
  push PAG_PWT_NO
  push PAG_PCD_NO
  push PAG_A
  push PAG_D
  push PAG_PAT
  push PAG_G_YES
  push dword(__PT_TSS_T2)
  push 0x1F1
  push dword(__PAGE_TABLES_VMA_LIN+0x1000+(0x1000*0x04))
  call __carga_TP 
  add esp,48

  push PAG_P_YES
  push PAG_RW_W
  push PAG_US_SUP
  push PAG_PWT_NO
  push PAG_PCD_NO
  push PAG_A
  push PAG_D
  push PAG_PAT
  push PAG_G_YES
  push dword(__PT_TSS_T3)
  push 0x1F2
  push dword(__PAGE_TABLES_VMA_LIN+0x1000+(0x1000*0x04))
  call __carga_TP 
  add esp,48

  push PAG_P_YES
  push PAG_RW_W
  push PAG_US_SUP
  push PAG_PWT_NO
  push PAG_PCD_NO
  push PAG_A
  push PAG_D
  push PAG_PAT
  push PAG_G_YES
  push dword(__PT_TSS_T4)
  push 0x1F3
  push dword(__PAGE_TABLES_VMA_LIN+0x1000+(0x1000*0x04))
  call __carga_TP 
  add esp,48

  push PAG_P_YES
  push PAG_RW_W
  push PAG_US_SUP
  push PAG_PWT_NO
  push PAG_PCD_NO
  push PAG_A
  push PAG_D
  push PAG_PAT
  push PAG_G_YES
  push dword(__PT_TSS_SYS)
  push 0x1F4
  push dword(__PAGE_TABLES_VMA_LIN+0x1000+(0x1000*0x04))
  call __carga_TP 
  add esp,48
  
  ;-----------------------------------------------------------------
  ; Si llegaste a leer esto tomate un cafe, porque lo que viene es durisimo
  ;-----------------------------------------------------------------
  ;0x2FFF-8000 / 0x0040-0000 = 191.99
  ;191*4MB = 0x2FC0-0000
  ;------------------------
  ;(0x2FC) 0x2FC0-0000 a  0x2FFF-FFFF
  ;   *Stack de Sistema 0x2FFF-8000
  ;------------------------

  ;-----------------------------------------------------------------
  ;13° Pagina de 4K - Stack de Sistema 0x1FFF-8000 a 0x1FFF-8FFF
  ;-----------------------------------------------------------------
  push PAG_P_YES
  push PAG_RW_W
  push PAG_US_SUP
  push PAG_PWT_NO
  push PAG_PCD_NO
  push PAG_A
  push PAG_D
  push PAG_PAT
  push PAG_G_YES
  push dword(__PT_STACK_SISTEMA)
  push 0x3F8
  push dword(__PAGE_TABLES_VMA_LIN+0x1000+(0x1000*0x7F))
  call __carga_TP 
  add esp,48

  ;------------------------
  ;(0x1) 0x0040-0000 a 0x007F-FFFF
  ;   *Stack Tarea 1   0x0078-F000
  ;------------------------


  ;0xFFFF-0000 / 0x0040-0000 = 1023,98
  ;1023*4MB = 0x2FC0-0000
  ;0x3FF*0x400000 = 0xFFC00000
  ;------------------------
  ;(0xFFC) 0xFFC0-0000 a 0xFFFF-FFFF
  ;   *Init ROM de 64K 0xFFFF-0000 a 0xFFFF-0FFF
  ;   *VGA INIT        0xFFFF-E000 a 0xFFFF-EFFF
  ;   *                0xFFFF-F000 a 0xFFFF-FFFF
  ;   -INIT 32         0xFFFF-F700 a 0xFFFF-FFFF
  ;   -Funciones ROM   0xFFFF-F900 a 0xFFFF-FFFF
  ;   -Sys Tables 16   0xFFFF-FE00 a 0xFFFF-FFFF
  ;   -Reset Vector    0xFFFF-FF00 a 0xFFFF-FFFF
  ;------------------------

  ;paginas 14-29 (ROM de 64KB)
  call __pagina_rom

ret

;------------------------------------------------------------------------------------------------------------
;		paginacion_tarea_1
;
;	Funcion: 	Funcion para paginar las direcciones de la Tarea 1
;
;				
;------------------------------------------------------------------------------------------------------------
paginacion_tarea_1:
 
  push PAG_P_YES
  push PAG_RW_W
  push PAG_US_US
  push PAG_PWT_NO
  push PAG_PCD_NO
  push PAG_A
  push PAG_D
  push PAG_PAT
  push PAG_G_YES
  push dword(__PAGE_TABLES_VMA_TASK01_LIN)
  push 0x00C
  push dword(__PAGE_TABLES_VMA_LIN+0x1000+(0x1000*0x00))
  call __carga_TP 
  add esp,48

  push PAG_P_YES
  push PAG_RW_R
  push PAG_US_US 
  push PAG_PWT_NO
  push PAG_PCD_NO
  push PAG_A
  push PAG_D
  push PAG_PAT
  push PAG_G_YES
  push dword(__PT_TASK_01_TEXT)
  push 0x310
  push dword(__PAGE_TABLES_VMA_LIN+0x1000+(0x1000*0x04))
  call __carga_TP 
  add esp,48

  push PAG_P_YES
  push PAG_RW_W
  push PAG_US_US  
  push PAG_PWT_NO
  push PAG_PCD_NO
  push PAG_A
  push PAG_D
  push PAG_PAT
  push PAG_G_YES
  push dword(__PT_TASK_01_BSS)
  push 0x320
  push dword(__PAGE_TABLES_VMA_LIN+0x1000+(0x1000*0x04))
  call __carga_TP 
  add esp,48

  push PAG_P_YES
  push PAG_RW_W
  push PAG_US_US
  push PAG_PWT_NO
  push PAG_PCD_NO
  push PAG_A
  push PAG_D
  push PAG_PAT
  push PAG_G_YES
  push dword(__PT_TASK_01_DATA)
  push 0x330
  push dword(__PAGE_TABLES_VMA_LIN+0x1000+(0x1000*0x04))
  call __carga_TP 
  add esp,48

  push PAG_P_YES
  push PAG_RW_R
  push PAG_US_US
  push PAG_PWT_NO
  push PAG_PCD_NO
  push PAG_A
  push PAG_D
  push PAG_PAT
  push PAG_G_YES
  push dword(__PT_TASK_01_RODATA)
  push 0x340
  push dword(__PAGE_TABLES_VMA_LIN+0x1000+(0x1000*0x04))
  call __carga_TP 
  add esp,48

  ;-----------------------------------------------------------------
  ;14° Pagina de 4K - Stack de TASK 01 0x1FFF-F000 a 0x1FFF-FFFF    
  ;-----------------------------------------------------------------
  push PAG_P_YES
  push PAG_RW_W
  push PAG_US_US
  push PAG_PWT_NO
  push PAG_PCD_NO
  push PAG_A
  push PAG_D
  push PAG_PAT
  push PAG_G_YES
  push dword(__PT_TASK_01_STACK)
  push 0x38F
  push dword(__PAGE_TABLES_VMA_LIN+0x1000+(0x1000*0x01))
  call __carga_TP 
  add esp,48

  push PAG_P_YES
  push PAG_RW_W
  push PAG_US_SUP 
  push PAG_PWT_NO
  push PAG_PCD_NO
  push PAG_A
  push PAG_D
  push PAG_PAT
  push PAG_G_YES
  push dword(__PT_STACK_SISTEMA_T1)
  push 0x3F4
  push dword(__PAGE_TABLES_VMA_LIN+0x1000+(0x1000*0x7F))
  call __carga_TP 
  add esp,48

ret

;------------------------------------------------------------------------------------------------------------
;		paginacion_tarea_2
;
;	Funcion: 	Funcion para paginar las direcciones de la Tarea 2
;
;				
;------------------------------------------------------------------------------------------------------------
paginacion_tarea_2:
  
  push PAG_P_YES
  push PAG_RW_W
  push PAG_US_US
  push PAG_PWT_NO
  push PAG_PCD_NO
  push PAG_A
  push PAG_D
  push PAG_PAT
  push PAG_G_YES
  push dword(__PAGE_TABLES_VMA_TASK02_LIN)
  push 0x00D
  push dword(__PAGE_TABLES_VMA_LIN+0x1000+(0x1000*0x00))
  call __carga_TP 
  add esp,48

  push PAG_P_YES
  push PAG_RW_R
  push PAG_US_US
  push PAG_PWT_NO
  push PAG_PCD_NO
  push PAG_A
  push PAG_D
  push PAG_PAT
  push PAG_G_YES
  push dword(__PT_TASK_02_TEXT)
  push 0x010
  push dword(__PAGE_TABLES_VMA_LIN+0x1000+(0x1000*0x05))
  call __carga_TP 
  add esp,48

  push PAG_P_YES
  push PAG_RW_R
  push PAG_US_US
  push PAG_PWT_NO
  push PAG_PCD_NO
  push PAG_A
  push PAG_D
  push PAG_PAT
  push PAG_G_YES
  push dword(__PT_TASK_02_BSS)
  push 0x020
  push dword(__PAGE_TABLES_VMA_LIN+0x1000+(0x1000*0x05))
  call __carga_TP 
  add esp,48

  push PAG_P_YES
  push PAG_RW_W
  push PAG_US_US
  push PAG_PWT_NO
  push PAG_PCD_NO
  push PAG_A
  push PAG_D
  push PAG_PAT
  push PAG_G_YES
  push dword(__PT_TASK_02_DATA)
  push 0x030
  push dword(__PAGE_TABLES_VMA_LIN+0x1000+(0x1000*0x05))
  call __carga_TP 
  add esp,48

  push PAG_P_YES
  push PAG_RW_R
  push PAG_US_US
  push PAG_PWT_NO
  push PAG_PCD_NO
  push PAG_A
  push PAG_D
  push PAG_PAT
  push PAG_G_YES
  push dword(__PT_TASK_02_RODATA)
  push 0x040
  push dword(__PAGE_TABLES_VMA_LIN+0x1000+(0x1000*0x05))
  call __carga_TP 
  add esp,48

  push PAG_P_YES
  push PAG_RW_W
  push PAG_US_US
  push PAG_PWT_NO
  push PAG_PCD_NO
  push PAG_A
  push PAG_D
  push PAG_PAT
  push PAG_G_YES
  push dword(__PT_TASK_02_STACK)
  push 0x390
  push dword(__PAGE_TABLES_VMA_LIN+0x1000+(0x1000*0x01))
  call __carga_TP 
  add esp,48

  push PAG_P_YES
  push PAG_RW_W
  push PAG_US_SUP 
  push PAG_PWT_NO
  push PAG_PCD_NO
  push PAG_A
  push PAG_D
  push PAG_PAT
  push PAG_G_YES
  push dword(__PT_STACK_SISTEMA_T2)
  push 0x3F5
  push dword(__PAGE_TABLES_VMA_LIN+0x1000+(0x1000*0x7F))
  call __carga_TP 
  add esp,48


ret


;------------------------------------------------------------------------------------------------------------
;		paginacion_tarea_3
;
;	Funcion: 	Función para paginar las direcciones de la Tarea 3
;
;				
;------------------------------------------------------------------------------------------------------------
paginacion_tarea_3:

  push PAG_P_YES
  push PAG_RW_W
  push PAG_US_US ;Cambiar a US
  push PAG_PWT_NO
  push PAG_PCD_NO
  push PAG_A
  push PAG_D
  push PAG_PAT
  push PAG_G_YES
  push dword(__PAGE_TABLES_VMA_TASK03_LIN)
  push 0x00E
  push dword(__PAGE_TABLES_VMA_LIN+0x1000+(0x1000*0x00))
  call __carga_TP 
  add esp,48

  push PAG_P_YES
  push PAG_RW_R
  push PAG_US_US ;Cambiar a US
  push PAG_PWT_NO
  push PAG_PCD_NO
  push PAG_A
  push PAG_D
  push PAG_PAT
  push PAG_G_YES
  push dword(__PT_TASK_03_TEXT)
  push 0x110
  push dword(__PAGE_TABLES_VMA_LIN+0x1000+(0x1000*0x05))
  call __carga_TP 
  add esp,48

  push PAG_P_YES
  push PAG_RW_R
  push PAG_US_US ;Cambiar a US
  push PAG_PWT_NO
  push PAG_PCD_NO
  push PAG_A
  push PAG_D
  push PAG_PAT
  push PAG_G_YES
  push dword(__PT_TASK_03_BSS)
  push 0x120
  push dword(__PAGE_TABLES_VMA_LIN+0x1000+(0x1000*0x05))
  call __carga_TP 
  add esp,48

  push PAG_P_YES
  push PAG_RW_R
  push PAG_US_US ;Cambiar a US
  push PAG_PWT_NO
  push PAG_PCD_NO
  push PAG_A
  push PAG_D
  push PAG_PAT
  push PAG_G_YES
  push dword(__PT_TASK_03_DATA)
  push 0x130
  push dword(__PAGE_TABLES_VMA_LIN+0x1000+(0x1000*0x05))
  call __carga_TP 
  add esp,48

  push PAG_P_YES
  push PAG_RW_R
  push PAG_US_US ;Cambiar a US
  push PAG_PWT_NO
  push PAG_PCD_NO
  push PAG_A
  push PAG_D
  push PAG_PAT
  push PAG_G_YES
  push dword(__PT_TASK_03_RODATA)
  push 0x140
  push dword(__PAGE_TABLES_VMA_LIN+0x1000+(0x1000*0x05))
  call __carga_TP 
  add esp,48

  push PAG_P_YES
  push PAG_RW_W
  push PAG_US_US ;Cambiar a US
  push PAG_PWT_NO
  push PAG_PCD_NO
  push PAG_A
  push PAG_D
  push PAG_PAT
  push PAG_G_YES
  push dword(__PT_TASK_03_STACK)
  push 0x391
  push dword(__PAGE_TABLES_VMA_LIN+0x1000+(0x1000*0x01))
  call __carga_TP 
  add esp,48

  push PAG_P_YES
  push PAG_RW_W
  push PAG_US_SUP 
  push PAG_PWT_NO
  push PAG_PCD_NO
  push PAG_A
  push PAG_D
  push PAG_PAT
  push PAG_G_YES
  push dword(__PT_STACK_SISTEMA_T3)
  push 0x3F6
  push dword(__PAGE_TABLES_VMA_LIN+0x1000+(0x1000*0x7F))
  call __carga_TP 
  add esp,48

ret

;------------------------------------------------------------------------------------------------------------
;		paginacion_tarea_4
;
;	Funcion: 	Función para paginar las direcciones de la Tarea 4
;
;				
;------------------------------------------------------------------------------------------------------------
paginacion_tarea_4:

  push PAG_P_YES
  push PAG_RW_W
  push PAG_US_US ;Cambiar a US
  push PAG_PWT_NO
  push PAG_PCD_NO
  push PAG_A
  push PAG_D
  push PAG_PAT
  push PAG_G_YES
  push dword(__PAGE_TABLES_VMA_TASK04_LIN)
  push 0x00F
  push dword(__PAGE_TABLES_VMA_LIN+0x1000+(0x1000*0x00))
  call __carga_TP 
  add esp,48

  push PAG_P_YES
  push PAG_RW_R
  push PAG_US_US ;Cambiar a US
  push PAG_PWT_NO
  push PAG_PCD_NO
  push PAG_A
  push PAG_D
  push PAG_PAT
  push PAG_G_YES
  push dword(__PT_TASK_04_TEXT)
  push 0x210
  push dword(__PAGE_TABLES_VMA_LIN+0x1000+(0x1000*0x05))
  call __carga_TP 
  add esp,48

  push PAG_P_YES
  push PAG_RW_R
  push PAG_US_US ;Cambiar a US
  push PAG_PWT_NO
  push PAG_PCD_NO
  push PAG_A
  push PAG_D
  push PAG_PAT
  push PAG_G_YES
  push dword(__PT_TASK_04_BSS)
  push 0x220
  push dword(__PAGE_TABLES_VMA_LIN+0x1000+(0x1000*0x05))
  call __carga_TP 
  add esp,48

  push PAG_P_YES
  push PAG_RW_R
  push PAG_US_US ;Cambiar a US
  push PAG_PWT_NO
  push PAG_PCD_NO
  push PAG_A
  push PAG_D
  push PAG_PAT
  push PAG_G_YES
  push dword(__PT_TASK_04_DATA)
  push 0x230
  push dword(__PAGE_TABLES_VMA_LIN+0x1000+(0x1000*0x05))
  call __carga_TP 
  add esp,48

  push PAG_P_YES
  push PAG_RW_R
  push PAG_US_US ;Cambiar a US
  push PAG_PWT_NO
  push PAG_PCD_NO
  push PAG_A
  push PAG_D
  push PAG_PAT
  push PAG_G_YES
  push dword(__PT_TASK_04_RODATA)
  push 0x240
  push dword(__PAGE_TABLES_VMA_LIN+0x1000+(0x1000*0x05))
  call __carga_TP 
  add esp,48

  push PAG_P_YES
  push PAG_RW_W
  push PAG_US_US ;Cambiar a uS
  push PAG_PWT_NO
  push PAG_PCD_NO
  push PAG_A
  push PAG_D
  push PAG_PAT
  push PAG_G_YES
  push dword(__PT_TASK_04_STACK)
  push 0x392
  push dword(__PAGE_TABLES_VMA_LIN+0x1000+(0x1000*0x01))
  call __carga_TP 
  add esp,48

  push PAG_P_YES
  push PAG_RW_W
  push PAG_US_SUP 
  push PAG_PWT_NO
  push PAG_PCD_NO
  push PAG_A
  push PAG_D
  push PAG_PAT
  push PAG_G_YES
  push dword(__PT_STACK_SISTEMA_T4)
  push 0x3F7
  push dword(__PAGE_TABLES_VMA_LIN+0x1000+(0x1000*0x7F))
  call __carga_TP 
  add esp,48
    
ret


;------------------------------------------------------------------------------------------------------------
;		DTP_task01
;
;	Funcion: 	Función que carga las DTP correspondientes a la tarea 1.
;
;				
;------------------------------------------------------------------------------------------------------------


DTP_task01:

    push PAG_P_YES          
    push PAG_RW_W
    push PAG_US_US
    push PAG_PWT_NO
    push PAG_PCD_NO
    push PAG_A
    push PAG_PS_4K
    push dword(__PAGE_TABLES_VMA_TASK01_LIN+0x5000+0x1000*0x00)      
    push 0x00                               
    push dword(__PAGE_TABLES_VMA_TASK01_LIN)             
    call __carga_DTP
    add esp,40

    push PAG_P_YES          
    push PAG_RW_W
    push PAG_US_US
    push PAG_PWT_NO
    push PAG_PCD_NO
    push PAG_A
    push PAG_PS_4K
    push dword(__PAGE_TABLES_VMA_TASK01_LIN+0x5000+0x1000*0x03)      
    push 0x03                               
    push dword(__PAGE_TABLES_VMA_TASK01_LIN)             
    call __carga_DTP
    add esp,40

    push PAG_P_YES          
    push PAG_RW_W
    push PAG_US_US
    push PAG_PWT_NO
    push PAG_PCD_NO
    push PAG_A
    push PAG_PS_4K
    push dword(__PAGE_TABLES_VMA_TASK01_LIN+0x5000+0x1000*0x04)      
    push 0x04                               
    push dword(__PAGE_TABLES_VMA_TASK01_LIN)             
    call __carga_DTP
    add esp,40

    push PAG_P_YES          
    push PAG_RW_W
    push PAG_US_US
    push PAG_PWT_NO
    push PAG_PCD_NO
    push PAG_A
    push PAG_PS_4K
    push dword(__PAGE_TABLES_VMA_TASK01_LIN+0x5000+0x1000*0x7F)      
    push 0x7F                               
    push dword(__PAGE_TABLES_VMA_TASK01_LIN)             
    call __carga_DTP
    add esp,40

    push PAG_P_YES          
    push PAG_RW_W
    push PAG_US_US
    push PAG_PWT_NO
    push PAG_PCD_NO
    push PAG_A
    push PAG_PS_4K
    push dword(__PAGE_TABLES_VMA_TASK01_LIN+0x5000+0x1000*0x001)      
    push 0x001                               
    push dword(__PAGE_TABLES_VMA_TASK01_LIN)            
    call __carga_DTP
    add esp,40

    push PAG_P_YES          
    push PAG_RW_W
    push PAG_US_US
    push PAG_PWT_NO
    push PAG_PCD_NO
    push PAG_A
    push PAG_PS_4K
    push dword(__PAGE_TABLES_VMA_TASK01_LIN+0x5000+0x1000*0x3FF)      
    push 0x3FF                               
    push dword(__PAGE_TABLES_VMA_TASK01_LIN)            
    call __carga_DTP
    add esp,40
ret


;------------------------------------------------------------------------------------------------------------
;		DTP_task02
;
;	Funcion: 	Función que carga las DTP correspondientes a la tarea 2
;
;				
;------------------------------------------------------------------------------------------------------------

DTP_task02:

    push PAG_P_YES          
    push PAG_RW_W
    push PAG_US_US
    push PAG_PWT_NO
    push PAG_PCD_NO
    push PAG_A
    push PAG_PS_4K
    push dword(__PAGE_TABLES_VMA_TASK02_LIN+0x4000+0x1000*0x00)      
    push 0x00                              
    push dword(__PAGE_TABLES_VMA_TASK02_LIN)             
    call __carga_DTP
    add esp,40

    push PAG_P_YES          
    push PAG_RW_W
    push PAG_US_US
    push PAG_PWT_NO
    push PAG_PCD_NO
    push PAG_A
    push PAG_PS_4K
    push dword(__PAGE_TABLES_VMA_TASK02_LIN+0x4000+0x1000*0x03)      
    push 0x03                         
    push dword(__PAGE_TABLES_VMA_TASK02_LIN)             
    call __carga_DTP
    add esp,40

    push PAG_P_YES          
    push PAG_RW_W
    push PAG_US_US
    push PAG_PWT_NO
    push PAG_PCD_NO
    push PAG_A
    push PAG_PS_4K
    push dword(__PAGE_TABLES_VMA_TASK02_LIN+0x4000+0x1000*0x04)      
    push 0x04                               
    push dword(__PAGE_TABLES_VMA_TASK02_LIN)             
    call __carga_DTP
    add esp,40

    push PAG_P_YES          
    push PAG_RW_W
    push PAG_US_US
    push PAG_PWT_NO
    push PAG_PCD_NO
    push PAG_A
    push PAG_PS_4K
    push dword(__PAGE_TABLES_VMA_TASK02_LIN+0x4000+0x1000*0x05)      
    push 0x05                               
    push dword(__PAGE_TABLES_VMA_TASK02_LIN)             
    call __carga_DTP
    add esp,40

    push PAG_P_YES          
    push PAG_RW_W
    push PAG_US_US
    push PAG_PWT_NO
    push PAG_PCD_NO
    push PAG_A
    push PAG_PS_4K
    push dword(__PAGE_TABLES_VMA_TASK02_LIN+0x4000+0x1000*0x7F)      
    push 0x7F                               
    push dword(__PAGE_TABLES_VMA_TASK02_LIN)            
    call __carga_DTP
    add esp,40

    push PAG_P_YES          
    push PAG_RW_W
    push PAG_US_US
    push PAG_PWT_NO
    push PAG_PCD_NO
    push PAG_A
    push PAG_PS_4K
    push dword(__PAGE_TABLES_VMA_TASK02_LIN+0x4000+0x1000*0x001)      
    push 0x001                               
    push dword(__PAGE_TABLES_VMA_TASK02_LIN)            
    call __carga_DTP
    add esp,40

    push PAG_P_YES          
    push PAG_RW_W
    push PAG_US_US
    push PAG_PWT_NO
    push PAG_PCD_NO
    push PAG_A
    push PAG_PS_4K
    push dword(__PAGE_TABLES_VMA_TASK02_LIN+0x4000+0x1000*0x3FF)      
    push 0x3FF                               
    push dword(__PAGE_TABLES_VMA_TASK02_LIN)            
    call __carga_DTP
    add esp,40


ret

;------------------------------------------------------------------------------------------------------------
;		DTP_task03
;
;	Funcion: 	Función que carga el las DTP para la tarea 3
;
;				
;------------------------------------------------------------------------------------------------------------

DTP_task03:
    push PAG_P_YES          
    push PAG_RW_W
    push PAG_US_US
    push PAG_PWT_NO
    push PAG_PCD_NO
    push PAG_A
    push PAG_PS_4K
    push dword(__PAGE_TABLES_VMA_TASK03_LIN+0x3000+0x1000*0x00)      
    push 0x00                               
    push dword(__PAGE_TABLES_VMA_TASK03_LIN)             
    call __carga_DTP
    add esp,40

    push PAG_P_YES          
    push PAG_RW_W
    push PAG_US_US
    push PAG_PWT_NO
    push PAG_PCD_NO
    push PAG_A
    push PAG_PS_4K
    push dword(__PAGE_TABLES_VMA_TASK03_LIN+0x3000+0x1000*0x03)      
    push 0x03                               
    push dword(__PAGE_TABLES_VMA_TASK03_LIN)             
    call __carga_DTP
    add esp,40

    push PAG_P_YES          
    push PAG_RW_W
    push PAG_US_US
    push PAG_PWT_NO
    push PAG_PCD_NO
    push PAG_A
    push PAG_PS_4K
    push dword(__PAGE_TABLES_VMA_TASK03_LIN+0x3000+0x1000*0x04)      
    push 0x04                               
    push dword(__PAGE_TABLES_VMA_TASK03_LIN)             
    call __carga_DTP
    add esp,40

    push PAG_P_YES          
    push PAG_RW_W
    push PAG_US_US
    push PAG_PWT_NO
    push PAG_PCD_NO
    push PAG_A
    push PAG_PS_4K
    push dword(__PAGE_TABLES_VMA_TASK03_LIN+0x3000+0x1000*0x05)      
    push 0x05                               
    push dword(__PAGE_TABLES_VMA_TASK03_LIN)             
    call __carga_DTP
    add esp,40

    push PAG_P_YES          
    push PAG_RW_W
    push PAG_US_US
    push PAG_PWT_NO
    push PAG_PCD_NO
    push PAG_A
    push PAG_PS_4K
    push dword(__PAGE_TABLES_VMA_TASK03_LIN+0x3000+0x1000*0x7F)      
    push 0x7F                               
    push dword(__PAGE_TABLES_VMA_TASK03_LIN)             
    call __carga_DTP
    add esp,40

    push PAG_P_YES          
    push PAG_RW_W
    push PAG_US_US
    push PAG_PWT_NO
    push PAG_PCD_NO
    push PAG_A
    push PAG_PS_4K
    push dword(__PAGE_TABLES_VMA_TASK03_LIN+0x3000+0x1000*0x01)      
    push 0x01                               
    push dword(__PAGE_TABLES_VMA_TASK03_LIN)             
    call __carga_DTP
    add esp,40

    push PAG_P_YES          
    push PAG_RW_W
    push PAG_US_US
    push PAG_PWT_NO
    push PAG_PCD_NO
    push PAG_A
    push PAG_PS_4K
    push dword(__PAGE_TABLES_VMA_TASK03_LIN+0x3000+0x1000*0x3FF)      
    push 0x3FF                               
    push dword(__PAGE_TABLES_VMA_TASK03_LIN)            
    call __carga_DTP
    add esp,40
ret

;------------------------------------------------------------------------------------------------------------
;		DTP_task01
;
;	Funcion: 	Función que carga el las DTP correspondienes para la tarea 4
;
;				
;------------------------------------------------------------------------------------------------------------
DTP_task04:

    push PAG_P_YES          
    push PAG_RW_W
    push PAG_US_US
    push PAG_PWT_NO
    push PAG_PCD_NO
    push PAG_A
    push PAG_PS_4K
    push dword(__PAGE_TABLES_VMA_TASK04_LIN+0x2000+0x1000*0x00)      
    push 0x00                               
    push dword(__PAGE_TABLES_VMA_TASK04_LIN)             
    call __carga_DTP
    add esp,40

    push PAG_P_YES          
    push PAG_RW_W
    push PAG_US_US
    push PAG_PWT_NO
    push PAG_PCD_NO
    push PAG_A
    push PAG_PS_4K
    push dword(__PAGE_TABLES_VMA_TASK04_LIN+0x2000+0x1000*0x03)      
    push 0x03                               
    push dword(__PAGE_TABLES_VMA_TASK04_LIN)             
    call __carga_DTP
    add esp,40

    push PAG_P_YES          
    push PAG_RW_W
    push PAG_US_US
    push PAG_PWT_NO
    push PAG_PCD_NO
    push PAG_A
    push PAG_PS_4K
    push dword(__PAGE_TABLES_VMA_TASK04_LIN+0x2000+0x1000*0x04)      
    push 0x04                               
    push dword(__PAGE_TABLES_VMA_TASK04_LIN)             
    call __carga_DTP
    add esp,40

    push PAG_P_YES          
    push PAG_RW_W
    push PAG_US_US
    push PAG_PWT_NO
    push PAG_PCD_NO
    push PAG_A
    push PAG_PS_4K
    push dword(__PAGE_TABLES_VMA_TASK04_LIN+0x2000+0x1000*0x05)      
    push 0x05                               
    push dword(__PAGE_TABLES_VMA_TASK04_LIN)             
    call __carga_DTP
    add esp,40

    push PAG_P_YES          
    push PAG_RW_W
    push PAG_US_US
    push PAG_PWT_NO
    push PAG_PCD_NO
    push PAG_A
    push PAG_PS_4K
    push dword(__PAGE_TABLES_VMA_TASK04_LIN+0x2000+0x1000*0x07F)      
    push 0x7F                               
    push dword(__PAGE_TABLES_VMA_TASK04_LIN)             
    call __carga_DTP
    add esp,40

    push PAG_P_YES          
    push PAG_RW_W
    push PAG_US_US
    push PAG_PWT_NO
    push PAG_PCD_NO
    push PAG_A
    push PAG_PS_4K
    push dword(__PAGE_TABLES_VMA_TASK04_LIN+0x2000+0x1000*0x001)      
    push 0x01                               
    push dword(__PAGE_TABLES_VMA_TASK04_LIN)             
    call __carga_DTP
    add esp,40

    push PAG_P_YES          
    push PAG_RW_W
    push PAG_US_US
    push PAG_PWT_NO
    push PAG_PCD_NO
    push PAG_A
    push PAG_PS_4K
    push dword(__PAGE_TABLES_VMA_TASK04_LIN+0x2000+0x1000*0x3FF)      
    push 0x3FF                               
    push dword(__PAGE_TABLES_VMA_TASK04_LIN)            
    call __carga_DTP
    add esp,40
ret

;------------------------------------------------------------------------------------------------------------
;		cargo_CR3
;
;	Funcion: 	Función que carga el CR3 para paginacion.
;
;				
;------------------------------------------------------------------------------------------------------------
cargo_CR3:
  xor eax,eax
  push __PAGE_TABLES_VMA_LIN
  push 0x18;
      ;PWT SI
      ;PCD SI
  call __carga_CR3
  add esp,8
  mov cr3,eax
ret

;------------------------------------------------------------------------------------------------------------
;		__TSS_SYS_INIT
;
;	Funcion: Inicia la TSS de sistema.
;
;				
;------------------------------------------------------------------------------------------------------------
GLOBAL __TSS_SYS_INIT
GLOBAL __TSS_INIT
EXTERN __TSS_TASK_01_LIN
EXTERN __TSS_TASK_02_LIN
EXTERN __TSS_TASK_03_LIN
EXTERN __TSS_TASK_04_LIN
EXTERN ciclo1
EXTERN ciclo2
EXTERN ciclo3
EXTERN ciclo4
EXTERN __TASK_01_STACK_END_LIN
EXTERN __TASK_02_STACK_END_LIN
EXTERN __TASK_03_STACK_END_LIN
EXTERN __TASK_04_STACK_END_LIN
EXTERN DS_SEL_32_US
EXTERN CS_SEL_32_US
EXTERN __STACK_END_32_T1
EXTERN __STACK_END_32_T2
EXTERN __STACK_END_32_T3
EXTERN __STACK_END_32_T4
EXTERN __TSS_SISTEMA_LIN
EXTERN DS_SEL_32

__TSS_SYS_INIT:
    mov dword eax,[__TSS_TASK_01_LIN + 1*04]   ;ESP0
    mov dword[__TSS_SISTEMA_LIN+1*04],eax       

    mov dword eax,[__TSS_TASK_01_LIN + 2*04]   ;SS0
    mov dword[__TSS_SISTEMA_LIN+2*04],eax       

    mov dword eax,[__TSS_TASK_01_LIN + 7*04]    ;CR3
    mov dword [__TSS_SISTEMA_LIN + 7*04],eax

    mov dword eax,0x200                         ;EFLAGS
    mov dword [__TSS_SISTEMA_LIN + 8*04],eax   

    mov dword eax,[__TSS_TASK_01_LIN + 14*04]   ;ESP3
    mov dword[__TSS_SISTEMA_LIN+14*04],eax       

    mov dword eax,[__TSS_TASK_01_LIN + 19*04]   ;ESP3
    mov dword[__TSS_SISTEMA_LIN+19*04],eax       

    mov dword eax,[__TSS_TASK_01_LIN + 20*04]   ;SS3
    mov dword[__TSS_SISTEMA_LIN+20*04],eax       


ret



;------------------------------------------------------------------------------------------------------------
;		__TSS_INIT
;
;	Funcion: Carga las TSS de todas las tareas.
;
;				
;------------------------------------------------------------------------------------------------------------

__TSS_INIT:
    mov dword[__TSS_TASK_01_LIN + 1*04],(__STACK_END_32_T1-5*04)            ;ESP0
    mov word [__TSS_TASK_01_LIN + 2*04],DS_SEL_32                    ;SS0
    mov eax,__PAGE_TABLES_VMA_TASK01_LIN     
    mov [__TSS_TASK_01_LIN + 7*04],eax                               ;CR3
    mov eax,ciclo1   
    mov [__TSS_TASK_01_LIN + 8*04],eax                               ;EIP
    mov dword[__TSS_TASK_01_LIN + 14*04],(__TASK_01_STACK_END_LIN-4*5)     ;ESP
    mov word [__TSS_TASK_01_LIN + 18*04],DS_SEL_32_US                ;ES
    mov word [__TSS_TASK_01_LIN + 19*04],CS_SEL_32_US                ;CS
    mov word [__TSS_TASK_01_LIN + 20*04],DS_SEL_32_US                ;SS
    mov word [__TSS_TASK_01_LIN + 21*04],DS_SEL_32_US                ;DS
    mov word [__TSS_TASK_01_LIN + 22*04],DS_SEL_32_US                ;FS
    mov word [__TSS_TASK_01_LIN + 23*04],DS_SEL_32_US                ;GS

    mov dword eax,[__TSS_TASK_01_LIN+8*04] ;EIP
    mov dword [__STACK_END_32_T1-5*04],eax
    mov dword eax,[__TSS_TASK_01_LIN+19*04] ;CS_US
    add eax,0x3
    mov dword [__STACK_END_32_T1-4*04],eax    
    mov dword eax,[__TSS_TASK_01_LIN+9*04] ;EFLAGS
    or eax,0x202
    mov dword [__STACK_END_32_T1-3*04],eax        
    mov dword eax,[__TSS_TASK_01_LIN+14*04] ;ESP3
    mov dword [__STACK_END_32_T1-2*04],eax    
    mov dword eax,[__TSS_TASK_01_LIN+20*04] ;SS3
    mov dword [__STACK_END_32_T1-1*04],eax

    mov dword[__TSS_TASK_02_LIN + 1*04],(__STACK_END_32_T2-5*04)     ;ESP0    
    mov word [__TSS_TASK_02_LIN + 2*04],DS_SEL_32                    ;SS0
    mov eax,__PAGE_TABLES_VMA_TASK02_LIN     
    mov [__TSS_TASK_02_LIN + 7*04],eax                               ;CR3
    mov eax,ciclo2   
    mov [__TSS_TASK_02_LIN + 8*04],eax                               ;EIP
    mov dword[__TSS_TASK_02_LIN + 14*04],__TASK_02_STACK_END_LIN     ;ESP
    mov word [__TSS_TASK_02_LIN + 18*04],DS_SEL_32_US                ;ES
    mov word [__TSS_TASK_02_LIN + 19*04],CS_SEL_32_US                ;CS
    mov word [__TSS_TASK_02_LIN + 20*04],DS_SEL_32_US                ;SS
    mov word [__TSS_TASK_02_LIN + 21*04],DS_SEL_32_US                ;DS
    mov word [__TSS_TASK_02_LIN + 22*04],DS_SEL_32_US                ;FS
    mov word [__TSS_TASK_02_LIN + 23*04],DS_SEL_32_US                ;GS    

    mov dword eax,[__TSS_TASK_02_LIN+8*04] ;EIP
    mov dword [__STACK_END_32_T2-5*04],eax
    mov dword eax,[__TSS_TASK_02_LIN+19*04] ;CS_US
    add eax,0x3
    mov dword [__STACK_END_32_T2-4*04],eax    
    mov dword eax,[__TSS_TASK_02_LIN+9*04] ;EFLAGS
    or eax,0x202
    mov dword [__STACK_END_32_T2-3*04],eax        
    mov dword eax,[__TSS_TASK_02_LIN+14*04] ;ESP3
    mov dword [__STACK_END_32_T2-2*04],eax    
    mov dword eax,[__TSS_TASK_02_LIN+20*04] ;SS3
    mov dword [__STACK_END_32_T2-1*04],eax


    mov dword[__TSS_TASK_03_LIN + 1*04],(__STACK_END_32_T3-5*04)            ;ESP0    
    mov word [__TSS_TASK_03_LIN + 2*04],DS_SEL_32                    ;SS0
    mov eax,__PAGE_TABLES_VMA_TASK01_LIN     
    mov [__TSS_TASK_03_LIN + 7*04],eax                               ;CR3
    mov eax,ciclo3   
    mov [__TSS_TASK_03_LIN + 8*04],eax                               ;EIP
    mov dword[__TSS_TASK_03_LIN + 14*04],__TASK_03_STACK_END_LIN     ;ESP
    mov word [__TSS_TASK_03_LIN + 18*04],DS_SEL_32_US                ;ES
    mov word [__TSS_TASK_03_LIN + 19*04],CS_SEL_32_US                ;CS
    mov word [__TSS_TASK_03_LIN + 20*04],DS_SEL_32_US                ;SS
    mov word [__TSS_TASK_03_LIN + 21*04],DS_SEL_32_US                ;DS
    mov word [__TSS_TASK_03_LIN + 22*04],DS_SEL_32_US                ;FS
    mov word [__TSS_TASK_03_LIN + 23*04],DS_SEL_32_US                ;GS    

    mov dword eax,[__TSS_TASK_03_LIN+8*04] ;EIP
    mov dword [__STACK_END_32_T3-5*04],eax
    mov dword eax,[__TSS_TASK_03_LIN+19*04] ;CS_US
    add eax,0x3
    mov dword [__STACK_END_32_T3-4*04],eax    
    mov dword eax,[__TSS_TASK_03_LIN+9*04] ;EFLAGS
    or eax,0x202
    mov dword [__STACK_END_32_T3-3*04],eax        
    mov dword eax,[__TSS_TASK_03_LIN+14*04] ;ESP3
    mov dword [__STACK_END_32_T3-2*04],eax    
    mov dword eax,[__TSS_TASK_03_LIN+20*04] ;SS3
    mov dword [__STACK_END_32_T3-1*04],eax

    mov dword[__TSS_TASK_04_LIN + 1*04],(__STACK_END_32_T4-5*04)     ;ESP0
    mov word [__TSS_TASK_04_LIN + 2*04],DS_SEL_32                    ;SS0
    mov eax,__PAGE_TABLES_VMA_TASK04_LIN
    mov [__TSS_TASK_04_LIN + 7*04],eax                               ;CR3
    mov eax,ciclo4
    mov [__TSS_TASK_04_LIN + 8*04],eax                               ;EIP
    mov dword[__TSS_TASK_04_LIN + 14*04],__TASK_04_STACK_END_LIN     ;ESP
    mov word [__TSS_TASK_04_LIN + 18*04],DS_SEL_32_US                ;ES
    mov word [__TSS_TASK_04_LIN + 19*04],CS_SEL_32_US                ;CS
    mov word [__TSS_TASK_04_LIN + 20*04],DS_SEL_32_US                ;SS
    mov word [__TSS_TASK_04_LIN + 21*04],DS_SEL_32_US                ;DS
    mov word [__TSS_TASK_04_LIN + 22*04],DS_SEL_32_US                ;FS
    mov word [__TSS_TASK_04_LIN + 23*04],DS_SEL_32_US                ;GS

    mov dword eax,[__TSS_TASK_04_LIN+8*04] ;EIP
    mov dword [__STACK_END_32_T4-5*04],eax
    mov dword eax,[__TSS_TASK_04_LIN+19*04] ;CS_US
    add eax,0x3
    mov dword [__STACK_END_32_T4-4*04],eax    
    mov dword eax,[__TSS_TASK_04_LIN+9*04] ;EFLAGS
    or eax,0x202
    mov dword [__STACK_END_32_T4-3*04],eax        
    mov dword eax,[__TSS_TASK_04_LIN+14*04] ;ESP3
    mov dword [__STACK_END_32_T4-2*04],eax    
    mov dword eax,[__TSS_TASK_04_LIN+20*04] ;SS3
    mov dword [__STACK_END_32_T4-1*04],eax
;[ESP+4*1]=EIP
;[ESP+4*2]=CS_US
;[ESP+4*3]=EFLAGS
;[ESP+4*4]=ESP3
;[ESP+4*5]=SS3
ret
