USE32
section .start32

EXTERN  DS_SEL
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

GLOBAL start32_launcher


GLOBAL start32_launcher

start32_launcher:
    xchg bx,bx
    ;inicializa los selectores de datos
    mov ax, DS_SEL
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
    mov esp, __STACK_END_32

    xchg bx,bx
    ;desempaqueto la rom
    push ebp
    mov ebp,esp
    ;enter
    push __functions_size
    push __FUNCTIONS_VMA
    push __FUNCTIONS_LMA
    call __fast_memcpy_rom
    xchg bx,bx
    leave
    cmp eax,1
    jne .guard
    xchg bx,bx
    ;desempaqueto la rom
    push ebp
    mov ebp,esp
    push __codigo_kernel32_size
    push __KERNEL_32_VMA
    push __KERNEL_32_LMA
    call __fast_memcpy_rom
    leave
    cmp eax,1
    jne .guard

    xchg bx,bx
    jmp CS_SEL_32:kernel32_init

    .guard:
        hlt
        jmp .guard