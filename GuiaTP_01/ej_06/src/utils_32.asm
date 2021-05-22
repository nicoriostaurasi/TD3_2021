SECTION .utils32

GLOBAL init_pic
GLOBAL init_mask_pic
GLOBAL init_PIT
GLOBAL cargo_gdt_desde_codigo
GLOBAL cargo_idt_desde_codigo

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

EXTERN  __carga_GDT
EXTERN  __carga_IDT

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
