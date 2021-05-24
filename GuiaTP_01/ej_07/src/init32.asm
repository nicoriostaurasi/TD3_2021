USE32
section .start32

%define CANT_GDTS 3
;recordar que hay un cant_GDTS en el include.h de C
%define CANT_INTERRUPCIONES 47

EXTERN  CS_SEL_32_1
EXTERN  DS_SEL_16

EXTERN  __STACK_END_32
EXTERN  __STACK_SIZE_32

EXTERN  kernel32_init

EXTERN  __codigo_kernel32_size
EXTERN  __fast_memcpy
EXTERN  __fast_memcpy_rom

EXTERN  kernel32_code_size
EXTERN  __KERNEL_32_VMA
EXTERN  __KERNEL_32_LMA

EXTERN  __functions_size
EXTERN  __FUNCTIONS_VMA
EXTERN  __FUNCTIONS_LMA

EXTERN  __sys_tables_size
EXTERN  __SYS_TABLES_32_VMA
EXTERN  __SYS_TABLES_32_LMA

EXTERN  __teclados_isr_size
EXTERN  __TECLADO_ISR_VMA
EXTERN  __TECLADO_ISR_LMA

EXTERN __codigo_task_01
EXTERN __TASK_01_LMA
EXTERN __TASK_01_VMA


EXTERN init_pic
EXTERN init_mask_pic
EXTERN init_PIT
EXTERN cargo_gdt_desde_codigo
EXTERN cargo_idt_desde_codigo

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
    ;xchg bx,bx
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
    ;xchg bx,bx                  ;MB(3)
    push ebp
    mov ebp,esp
    push __functions_size
    push __FUNCTIONS_VMA
    push __FUNCTIONS_LMA
    call __fast_memcpy_rom
    leave                       
    ;xchg bx,bx                  ;MB(4)
    cmp eax,1
    jne guard

    ;desempaqueto la ROM y llevo el kernel a RAM
    ;xchg bx,bx                  ;MB(5)
    push ebp
    mov ebp,esp
    push __codigo_kernel32_size
    push __KERNEL_32_VMA
    push __KERNEL_32_LMA
    call __fast_memcpy
    leave
    ;xchg bx,bx                  ;MB(6)
    cmp eax,1
    jne guard
    
    ;desempaqueto la ROM y llevo el Teclado + ISR a RAM
    ;xchg bx,bx                  ;MB(7)
    push ebp
    mov ebp,esp
    push __teclados_isr_size
    push __TECLADO_ISR_VMA
    push __TECLADO_ISR_LMA
    call __fast_memcpy
    leave
    ;xchg bx,bx                  ;MB(8)
    cmp eax,1
    jne guard
    
    ;desempaqueto la ROM y llevo Task 01
    ;xchg bx,bx                  
    push ebp
    mov ebp,esp
    push __codigo_task_01
    push __TASK_01_VMA
    push __TASK_01_LMA
    call __fast_memcpy
    leave
    ;xchg bx,bx                  
    cmp eax,1
    jne guard
    
    ;cargo las nuevas gdt y ldt
    ;xchg bx,bx
    call cargo_gdt_desde_codigo ;de modificar esta funcion no olvidarse de los defines
    ;xchg bx,bx
    call cargo_idt_desde_codigo ;de modificar esta funcion no olvidarse de los defines   
    ;xchg bx,bx
    lgdt [_lgdt_v2]
    lidt [_igdt_v2]
    ;xchg bx,bx

    ;Llamo a reprogramar los pics
    ;xchg bx,bx
    call init_pic
    call init_mask_pic
    
    HabilitoIRQ1:
    ;xchg bx,bx
    in al,0x21
    xor al,teclado_IRQ
    out 0x21,al

    call init_PIT

    HabilitoIRQ0:
    in al,0x21
    xor al,timer_IRQ
    out 0x21,al

    sti     ;habilito las interrupciones
    
    jmp CS_SEL_32:kernel32_init; me fui al kernel

    guard:
        hlt
        jmp guard

    ;registros de GDT/IDT nuevos

    _lgdt_v2:
    dw (CANT_GDTS*8-1)
    dd __SYS_TABLES_32_VMA

    _igdt_v2:
    dw (CANT_INTERRUPCIONES*8-1)
    dd (__SYS_TABLES_32_VMA+(CANT_GDTS*8))

