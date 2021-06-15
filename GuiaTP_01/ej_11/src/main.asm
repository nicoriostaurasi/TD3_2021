;/**
; * @file main.asm
; * @author Nicolas Rios Taurasi (nicoriostaurasi@frba.utn.edu.ar)
; * @brief Flujo principal
; * @version 1.1
; * @date 01-06-2021
; * 
; * @copyright Copyright (c) 2021
; * 
; */

EXTERN CS_SEL_32
EXTERN __TECLADO_ISR_VMA

GLOBAL data_teclado
GLOBAL cr2_ram_main
GLOBAL direccion_carga_local_main

GLOBAL kernel32_code_size
GLOBAL kernel32_init
EXTERN pool_teclado
EXTERN __completa_ring_buffer
EXTERN __DATOS_VMA_LIN
EXTERN __DIGITOS_VMA_LIN  
EXTERN __ring_buffer_init
EXTERN __ring_buffer_clear
EXTERN tabla_digitos_init
EXTERN __VIDEO_VGA_LIN
EXTERN __screen_buffer_init
EXTERN task01_main
EXTERN task02_main
EXTERN task03_main
EXTERN __tiempo_iniciar
EXTERN __DATOS_TIMER_VMA_LIN
EXTERN __DATOS_SCH_VMA_LIN
EXTERN __MEMORIA_FISICA_DINAMICA
EXTERN __Scheduler_init
EXTERN __DATOS_SCH_VMA_LIN
EXTERN __TSS_TASK_01_LIN
EXTERN __TSS_TASK_02_LIN
EXTERN __TSS_TASK_03_LIN
EXTERN __TSS_TASK_04_LIN
EXTERN __TASK_01_STACK_END_LIN
EXTERN __TASK_02_STACK_END_LIN
EXTERN __TASK_03_STACK_END_LIN
EXTERN __TASK_04_STACK_END_LIN
EXTERN CS_SEL_32
EXTERN DS_SEL_32
EXTERN __STACK_END_32
EXTERN __PAGE_TABLES_VMA_TASK01_LIN
EXTERN __PAGE_TABLES_VMA_TASK02_LIN
EXTERN __PAGE_TABLES_VMA_TASK03_LIN
EXTERN __PAGE_TABLES_VMA_TASK04_LIN
EXTERN my_task_04

section .kernel32
USE32

%include "inc/utils.h"
%include "inc/processor-flags.h"

kernel32_init:

    ;reinicio los GPR
    xor eax,eax
    xor ebx,ebx
    xor ecx,ecx
    xor edx,edx
 
    ;Inicio la direccion de carga dinamica como lo pide el enunciado
    mov dword [direccion_carga_local_main],__MEMORIA_FISICA_DINAMICA
        
    ;Inicializo el ring buffer
    push __DATOS_VMA_LIN
    call __ring_buffer_init
    add esp,4

    ;Limpio el ring buffer
    push __DATOS_VMA_LIN
    call __ring_buffer_clear        
    add esp,4

    ;Inicio los digitos
    push __DIGITOS_VMA_LIN
    call tabla_digitos_init        
    add esp,4

    ;Inicio la pantalla
    push __VIDEO_VGA_LIN
    call __screen_buffer_init         
    add esp,4

    ;Inicio la estructura de tiempo
    push __DATOS_TIMER_VMA_LIN ;ocupa desde 0x210050 - 0x210056
    call __tiempo_iniciar
    add esp,4
    
    ;Inicio la estructura de Scheduler
    push __DATOS_SCH_VMA_LIN  
    call __Scheduler_init
    add esp,4
    
    ;Inicio las TSS
    call __TSS_INIT

    mov byte[TareaActual],1


;    push __DATOS_SCH_VMA_LIN
;    push __DIGITOS_VMA_LIN
;    call task01_main
;    add esp,8        
    
    mov ebp,esp
    mov esp,__TASK_01_STACK_END_LIN
    mov ebp,esp

    sti
    jmp ciclo1

    idle_kernel:
    jmp idle_kernel
    


