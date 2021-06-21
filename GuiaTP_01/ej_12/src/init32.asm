;/**
; * @file init32.asm
; * @author Nicolas Rios Taurasi (nicoriostaurasi@frba.utn.edu.ar)
; * @brief Rutina de Inicializacion en 32 bits
; * @version 1.1
; * @date 01-06-2021
; * 
; * @copyright Copyright (c) 2021
; * 
; */


USE32
section .start32

%define CANT_GDTS 4
;recordar que hay un cant_GDTS en el include.h de C
%define CANT_INTERRUPCIONES 47

%include "inc/processor-flags.h"

EXTERN  CS_SEL_32_1
EXTERN  DS_SEL_16

EXTERN  __STACK_END_32
EXTERN  __STACK_SIZE_32

EXTERN  kernel32_init

EXTERN  __codigo_kernel32_size
EXTERN  __fast_memcpy
EXTERN  __fast_memcpy_rom
EXTERN cargo_CR3

EXTERN __TASK_01_TEXT_LMA
EXTERN __TASK_01_BSS_LMA    
EXTERN __TASK_01_DATA_LMA   
EXTERN __TASK_01_RODATA_LMA 

EXTERN __TASK_01_TEXT_VMA_PHI
EXTERN __TASK_01_BSS_VMA_PHI
EXTERN __TASK_01_DATA_VMA_PHI
EXTERN __TASK_01_RODATA_VMA_PHI

EXTERN __codigo_task_01
EXTERN __bss_task_01
EXTERN __data_task_01
EXTERN __rodata_task_01

EXTERN __TASK_01_LMA
EXTERN __TASK_01_VMA

EXTERN __TASK_02_TEXT_LMA
EXTERN __TASK_02_BSS_LMA    
EXTERN __TASK_02_DATA_LMA   
EXTERN __TASK_02_RODATA_LMA 

EXTERN __TASK_02_TEXT_VMA_PHI
EXTERN __TASK_02_BSS_VMA_PHI
EXTERN __TASK_02_DATA_VMA_PHI
EXTERN __TASK_02_RODATA_VMA_PHI

EXTERN __codigo_task_02
EXTERN __bss_task_02
EXTERN __data_task_02
EXTERN __rodata_task_02

EXTERN __codigo_task_03
EXTERN __bss_task_03
EXTERN __data_task_03
EXTERN __rodata_task_03

EXTERN __TASK_03_TEXT_VMA_PHI
EXTERN __TASK_03_BSS_VMA_PHI
EXTERN __TASK_03_DATA_VMA_PHI
EXTERN __TASK_03_RODATA_VMA_PHI

EXTERN __TASK_03_TEXT_LMA
EXTERN __TASK_03_BSS_LMA    
EXTERN __TASK_03_DATA_LMA   
EXTERN __TASK_03_RODATA_LMA 

EXTERN __TASK_04_TEXT_LMA
EXTERN __TASK_04_BSS_LMA    
EXTERN __TASK_04_DATA_LMA   
EXTERN __TASK_04_RODATA_LMA 

EXTERN __TASK_04_TEXT_VMA_PHI
EXTERN __TASK_04_BSS_VMA_PHI
EXTERN __TASK_04_DATA_VMA_PHI
EXTERN __TASK_04_RODATA_VMA_PHI

EXTERN __codigo_task_04
EXTERN __bss_task_04
EXTERN __data_task_04
EXTERN __rodata_task_04

EXTERN  kernel32_code_size
EXTERN  __KERNEL_32_VMA_PHI
EXTERN  __KERNEL_32_LMA

EXTERN  __functions_size
EXTERN  __FUNCTIONS_VMA_PHI
EXTERN  __FUNCTIONS_LMA

EXTERN  __sys_tables_size
EXTERN  __SYS_TABLES_32_VMA_PHI
EXTERN  __SYS_TABLES_32_LMA

EXTERN  __teclados_isr_size
EXTERN  __TECLADO_ISR_VMA_PHI
EXTERN  __TECLADO_ISR_LMA

EXTERN init_pic
EXTERN init_mask_pic
EXTERN init_PIT
EXTERN cargo_gdt_desde_codigo
EXTERN cargo_idt_desde_codigo
EXTERN cargo_DTP_desde_codigo
EXTERN cargo_TP_desde_codigo
EXTERN paginacion_tarea_1
EXTERN paginacion_tarea_2
EXTERN paginacion_tarea_3
EXTERN paginacion_tarea_4

EXTERN DTP_task01
EXTERN DTP_task02
EXTERN DTP_task03
EXTERN DTP_task04

EXTERN  _gdtr
EXTERN  _idtr

GLOBAL start32_launcher

GLOBAL NULL_SEL
GLOBAL CS_SEL_32
GLOBAL DS_SEL_32


NULL_SEL equ 0x0000
CS_SEL_32 equ 0x0008
DS_SEL_32 equ 0x0010
teclado_IRQ equ 0x02
timer_IRQ equ 0x01

start32_launcher:

    ;inicializa los selectores de datos
    mov ax, DS_SEL_16
    mov ds, ax
    mov es, ax
    mov gs, ax
    mov fs, ax
    
    ;inicializo la pila
    mov ss,ax
    mov esp,__STACK_END_32
    xor eax,eax
    
    ;limpio la pila
    mov ecx,__STACK_SIZE_32   
    .stack_init:
        push eax
        loop .stack_init
    mov esp,__STACK_END_32

    ;desempaqueto la ROM y llevo las funciones a RAM
    push ebp
    mov ebp,esp
    push __functions_size
    push __FUNCTIONS_VMA_PHI
    push __FUNCTIONS_LMA
    call __fast_memcpy_rom
    leave                       
    cmp eax,1
    jne guard

    ;desempaqueto la ROM y llevo el kernel a RAM
    push ebp
    mov ebp,esp
    push __codigo_kernel32_size
    push __KERNEL_32_VMA_PHI
    push __KERNEL_32_LMA
    call __fast_memcpy
    leave
    cmp eax,1
    jne guard
    
    ;desempaqueto la ROM y llevo el Teclado + ISR a RAM
    push ebp
    mov ebp,esp
    push __teclados_isr_size
    push __TECLADO_ISR_VMA_PHI
    push __TECLADO_ISR_LMA
    call __fast_memcpy
    leave
    cmp eax,1
    jne guard
    

    ;desempaqueto la ROM y llevo las secciones de TASK01 a RAM
    push ebp
    mov ebp,esp
    push __codigo_task_01
    push __TASK_01_TEXT_VMA_PHI
    push __TASK_01_TEXT_LMA
    call __fast_memcpy
    leave
    cmp eax,1
    jne guard

    push ebp
    mov ebp,esp
    push __bss_task_01
    push __TASK_01_BSS_VMA_PHI
    push __TASK_01_BSS_LMA
    call __fast_memcpy
    leave
    cmp eax,1
    jne guard

    push ebp
    mov ebp,esp
    push __data_task_01
    push __TASK_01_DATA_VMA_PHI
    push __TASK_01_DATA_LMA
    call __fast_memcpy
    leave
    cmp eax,1
    jne guard

    push ebp
    mov ebp,esp
    push __rodata_task_01
    push __TASK_01_RODATA_VMA_PHI
    push __TASK_01_RODATA_LMA
    call __fast_memcpy
    leave
    cmp eax,1
    jne guard

    ;desempaqueto la ROM y llevo las secciones de TASK02 a RAM
    push ebp
    mov ebp,esp
    push __codigo_task_02
    push __TASK_02_TEXT_VMA_PHI
    push __TASK_02_TEXT_LMA
    call __fast_memcpy
    leave
    cmp eax,1
    jne guard

    push ebp
    mov ebp,esp
    push __bss_task_02
    push __TASK_02_BSS_VMA_PHI
    push __TASK_02_BSS_LMA
    call __fast_memcpy
    leave
    cmp eax,1
    jne guard

    push ebp
    mov ebp,esp
    push __data_task_02
    push __TASK_02_DATA_VMA_PHI
    push __TASK_02_DATA_LMA
    call __fast_memcpy
    leave
    cmp eax,1
    jne guard

    push ebp
    mov ebp,esp
    push __rodata_task_02
    push __TASK_02_RODATA_VMA_PHI
    push __TASK_02_RODATA_LMA
    call __fast_memcpy
    leave
    cmp eax,1
    jne guard
    ;desempaqueto la ROM y llevo las secciones de TASK03 a RAM
    push ebp
    mov ebp,esp
    push __codigo_task_03
    push __TASK_03_TEXT_VMA_PHI
    push __TASK_03_TEXT_LMA
    call __fast_memcpy
    leave
    cmp eax,1
    jne guard

    push ebp
    mov ebp,esp
    push __bss_task_03
    push __TASK_03_BSS_VMA_PHI
    push __TASK_03_BSS_LMA
    call __fast_memcpy
    leave
    cmp eax,1
    jne guard

    push ebp
    mov ebp,esp
    push __data_task_03
    push __TASK_03_DATA_VMA_PHI
    push __TASK_03_DATA_LMA
    call __fast_memcpy
    leave
    cmp eax,1
    jne guard

    push ebp
    mov ebp,esp
    push __rodata_task_03
    push __TASK_03_RODATA_VMA_PHI
    push __TASK_03_RODATA_LMA
    call __fast_memcpy
    leave
    cmp eax,1
    jne guard

    ;desempaqueto la ROM y llevo las secciones de TASK04 a RAM
    push ebp
    mov ebp,esp
    push __codigo_task_04
    push __TASK_04_TEXT_VMA_PHI
    push __TASK_04_TEXT_LMA
    call __fast_memcpy
    leave
    cmp eax,1
    jne guard

    push ebp
    mov ebp,esp
    push __bss_task_04
    push __TASK_04_BSS_VMA_PHI
    push __TASK_04_BSS_LMA
    call __fast_memcpy
    leave
    cmp eax,1
    jne guard

    push ebp
    mov ebp,esp
    push __data_task_04
    push __TASK_04_DATA_VMA_PHI
    push __TASK_04_DATA_LMA
    call __fast_memcpy
    leave
    cmp eax,1
    jne guard

    push ebp
    mov ebp,esp
    push __rodata_task_04
    push __TASK_04_RODATA_VMA_PHI
    push __TASK_04_RODATA_LMA
    call __fast_memcpy
    leave
    cmp eax,1
    jne guard
   
    ;cargo las nuevas gdt y ldt
    call cargo_gdt_desde_codigo ;de modificar esta funcion no olvidarse de los defines
    call cargo_idt_desde_codigo ;de modificar esta funcion no olvidarse de los defines   
    lgdt [_lgdt_v2]
    lidt [_igdt_v2]

    ;Llamo a reprogramar los pics
    call init_pic
    call init_mask_pic
    
    ;Habilito IRQ1
    in al,0x21
    xor al,teclado_IRQ
    out 0x21,al

    call init_PIT

    ;Habilito IRQ0
    in al,0x21
    xor al,timer_IRQ
    out 0x21,al


    ;rutina de paginacion
    call cargo_DTP_desde_codigo
    call cargo_TP_desde_codigo
    call paginacion_tarea_1
    call paginacion_tarea_2
    call paginacion_tarea_3
    call paginacion_tarea_4
    
    call DTP_task01
    call DTP_task02
    call DTP_task03
    call DTP_task04
    
    call cargo_CR3    

    ;Habilito la paginacion
    mov eax, cr0
    or  eax, X86_CR0_PG
    mov cr0, eax

    ;call pruebas_paginacion

    ;Habilito soporte de NM
    mov eax, cr4
    or  eax, X86_CR4_NM
    mov cr4, eax
    jmp CS_SEL_32:kernel32_init; me fui al kernel

    ;seccion de fallo
    guard:
        hlt
        jmp guard

    ;registros de GDT/IDT nuevos
    _lgdt_v2:
    dw (CANT_GDTS*8-1)
    dd __SYS_TABLES_32_VMA_PHI

    _igdt_v2:
    dw (CANT_INTERRUPCIONES*8-1)
    dd (__SYS_TABLES_32_VMA_PHI+(CANT_GDTS*8))

;    pruebas_paginacion:
;
;    xchg bx,bx
;
;    ;Cargo T1    
;    mov eax, cr0
;    xor  eax, X86_CR0_PG
;    mov cr0, eax
;
;    call apago_contexto_tarea02
;    call apago_contexto_tarea03
;    call apago_contexto_tarea04
;    call prendo_contexto_tarea01
;    call cargo_cr3_task01
;    
;    mov eax, cr0
;    xor  eax, X86_CR0_PG
;    mov cr0, eax
;    
;    xchg bx,bx
;
;    ;Cargo T2    
;    mov eax, cr0
;    xor  eax, X86_CR0_PG
;    mov cr0, eax
;
;    call apago_contexto_tarea01
;    call apago_contexto_tarea03
;    call apago_contexto_tarea04
;    call prendo_contexto_tarea02
;    call cargo_cr3_task02
;    
;    mov eax, cr0
;    xor  eax, X86_CR0_PG
;    mov cr0, eax
;    
;    xchg bx,bx
;
;    ;Cargo T3    
;    mov eax, cr0
;    xor  eax, X86_CR0_PG
;    mov cr0, eax
;
;    call apago_contexto_tarea02
;    call apago_contexto_tarea03
;    call apago_contexto_tarea04
;    call prendo_contexto_tarea03
;    call cargo_cr3_task03
;    
;    mov eax, cr0
;    xor  eax, X86_CR0_PG
;    mov cr0, eax
;    
;    xchg bx,bx
;
;    ;Cargo T4    
;    mov eax, cr0
;    xor  eax, X86_CR0_PG
;    mov cr0, eax
;
;    call apago_contexto_tarea01
;    call apago_contexto_tarea02
;    call apago_contexto_tarea03
;    call prendo_contexto_tarea04
;    call cargo_cr3_task04
;    
;    mov eax, cr0
;    xor  eax, X86_CR0_PG
;    mov cr0, eax
;    
;    xchg bx,bx
;
;    mov eax, cr0
;    xor  eax, X86_CR0_PG
;    mov cr0, eax
;
;    call prendo_contexto_tarea01
;    call prendo_contexto_tarea02
;    call prendo_contexto_tarea03
;    call prendo_contexto_tarea04
;    call cargo_CR3
;    
;    mov eax, cr0
;    xor  eax, X86_CR0_PG
;    mov cr0, eax
;    
;    xchg bx,bx
;
;    ret