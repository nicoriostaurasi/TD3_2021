;/**
; * @file task_multiple.asm
; * @author Nicolas Rios Taurasi (nicoriostaurasi@frba.utn.edu.ar)
; * @brief Codigo de tareas en ASM
; * @version 0.1
; * @date 20-06-2021
; * 
; * @copyright Copyright (c) 2021
; * 
; */

section .functions_task01
USE32
GLOBAL task01_print_k
GLOBAL ciclo1
GLOBAL task01_read_k
EXTERN TD3_Read
EXTERN task01_main
ciclo1:
    ;CR3 C000
    ;Llama la tarea 1 
;    xchg bx,bx
    push __DIGITOS_VMA_LIN
    call task01_main
    add esp,4       
    mov ebp,esp
    mov eax,TD3_Halt
    int 0x80
    jmp ciclo1

task01_print_k:
;    xchg bx,bx
    mov ebx,[esp+4*1]   ;x
    mov ecx,[esp+4*2]   ;y
    mov edx,[esp+4*3]   ;caracter
    mov eax,TD3_Print
    int 0x80
    ret
task01_read_k:
    mov ebx,[esp+4*1]   ;direccion
    mov ecx,[esp+4*2]   ;bytes
    mov eax,TD3_Read
    int 0x80
    ret



section .functions_task02
GLOBAL task02_print_k
GLOBAL task02_read_k
GLOBAL ciclo2
EXTERN task02_main
ciclo2: 
    ;CR3 D000
    ;Llama la tarea 2 
    push __DIGITOS_VMA_LIN
    call task02_main
    add esp,4        
    mov ebp,esp

    mov eax,TD3_Halt
    int 0x80

    jmp ciclo2;


task02_print_k:
;    xchg bx,bx
    mov ebx,[esp+4*1]   ;x
    mov ecx,[esp+4*2]   ;y
    mov edx,[esp+4*3]   ;caracter
    mov eax,TD3_Print
    int 0x80
    ret
task02_read_k:
    mov ebx,[esp+4*1]   ;direccion
    mov ecx,[esp+4*2]   ;bytes
    mov eax,TD3_Read
    int 0x80
    ret

section .functions_task03
GLOBAL ciclo3
GLOBAL task03_print_k
GLOBAL task03_read_k
EXTERN task03_main
EXTERN __DIGITOS_VMA_LIN
ciclo3:
    ;CR3 E000
    ;Llama la tarea 3
    push __DIGITOS_VMA_LIN
    call task03_main
    add esp,4        
    mov ebp,esp

    mov eax,TD3_Halt
    int 0x80

    jmp ciclo3

task03_print_k:
    mov ebx,[esp+4*1]   ;x
    mov ecx,[esp+4*2]   ;y
    mov edx,[esp+4*3]   ;caracter
    mov eax,TD3_Print
    int 0x80
    ret
task03_read_k:
    mov ebx,[esp+4*1]   ;direccion
    mov ecx,[esp+4*2]   ;bytes
    mov eax,TD3_Read
    int 0x80
    ret

section .functions_task04
EXTERN TD3_Halt
EXTERN TD3_Print
GLOBAL ciclo4
EXTERN my_task_04
ciclo4:
    ;CR3 F000
    ;Llama la tarea 4
    call my_task_04
    jmp ciclo4