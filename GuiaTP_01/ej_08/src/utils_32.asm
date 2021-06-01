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

;Funciones de C externas
EXTERN  __carga_GDT
EXTERN  __carga_IDT
EXTERN  __carga_DTP
EXTERN  __carga_TP
EXTERN  __carga_CR3
EXTERN  __clean_dir
EXTERN  __pagina_rom

;Labels para Paginación
EXTERN __PAGE_TABLES_VMA
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
EXTERN __PT_STACK_SISTEMA      

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
;   *RAM VIDEO       0x000B-8000
;   *Teclado + ISR   0x0010-0000
;   *Digitos         0x0020-0000
;   *Datos           0x0021-0000
;   *Kernel          0x0022-0000
;   *Tarea 1 TEXT    0x0031-0000
;   *Tarea 1 BSS     0x0032-0000
;   *Tarea 1 DATA    0x0033-0000
;   *Tarea 1 RODATA  0x0034-0000
;------------------------
;(0x1) VACIA
;------------------------
; (..)
;------------------------
;(0x2FC) 0x2FC0-0000 a 0x2FFF-FFFF
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
    push PAG_US_SUP
    push PAG_PWT_NO
    push PAG_PCD_NO
    push PAG_A
    push PAG_PS_4K
    push dword(__PAGE_TABLES_VMA+0x1000)      
    push 0x00                               
    push dword(__PAGE_TABLES_VMA)             
    call __carga_DTP
    add esp,40

    ;------------------------
    ;DTP(0x2FC) 0x2FC0-0000 a 0x2FFF-FFFF
    ;------------------------
    push PAG_P_YES          
    push PAG_RW_W
    push PAG_US_SUP
    push PAG_PWT_NO
    push PAG_PCD_NO
    push PAG_A
    push PAG_PS_4K
    ;push dword(__PAGE_TABLES_VMA+0x1000+0x1000*0xBF)      
    ;push 0xBF                               
    push dword(__PAGE_TABLES_VMA+0x1000+0x1000*0x7F)      
    push 0x7F                               
    push dword(__PAGE_TABLES_VMA)            
    call __carga_DTP
    add esp,40

    ;------------------------
    ;(0xFFC) 0xFFC0-0000 a 0xFFFF-FFFF
    ;------------------------
    push PAG_P_YES          
    push PAG_RW_W
    push PAG_US_SUP
    push PAG_PWT_NO
    push PAG_PCD_NO
    push PAG_A
    push PAG_PS_4K
    push dword(__PAGE_TABLES_VMA+0x1000+0x1000*0x3FF)      
    push 0x3FF                               
    push dword(__PAGE_TABLES_VMA)            
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

  ;------------------------
  ;(0x0) 0x0000-0000 a 0x003F-FFFF
  ;   *Sys_tables      0x0000-0000
  ;   *Tablas de Pag.  0x0001-0000
  ;   *Rutinas         0x0005-0000
  ;   *RAM VIDEO       0x000B-8000
  ;   *Teclado + ISR   0x0010-0000
  ;   *Digitos         0x0020-0000
  ;   *Datos           0x0021-0000
  ;   *Kernel          0x0022-0000
  ;   *Tarea 1 TEXT    0x0031-0000
  ;   *Tarea 1 BSS     0x0032-0000
  ;   *Tarea 1 DATA    0x0033-0000
  ;   *Tarea 1 RODATA  0x0034-0000
  ;------------------------
  
  ;-----------------------------------------------------------------
  ;1° Pagina de 4K - Sys Tables  0x0000-0000 a 0x0000-0FFF
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
  push dword(__PT_SYS_TABLES)
  push 0x00
  push dword(__PAGE_TABLES_VMA+0x1000)
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
  push dword(__PAGE_TABLES_VMA+0x1000)
  call __carga_TP 
  add esp,48

  ;-----------------------------------------------------------------
  ;3° Pagina de 4K - Rutinas de RAM  0x0005-0000 a 0x0005-0FFF
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
  push dword(__PT_FUNCIONES)
  push 0x050
  push dword(__PAGE_TABLES_VMA+0x1000)
  call __carga_TP 
  add esp,48

  ;-----------------------------------------------------------------
  ;4° Pagina de 4K - RAM de Video  0x000B-8000 a 0x000B-8FFF
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
  push 0x0B8
  push dword(__PAGE_TABLES_VMA+0x1000)
  call __carga_TP 
  add esp,48

  ;-----------------------------------------------------------------
  ;5° Pagina de 4K - Teclado + ISR  0x0010-0000 a 0x0010-0FFF
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
  push dword(__PT_TECLADO_ISR)
  push 0x100
  push dword(__PAGE_TABLES_VMA+0x1000)
  call __carga_TP 
  add esp,48

  ;-----------------------------------------------------------------
  ;6° Pagina de 4K - Datos 0x0020-0000 a 0x0020-0FFF
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
  push dword(__PAGE_TABLES_VMA+0x1000)
  call __carga_TP 
  add esp,48

  ;-----------------------------------------------------------------
  ;7° Pagina de 4K - Digitos 0x0021-0000 a 0x0021-0FFF
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
  push dword(__PAGE_TABLES_VMA+0x1000)
  call __carga_TP 
  add esp,48

  ;-----------------------------------------------------------------
  ;8° Pagina de 4K - Kernel 0x0022-0000 a 0x0022-0FFF
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
  push dword(__PT_KERNEL)
  push 0x220
  push dword(__PAGE_TABLES_VMA+0x1000)
  call __carga_TP 
  add esp,48

  ;-----------------------------------------------------------------
  ;9° Pagina de 4K - TEXT Tarea 1 0x0031-0000 a 0x0031-0FFF
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
  push dword(__PT_TASK_01_TEXT)
  push 0x310
  push dword(__PAGE_TABLES_VMA+0x1000)
  call __carga_TP 
  add esp,48

  ;-----------------------------------------------------------------
  ;10° Pagina de 4K - BSS Tarea 1 0x0032-0000 a 0x0032-0FFF
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
  push dword(__PT_TASK_01_BSS)
  push 0x320
  push dword(__PAGE_TABLES_VMA+0x1000)
  call __carga_TP 
  add esp,48

  ;-----------------------------------------------------------------
  ;11° Pagina de 4K - DATA Tarea 1 0x0033-0000 a 0x0033-0FFF
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
  push dword(__PT_TASK_01_DATA)
  push 0x330
  push dword(__PAGE_TABLES_VMA+0x1000)
  call __carga_TP 
  add esp,48

  ;-----------------------------------------------------------------
  ;12° Pagina de 4K - RODATA Tarea 1 0x0034-0000 a 0x0034-0FFF
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
  push dword(__PT_TASK_01_RODATA)
  push 0x340
  push dword(__PAGE_TABLES_VMA+0x1000)
  call __carga_TP 
  add esp,48

  ;-----------------------------------------------------------------
  ;Paginados los 1ros 4MB
  ;-----------------------------------------------------------------
  
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
  ;13° Pagina de 4K - Stack de Sistema 0x2FFF-8000 a 0x2FFF-8FFF
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
; #ISSUE
;  push 0x3F8
;  push dword(__PAGE_TABLES_VMA+0x1000+(0x1000*0xBF)) ;0xD0000
  push 0x308
  push dword(__PAGE_TABLES_VMA+0x1000+(0x1000*0x7F))
  call __carga_TP 
  add esp,48


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
;		cargo_CR3
;
;	Funcion: 	Función que carga el CR3 para paginacion.
;
;				
;------------------------------------------------------------------------------------------------------------

cargo_CR3:
  xor eax,eax
  push __PAGE_TABLES_VMA
  push 0x18;
      ;PWT NO
      ;PCD NO
  call __carga_CR3
  add esp,8
  mov cr3,eax
ret