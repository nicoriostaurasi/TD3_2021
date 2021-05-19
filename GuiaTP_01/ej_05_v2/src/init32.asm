USE32
section .start32

EXTERN  DS_SEL_16
EXTERN  __STACK_END_32
EXTERN  __STACK_SIZE_32
EXTERN  CS_SEL_32
EXTERN  kernel32_init
EXTERN  __KERNEL_32_LMA
EXTERN  __codigo_kernel32_size
EXTERN  __fast_memcpy
EXTERN  __fast_memcpy_rom
EXTERN  kernel32_code_size
EXTERN  __functions_size
EXTERN  __FUNCTIONS_LMA
EXTERN  __KERNEL_32_VMA
EXTERN  __FUNCTIONS_VMA
EXTERN  __sys_tables_size
EXTERN  __SYS_TABLES_32_VMA
EXTERN  __SYS_TABLES_32_LMA
EXTERN  __teclados_isr_size
EXTERN  __TECLADO_ISR_VMA
EXTERN  __TECLADO_ISR_LMA

EXTERN  _gdtr
EXTERN  _idtr


GLOBAL start32_launcher

start32_launcher:
    ;xchg bx,bx
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
  
    ;desempaqueto la ROM y llevo las SYSTABLES DE 32 a RAM
    ;xchg bx,bx                  ;MB(1)
    push ebp
    mov ebp,esp
    push __sys_tables_size
    push __SYS_TABLES_32_VMA
    push __SYS_TABLES_32_LMA
    call __fast_memcpy_rom
    leave                       
    ;xchg bx,bx                  ;MB(2)
    cmp eax,1
    jne .guard
    
    ;cargo las nuevas systables desde RAM
    lgdt [_gdtr]
    lidt [_idtr]


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
    jne .guard

    ;desempaqueto la ROM y llevo el kernel a RAM
    ;xchg bx,bx                  ;MB(5)
    push ebp
    mov ebp,esp
    push __codigo_kernel32_size
    push __KERNEL_32_VMA
    push __KERNEL_32_LMA
    call __fast_memcpy_rom
    leave
    ;xchg bx,bx                  ;MB(6)
    cmp eax,1
    jne .guard
    
    ;xchg bx,bx                  ;MB(7)
    push ebp
    mov ebp,esp
    push __teclados_isr_size
    push __TECLADO_ISR_VMA
    push __TECLADO_ISR_LMA
    call __fast_memcpy_rom
    leave
    ;xchg bx,bx                  ;MB(8)
    cmp eax,1
    jne .guard
    

    jmp CS_SEL_32:kernel32_init

    .guard:
        hlt
        jmp .guard

    