;------------------------------------------------------------------------------------------------------------
;		__TSS_INIT
;
;	Funcion: Carga las TSS de todas las tareas.
;
;				
;------------------------------------------------------------------------------------------------------------
__TSS_INIT:
    mov dword[__TSS_TASK_01_LIN + 1*04],__STACK_END_32               ;ESP0
    mov word [__TSS_TASK_01_LIN + 2*04],DS_SEL_32                    ;SS0
    mov eax,__PAGE_TABLES_VMA_TASK01_LIN     
    mov [__TSS_TASK_01_LIN + 7*04],eax                               ;CR3
    mov eax,ciclo1   
    mov [__TSS_TASK_01_LIN + 8*04],eax                               ;EIP
    mov dword[__TSS_TASK_01_LIN + 14*04],__TASK_01_STACK_END_LIN     ;ESP
    mov word [__TSS_TASK_01_LIN + 18*04],DS_SEL_32                   ;ES
    mov word [__TSS_TASK_01_LIN + 19*04],CS_SEL_32                   ;CS
    mov word [__TSS_TASK_01_LIN + 20*04],DS_SEL_32                   ;SS
    mov word [__TSS_TASK_01_LIN + 21*04],DS_SEL_32                   ;DS
    mov word [__TSS_TASK_01_LIN + 22*04],DS_SEL_32                   ;FS
    mov word [__TSS_TASK_01_LIN + 23*04],DS_SEL_32                   ;GS

    mov dword[__TSS_TASK_02_LIN + 1*04],__STACK_END_32               ;ESP0    
    mov word [__TSS_TASK_02_LIN + 2*04],DS_SEL_32                    ;SS0
    mov eax,__PAGE_TABLES_VMA_TASK02_LIN     
    mov [__TSS_TASK_02_LIN + 7*04],eax                               ;CR3
    mov eax,ciclo2   
    mov [__TSS_TASK_02_LIN + 8*04],eax                               ;EIP
    mov dword[__TSS_TASK_02_LIN + 14*04],__TASK_02_STACK_END_LIN     ;ESP
    mov word [__TSS_TASK_02_LIN + 18*04],DS_SEL_32                   ;ES
    mov word [__TSS_TASK_02_LIN + 19*04],CS_SEL_32                   ;CS
    mov word [__TSS_TASK_02_LIN + 20*04],DS_SEL_32                   ;SS
    mov word [__TSS_TASK_02_LIN + 21*04],DS_SEL_32                   ;DS
    mov word [__TSS_TASK_02_LIN + 22*04],DS_SEL_32                   ;FS
    mov word [__TSS_TASK_02_LIN + 23*04],DS_SEL_32                   ;GS    

    mov dword[__TSS_TASK_03_LIN + 1*04],__STACK_END_32               ;ESP0    
    mov word [__TSS_TASK_03_LIN + 2*04],DS_SEL_32                    ;SS0
    mov eax,__PAGE_TABLES_VMA_TASK01_LIN     
    mov [__TSS_TASK_03_LIN + 7*04],eax                               ;CR3
    mov eax,ciclo3   
    mov [__TSS_TASK_03_LIN + 8*04],eax                               ;EIP
    mov dword[__TSS_TASK_03_LIN + 14*04],__TASK_03_STACK_END_LIN     ;ESP
    mov word [__TSS_TASK_03_LIN + 18*04],DS_SEL_32                   ;ES
    mov word [__TSS_TASK_03_LIN + 19*04],CS_SEL_32                   ;CS
    mov word [__TSS_TASK_03_LIN + 20*04],DS_SEL_32                   ;SS
    mov word [__TSS_TASK_03_LIN + 21*04],DS_SEL_32                   ;DS
    mov word [__TSS_TASK_03_LIN + 22*04],DS_SEL_32                   ;FS
    mov word [__TSS_TASK_03_LIN + 23*04],DS_SEL_32                   ;GS    

    mov dword[__TSS_TASK_04_LIN + 1*04],__STACK_END_32               ;ESP0
    mov word [__TSS_TASK_04_LIN + 2*04],DS_SEL_32                    ;SS0
    mov eax,__PAGE_TABLES_VMA_TASK04_LIN
    mov [__TSS_TASK_04_LIN + 7*04],eax                               ;CR3
    mov eax,ciclo4
    mov [__TSS_TASK_04_LIN + 8*04],eax                               ;EIP
    mov dword[__TSS_TASK_04_LIN + 14*04],__TASK_04_STACK_END_LIN     ;ESP
    mov word [__TSS_TASK_04_LIN + 18*04],DS_SEL_32                   ;ES
    mov word [__TSS_TASK_04_LIN + 19*04],CS_SEL_32                   ;CS
    mov word [__TSS_TASK_04_LIN + 20*04],DS_SEL_32                   ;SS
    mov word [__TSS_TASK_04_LIN + 21*04],DS_SEL_32                   ;DS
    mov word [__TSS_TASK_04_LIN + 22*04],DS_SEL_32                   ;FS
    mov word [__TSS_TASK_04_LIN + 23*04],DS_SEL_32                   ;GS
ret


section .data
USE32
reserva_buffer:
times 36 db 0x00

times 12 db 0x00

data_teclado: ; lo cargo en 0x00200030
db 0xFF

reserva_out:
times 15 db 0x00
times 16 db 0x00

reserva_ram_timer:
times 16 db 0x00

reserva_ram_promedio:
times 16 db 0x00

reserva_ram_sch:
times 32 db 0x00

reserva_ram_conv:
times 16 db 0x00
times 16 db 0x00
times 16 db 0x00

times 64 db 0x00

direccion_carga_local_main:
dd 0x0A000000
;times 16 db 0x00
align 32
cr2_ram_main:
dd 0x00000000
align 32


GLOBAL ContadorTarea2,ContadorTarea1,ContadorTarea3,TareaActual,TareaProxima
ContadorTarea1:
db 0x00
align 32
ContadorTarea2:
db 0x00
align 32
ContadorTarea3:
db 0x00
align 32
TareaActual:
db 0x00
align 32
TareaProxima:
db 0x00
align 32

section .functions_task01
ciclo1:
    ;CR3 C000
    ;Llama la tarea 1 
    push __DIGITOS_VMA_LIN
    call task01_main
    add esp,4       
    mov ebp,esp
    hlt
    jmp ciclo1

section .functions_task02
ciclo2:
    ;CR3 D000
    ;Llama la tarea 2 
    push __DIGITOS_VMA_LIN
    call task02_main
    add esp,4        
    mov ebp,esp
    jmp ciclo2;

section .functions_task03
ciclo3:
    ;CR3 E000
    ;Llama la tarea 3
    push __DIGITOS_VMA_LIN
    call task03_main
    add esp,4        
    mov ebp,esp
    jmp ciclo3

section .functions_task04
ciclo4:
    ;CR3 F000
    call my_task_04
    jmp ciclo4