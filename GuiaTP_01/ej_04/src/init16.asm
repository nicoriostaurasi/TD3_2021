
USE16

section .ROM_init
%include "inc/processor-flags.h" 

GLOBAL start16

EXTERN _gdtr
EXTERN CS_SEL_32
EXTERN start32_launcher
EXTERN __STACK_START_16
EXTERN __STACK_END_16


start16:
    test eax,0x0    ;verificar que el uP no este en falla
    jne fault_end

    ;Habilitar A20 Gate
    jmp A20_Enable_No_Stack
A20_Enable_No_Stack_return:

    ;xchg bx,bx

    xor eax,eax
    mov cr3,eax         ;invalidar la TLB

    ;setear stack de 16 bits
    mov ax,cs
    mov ds,ax
    mov ax,__STACK_START_16
    mov ss,ax
    mov sp,__STACK_END_16

    ;deshabilitar cache
    mov eax,cr0
    or eax, (X86_CR0_NW | X86_CR0_CD)
    mov cr0,eax
    wbinvd

    ;xchg bx,bx
    lgdt [_gdtr]

    ;establece el up en MP
    smsw ax
    or   ax, X86_CR0_PE
    lmsw ax
    ;xchg bx,bx
    jmp dword CS_SEL_32:start32_launcher

    fault_end:
        hlt

%define PORT_A_8042    0x60
%define CTRL_PORT_8042 0x64
%define KEYB_DIS       0xAD
%define KEYB_EN        0xAE
%define READ_OUT_8042  0xD0
%define WRITE_OUT_8042 0xD1

A20_Enable_No_Stack:

    xor ax,ax
    ;deshabilito teclado
    mov di, .8042_kbrd_dis
    jmp .empty_8042_in
    .8042_kbrd_dis:
    mov al,KEYB_DIS
    out CTRL_PORT_8042,al

    ;lee la salida
    mov di, .8042_read_out
    jmp .empty_8042_in
    .8042_read_out:
    mov al, READ_OUT_8042
    out CTRL_PORT_8042,al

    .empty_8042_out:
;       in al, CTRL_PORT_8042
;       test al, 00000001b
;       jne .empty_8042_out

    xor bx,bx
    in al, PORT_A_8042
    mov bx,ax

    ;modifica el valor del A20
    mov di, .8042_write_out
    jmp .empty_8042_in
    .8042_write_out:
    mov al, WRITE_OUT_8042
    out CTRL_PORT_8042, al

    mov di, .8042_set_a20
    jmp .empty_8042_in
    .8042_set_a20:
    mov ax,bx
    or ax,00000010b
    out PORT_A_8042,al

    ;Habilita el teclado
    mov di, .8042_kbrd_en
    jmp .empty_8042_in
    .8042_kbrd_en:
    mov al, KEYB_EN
    out CTRL_PORT_8042,al

    mov di, .a20_enable_no_stack_exit
    .empty_8042_in:
;       in al,CTRL_PORT_8042
;       test al, 00000010b
;       jne .empty_8042_in
       jmp di
    
    .a20_enable_no_stack_exit:

jmp A20_Enable_No_Stack_return

endcode:
