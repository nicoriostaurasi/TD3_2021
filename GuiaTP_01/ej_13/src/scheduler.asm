;/**
; * @file scheduler.asm
; * @author Nicolas Rios Taurasi (nicoriostaurasi@frba.utn.edu.ar)
; * @brief Funcion de Scheduler para conmutar tareas
; * Puede encontrarse su descripción en doc/Scheduler_TD3.pdf
; * @version 0.1
; * @date 14-06-2021
; * 
; * @copyright Copyright (c) 2021
; * 
; */

USE32
%include "inc/processor-flags.h" 
GLOBAL dummy_utils_scheduler
GLOBAL guardar_contexto_tarea_1
GLOBAL guardar_contexto_tarea_2
GLOBAL guardar_contexto_tarea_4
GLOBAL cargar_contexto_tarea_1
GLOBAL cargar_contexto_tarea_2
GLOBAL cargar_contexto_tarea_4
EXTERN __TSS_TASK_01_LIN
EXTERN __TSS_TASK_02_LIN
EXTERN __TSS_TASK_03_LIN
EXTERN __TSS_TASK_04_LIN
EXTERN __TSS_SISTEMA_LIN

;cambio de contexto
GLOBAL cargo_cr3_task01
GLOBAL cargo_cr3_task02
GLOBAL cargo_cr3_task03
GLOBAL cargo_cr3_task04

GLOBAL prendo_contexto_tarea01
GLOBAL prendo_contexto_tarea02
GLOBAL prendo_contexto_tarea03
GLOBAL prendo_contexto_tarea04

GLOBAL apago_contexto_tarea01
GLOBAL apago_contexto_tarea02
GLOBAL apago_contexto_tarea03
GLOBAL apago_contexto_tarea04
;cambio de contexto

GLOBAL scheduler_ASM
EXTERN return_scheduler_ASM
EXTERN ContadorTarea1
EXTERN ContadorTarea2
EXTERN ContadorTarea3
EXTERN TareaActual,TareaProxima

%define Tarea_1 1
%define Tarea_2 2
%define Tarea_4 4
%define Tarea_3 3
%define TC_T1 49
%define TC_T2 19
%define TC_T3 9

scheduler_ASM:
    cmp byte [TareaActual],255
    je Recargar_Tarea_4

    inc byte [ContadorTarea1]       
    inc byte [ContadorTarea2]       
    inc byte [ContadorTarea3]

    cmp byte [ContadorTarea3],TC_T3
    jg llegue_a_10

    cmp byte [ContadorTarea2],TC_T2
    jg llegue_a_20

    cmp byte [ContadorTarea1],TC_T1
    jg llegue_a_50

    jmp CargoTarea4

    llegue_a_10:
    mov byte [ContadorTarea3],0x00
    jmp CargoTarea3

    llegue_a_20:
    mov byte [ContadorTarea2],0x00
    jmp CargoTarea2

    llegue_a_50:
    mov byte [ContadorTarea1],0x00
    jmp CargoTarea1

    llegue_a_tarea_4:
    jmp CargoTarea4

    CargoTarea1:
    mov byte [TareaProxima],Tarea_1
    cmp byte [TareaActual],Tarea_1
    je fin ;misma tarea no hago nada
    cmp byte [TareaActual],Tarea_2
    je Salvar_Tarea_2
    cmp byte [TareaActual],Tarea_3
    je Salvar_Tarea_3
    cmp byte [TareaActual],Tarea_4
    je Salvar_Tarea_4
    jmp fin

    CargoTarea2:
    mov byte [TareaProxima],Tarea_2
    cmp byte [TareaActual],Tarea_2
    je fin ;misma tarea no hago nada
    cmp byte [TareaActual],Tarea_1
    je Salvar_Tarea_1
    cmp byte [TareaActual],Tarea_3
    je Salvar_Tarea_3
    cmp byte [TareaActual],Tarea_4
    je Salvar_Tarea_4
    jmp fin

    CargoTarea3:
    mov byte [TareaProxima],Tarea_3
    cmp byte [TareaActual],Tarea_3
    je fin ;misma tarea no hago nada
    cmp byte [TareaActual],Tarea_1
    je Salvar_Tarea_1
    cmp byte [TareaActual],Tarea_2
    je Salvar_Tarea_2
    cmp byte [TareaActual],Tarea_4
    je Salvar_Tarea_4
    jmp fin

    CargoTarea4:
    mov byte [TareaProxima],Tarea_4
    cmp byte [TareaActual],Tarea_4
    je fin ;misma tarea no hago nada
    cmp byte [TareaActual],Tarea_1
    je Salvar_Tarea_1
    cmp byte [TareaActual],Tarea_2
    je Salvar_Tarea_2
    cmp byte [TareaActual],Tarea_3
    je Salvar_Tarea_3
    jmp fin


    Salvar_Tarea_1:
    call guardar_contexto_tarea_1
    jmp proxima_tarea

    Salvar_Tarea_2:
    call guardar_contexto_tarea_2
    jmp proxima_tarea

    Salvar_Tarea_3:
    call guardar_contexto_tarea_3
    jmp proxima_tarea

    Salvar_Tarea_4:
    call guardar_contexto_tarea_4
    jmp proxima_tarea

    proxima_tarea:
    cmp byte[TareaProxima],Tarea_1
    je Recargar_Tarea_1
    cmp byte[TareaProxima],Tarea_2
    je Recargar_Tarea_2
    cmp byte[TareaProxima],Tarea_3
    je Recargar_Tarea_3
    cmp byte[TareaProxima],Tarea_4
    je Recargar_Tarea_4


    Recargar_Tarea_1:
    call prender_todos_los_stacks
    mov eax,__PAGE_TABLES_VMA_TASK01_LIN
    mov cr3,eax
    mov esp,[__TSS_TASK_01_LIN+1*04]
    jmp cargar_contexto_tarea_1
    return_cargar_contexto_tarea_1:
    mov byte [TareaActual],Tarea_1
 
    call cargo_cr3_kernel
    call prendo_contexto_tarea01
    call apago_contexto_tarea02
    call apago_contexto_tarea03
    call apago_contexto_tarea04 
    call cargo_cr3_task01
    
    jmp fin

    Recargar_Tarea_2:
    call prender_todos_los_stacks    
    mov eax,__PAGE_TABLES_VMA_TASK02_LIN
    mov cr3,eax
    mov esp,[__TSS_TASK_02_LIN+1*04]
    jmp cargar_contexto_tarea_2
    return_cargar_contexto_tarea_2:
    mov byte [TareaActual],Tarea_2
    call cargo_cr3_kernel
    call prendo_contexto_tarea02
    call apago_contexto_tarea01
    call apago_contexto_tarea03
    call apago_contexto_tarea04
    call cargo_cr3_task02 
    jmp fin

    Recargar_Tarea_3:
    call prender_todos_los_stacks    
    mov eax,__PAGE_TABLES_VMA_TASK03_LIN
    mov cr3,eax
    mov esp,[__TSS_TASK_03_LIN+1*04]
    jmp cargar_contexto_tarea_3
    return_cargar_contexto_tarea_3:
    mov byte [TareaActual],Tarea_3
    call cargo_cr3_kernel
    call prendo_contexto_tarea03
    call apago_contexto_tarea01
    call apago_contexto_tarea02
    call apago_contexto_tarea04
    call cargo_cr3_task03 
    jmp fin

EXTERN __STACK_END_32_T1
EXTERN __STACK_END_32_T2
EXTERN __STACK_END_32_T3
EXTERN __STACK_END_32_T4


    Recargar_Tarea_4:
    call prender_todos_los_stacks
    mov eax,__PAGE_TABLES_VMA_TASK04_LIN
    mov cr3,eax
    mov esp,[__TSS_TASK_04_LIN+1*04]
    jmp cargar_contexto_tarea_4
    return_cargar_contexto_tarea_4:

    mov byte [TareaActual],Tarea_4
    call cargo_cr3_kernel
    call prendo_contexto_tarea04
    call apago_contexto_tarea01
    call apago_contexto_tarea02
    call apago_contexto_tarea03 
    call cargo_cr3_task04

    jmp fin


    fin:

jmp return_scheduler_ASM


guardar_contexto_tarea_1:
  mov [__TSS_TASK_01_LIN+10*04],eax ;EAX
  mov [__TSS_TASK_01_LIN+11*04],ecx ;ECX
  mov [__TSS_TASK_01_LIN+12*04],edx ;EDX
  mov [__TSS_TASK_01_LIN+13*04],ebx ;EBX
  mov [__TSS_TASK_01_LIN+16*04],esi ;ESI
  mov [__TSS_TASK_01_LIN+17*04],edi ;EDI


  ;Registros de Segmento
  mov [__TSS_TASK_01_LIN+18*04],es ;reserved / ES    
  mov [__TSS_TASK_01_LIN+21*04],ds ;reserved / DS   
  mov [__TSS_TASK_01_LIN+22*04],fs ;reserved / FS       
  mov [__TSS_TASK_01_LIN+23*04],gs ;reserved / GS   
  mov [__TSS_TASK_01_LIN+15*04],ebp ;EBP
  mov ebp,esp
  add ebp,4
  mov [__TSS_TASK_01_LIN+1*04],ebp ;ESP
ret
;jmp return_guardar_contexto_tarea_1


guardar_contexto_tarea_2:
  mov [__TSS_TASK_02_LIN+10*04],eax ;EAX
  mov [__TSS_TASK_02_LIN+11*04],ecx ;ECX
  mov [__TSS_TASK_02_LIN+12*04],edx ;EDX
  mov [__TSS_TASK_02_LIN+13*04],ebx ;EBX
  mov [__TSS_TASK_02_LIN+16*04],esi ;ESI
  mov [__TSS_TASK_02_LIN+17*04],edi ;EDI


  ;Registros de Segmento
  mov [__TSS_TASK_02_LIN+18*04],es ;reserved / ES    
  mov [__TSS_TASK_02_LIN+21*04],ds ;reserved / DS   
  mov [__TSS_TASK_02_LIN+22*04],fs ;reserved / FS       
  mov [__TSS_TASK_02_LIN+23*04],gs ;reserved / GS   
  mov [__TSS_TASK_02_LIN+15*04],ebp ;EBP
  mov ebp,esp
  add ebp,4
  mov [__TSS_TASK_02_LIN+1*04],ebp ;ESP
ret
;jmp return_guardar_contexto_tarea_2

guardar_contexto_tarea_3:

  mov [__TSS_TASK_03_LIN+10*04],eax ;EAX
  mov [__TSS_TASK_03_LIN+11*04],ecx ;ECX
  mov [__TSS_TASK_03_LIN+12*04],edx ;EDX
  mov [__TSS_TASK_03_LIN+13*04],ebx ;EBX
  mov [__TSS_TASK_03_LIN+16*04],esi ;ESI
  mov [__TSS_TASK_03_LIN+17*04],edi ;EDI


  ;Registros de Segmento
  mov [__TSS_TASK_03_LIN+18*04],es ;reserved / ES    
  mov [__TSS_TASK_03_LIN+21*04],ds ;reserved / DS   
  mov [__TSS_TASK_03_LIN+22*04],fs ;reserved / FS       
  mov [__TSS_TASK_03_LIN+23*04],gs ;reserved / GS   
  mov [__TSS_TASK_03_LIN+15*04],ebp ;EBP
  mov ebp,esp
  add ebp,4
  mov [__TSS_TASK_03_LIN+1*04],ebp ;ESP
ret


guardar_contexto_tarea_4:
;  xchg bx,bx
  mov [__TSS_TASK_04_LIN+10*04],eax ;EAX
  mov [__TSS_TASK_04_LIN+11*04],ecx ;ECX
  mov [__TSS_TASK_04_LIN+12*04],edx ;EDX
  mov [__TSS_TASK_04_LIN+13*04],ebx ;EBX
  mov [__TSS_TASK_04_LIN+16*04],esi ;ESI
  mov [__TSS_TASK_04_LIN+17*04],edi ;EDI

  ;Registros de Segmento
  mov [__TSS_TASK_04_LIN+18*04],es ;reserved / ES    
;  mov [__TSS_TASK_04_LIN+20*04],ss ;reserved / SS
  mov [__TSS_TASK_04_LIN+21*04],ds ;reserved / DS   
  mov [__TSS_TASK_04_LIN+22*04],fs ;reserved / FS       
  mov [__TSS_TASK_04_LIN+23*04],gs ;reserved / GS   
  mov [__TSS_TASK_04_LIN+15*04],ebp ;EBP
  mov ebp,esp
  add ebp,4
  mov [__TSS_TASK_04_LIN+1*04],ebp ;ESP
ret
;jmp return_guardar_contexto_tarea_4


cargar_contexto_tarea_1:
    mov ebp,[__TSS_TASK_01_LIN+15*04] 

    mov eax, cr0
    xor  eax, X86_CR0_PG
    mov cr0, eax

    call cargo_cr3_task01
    
    mov eax, cr0
    xor  eax, X86_CR0_PG
    mov cr0, eax

    ;Cargo los registros de segmento
    mov es,[__TSS_TASK_01_LIN+18*04] ;reserved / ES
    mov ss,[__TSS_TASK_01_LIN+2*04] ;reserved / SS0
    mov ds,[__TSS_TASK_01_LIN+21*04] ;reserved / DS
    mov fs,[__TSS_TASK_01_LIN+22*04] ;reserved / FS
    mov gs,[__TSS_TASK_01_LIN+23*04] ;reserved / GS

    mov eax, cr0
    or  eax, X86_CR0_TS
    mov cr0, eax

    ;TSS de sistema
    mov dword eax,__STACK_END_32_T1   ;ESP0
    mov dword[__TSS_SISTEMA_LIN+1*04],eax       
    mov dword eax,[__TSS_TASK_01_LIN + 2*04]   ;SS0
    mov dword[__TSS_SISTEMA_LIN+2*04],eax
    mov dword eax,[__TSS_TASK_01_LIN + 7*04]    ;CR3
    mov dword [__TSS_SISTEMA_LIN + 7*04],eax       
    mov dword eax,[__TSS_TASK_01_LIN + 14*04]  ;SS0
    mov dword[__TSS_SISTEMA_LIN+14*04],eax       
    mov word ax,[__TSS_TASK_01_LIN + 19*04]  ;CS
    mov word[__TSS_SISTEMA_LIN+19*04],ax       
    mov dword eax,[__TSS_TASK_01_LIN + 20*04]  ;SS0
    mov dword[__TSS_SISTEMA_LIN+20*04],eax       

    ;Registros de Proposito general
    mov eax,[__TSS_TASK_01_LIN+10*04]    
    mov ebx,[__TSS_TASK_01_LIN+11*04]
    mov ecx,[__TSS_TASK_01_LIN+12*04]
    mov edx,[__TSS_TASK_01_LIN+13*04]
    mov esi,[__TSS_TASK_01_LIN+16*04]
    mov edi,[__TSS_TASK_01_LIN+17*04]

jmp return_cargar_contexto_tarea_1

cargar_contexto_tarea_2:
    mov ebp,[__TSS_TASK_02_LIN+15*04] 

    mov eax, cr0
    xor  eax, X86_CR0_PG
    mov cr0, eax

    call cargo_cr3_task02
    
    mov eax, cr0
    xor  eax, X86_CR0_PG
    mov cr0, eax

    ;Cargo los registros de segmento
    mov es,[__TSS_TASK_02_LIN+18*04] ;reserved / ES
    mov ss,[__TSS_TASK_02_LIN+2*04] ;reserved / SS0
    mov ds,[__TSS_TASK_02_LIN+21*04] ;reserved / DS
    mov fs,[__TSS_TASK_02_LIN+22*04] ;reserved / FS
    mov gs,[__TSS_TASK_02_LIN+23*04] ;reserved / GS

    mov eax, cr0
    or  eax, X86_CR0_TS
    mov cr0, eax

    ;TSS de sistema
    mov dword eax,__STACK_END_32_T2   ;ESP0
    mov dword[__TSS_SISTEMA_LIN+1*04],eax       
    mov dword eax,[__TSS_TASK_02_LIN + 2*04]   ;SS0
    mov dword[__TSS_SISTEMA_LIN+2*04],eax
    mov dword eax,[__TSS_TASK_02_LIN + 7*04]    ;CR3
    mov dword [__TSS_SISTEMA_LIN + 7*04],eax       
    mov dword eax,[__TSS_TASK_02_LIN + 14*04]  ;SS0
    mov dword[__TSS_SISTEMA_LIN+14*04],eax       
    mov word ax,[__TSS_TASK_02_LIN + 19*04]  ;CS
    mov word[__TSS_SISTEMA_LIN+19*04],ax       
    mov dword eax,[__TSS_TASK_02_LIN + 20*04]  ;SS0
    mov dword[__TSS_SISTEMA_LIN+20*04],eax       

    ;Registros de Proposito general
    mov eax,[__TSS_TASK_02_LIN+10*04]    
    mov ebx,[__TSS_TASK_02_LIN+11*04]
    mov ecx,[__TSS_TASK_02_LIN+12*04]
    mov edx,[__TSS_TASK_02_LIN+13*04]
    mov esi,[__TSS_TASK_02_LIN+16*04]
    mov edi,[__TSS_TASK_02_LIN+17*04]

jmp return_cargar_contexto_tarea_2

cargar_contexto_tarea_3:

    mov ebp,[__TSS_TASK_03_LIN+15*04] 

    mov eax, cr0
    xor  eax, X86_CR0_PG
    mov cr0, eax

    call cargo_cr3_task03
    
    mov eax, cr0
    xor  eax, X86_CR0_PG
    mov cr0, eax

    ;Cargo los registros de segmento
    mov es,[__TSS_TASK_03_LIN+18*04] ;reserved / ES
    mov ss,[__TSS_TASK_03_LIN+2*04] ;reserved / SS0
    mov ds,[__TSS_TASK_03_LIN+21*04] ;reserved / DS
    mov fs,[__TSS_TASK_03_LIN+22*04] ;reserved / FS
    mov gs,[__TSS_TASK_03_LIN+23*04] ;reserved / GS

    mov eax, cr0
    or  eax, X86_CR0_TS
    mov cr0, eax

    ;TSS de sistema
    mov dword eax,__STACK_END_32_T3   ;ESP0
    mov dword[__TSS_SISTEMA_LIN+1*04],eax       
    mov dword eax,[__TSS_TASK_03_LIN + 2*04]   ;SS0
    mov dword[__TSS_SISTEMA_LIN+2*04],eax
    mov dword eax,[__TSS_TASK_03_LIN + 7*04]    ;CR3
    mov dword [__TSS_SISTEMA_LIN + 7*04],eax       
    mov dword eax,[__TSS_TASK_03_LIN + 14*04]  ;SS0
    mov dword[__TSS_SISTEMA_LIN+14*04],eax       
    mov word ax,[__TSS_TASK_03_LIN + 19*04]  ;CS
    mov word[__TSS_SISTEMA_LIN+19*04],ax       
    mov dword eax,[__TSS_TASK_03_LIN + 20*04]  ;SS0
    mov dword[__TSS_SISTEMA_LIN+20*04],eax       

    ;Registros de Proposito general
    mov eax,[__TSS_TASK_03_LIN+10*04]    
    mov ebx,[__TSS_TASK_03_LIN+11*04]
    mov ecx,[__TSS_TASK_03_LIN+12*04]
    mov edx,[__TSS_TASK_03_LIN+13*04]
    mov esi,[__TSS_TASK_03_LIN+16*04]
    mov edi,[__TSS_TASK_03_LIN+17*04]

jmp return_cargar_contexto_tarea_3

cargar_contexto_tarea_4:

    mov ebp,[__TSS_TASK_04_LIN+15*04] 

    mov eax, cr0
    xor  eax, X86_CR0_PG
    mov cr0, eax

    call cargo_cr3_task04
    
    mov eax, cr0
    xor  eax, X86_CR0_PG
    mov cr0, eax

    ;Cargo los registros de segmento
    mov es,[__TSS_TASK_04_LIN+18*04] ;reserved / ES
    mov ss,[__TSS_TASK_04_LIN+2*04] ;reserved / SS0
    mov ds,[__TSS_TASK_04_LIN+21*04] ;reserved / DS
    mov fs,[__TSS_TASK_04_LIN+22*04] ;reserved / FS
    mov gs,[__TSS_TASK_04_LIN+23*04] ;reserved / GS


    ;Registros del Stack
;    EXTERN CS_SEL_32_US
 ;   xchg bx,bx
;    mov eax,[__TSS_TASK_04_LIN+8*04]     ;EIP
;    mov [esp+4*0],eax
    
;    mov ax,[__TSS_TASK_04_LIN+9*04]      ;EFLAGS
;    or eax, 0x0202                       ;Enable int
;    mov [esp+4*2],eax
; 
;    mov eax,[__TSS_TASK_04_LIN+19*04]    ;CS
;    cmp eax,CS_SEL_32
;    je k2k_l_t4
;    add eax,3
;    mov [esp+4*1],eax
;    mov eax,[__TSS_TASK_04_LIN+14*04]    ;ESP3
;    mov [esp+4*3],eax
;    mov eax,[__TSS_TASK_04_LIN+20*04]    ;SS3
;    mov [esp+4*4],eax
;    jmp cargado_stack_l_t4
;
;    k2k_l_t4:    
;    mov [esp+4*1],eax
;    xchg bx,bx

    cargado_stack_l_t4:
    mov eax, cr0
    or  eax, X86_CR0_TS
    mov cr0, eax

    ;TSS de sistema
    mov dword eax,__STACK_END_32_T4   ;ESP0
    mov dword[__TSS_SISTEMA_LIN+1*04],eax       
    mov dword eax,[__TSS_TASK_04_LIN + 2*04]   ;SS0
    mov dword[__TSS_SISTEMA_LIN+2*04],eax
    mov dword eax,[__TSS_TASK_04_LIN + 7*04]    ;CR3
    mov dword [__TSS_SISTEMA_LIN + 7*04],eax       
    mov dword eax,[__TSS_TASK_04_LIN + 14*04]  ;SS0
    mov dword[__TSS_SISTEMA_LIN+14*04],eax       
    mov word ax,[__TSS_TASK_04_LIN + 19*04]  ;CS
    mov word[__TSS_SISTEMA_LIN+19*04],ax       
    mov dword eax,[__TSS_TASK_04_LIN + 20*04]  ;SS0
    mov dword[__TSS_SISTEMA_LIN+20*04],eax       


    ;Registros de Proposito general
    mov eax,[__TSS_TASK_04_LIN+10*04]    
    mov ebx,[__TSS_TASK_04_LIN+11*04]
    mov ecx,[__TSS_TASK_04_LIN+12*04]
    mov edx,[__TSS_TASK_04_LIN+13*04]
    mov esi,[__TSS_TASK_04_LIN+16*04]
    mov edi,[__TSS_TASK_04_LIN+17*04]
;    xchg bx,bx
jmp return_cargar_contexto_tarea_4


;Funciones para cambio de contexto
EXTERN ISR14_Handler_PF_Basico
EXTERN ISR14_Handler_PF

EXTERN __carga_IDT
EXTERN __carga_TP
EXTERN __carga_DTP
EXTERN __carga_CR3

EXTERN __PAGE_TABLES_VMA_LIN
EXTERN __PAGE_TABLES_VMA_TASK01_LIN
EXTERN __PAGE_TABLES_VMA_TASK02_LIN
EXTERN __PAGE_TABLES_VMA_TASK03_LIN
EXTERN __PAGE_TABLES_VMA_TASK04_LIN

EXTERN __PT_TASK_01_TEXT
EXTERN __PT_TASK_02_TEXT
EXTERN __PT_TASK_03_TEXT
EXTERN __PT_TASK_04_TEXT

EXTERN __PT_TASK_01_BSS
EXTERN __PT_TASK_02_BSS
EXTERN __PT_TASK_03_BSS
EXTERN __PT_TASK_04_BSS

EXTERN __PT_TASK_01_DATA
EXTERN __PT_TASK_02_DATA
EXTERN __PT_TASK_03_DATA
EXTERN __PT_TASK_04_DATA

EXTERN __PT_TASK_01_RODATA
EXTERN __PT_TASK_02_RODATA
EXTERN __PT_TASK_03_RODATA
EXTERN __PT_TASK_04_RODATA

EXTERN __PT_TASK_01_STACK
EXTERN __PT_TASK_02_STACK
EXTERN __PT_TASK_03_STACK
EXTERN __PT_TASK_04_STACK

EXTERN __PT_STACK_SISTEMA_T1
EXTERN __PT_STACK_SISTEMA_T2
EXTERN __PT_STACK_SISTEMA_T3
EXTERN __PT_STACK_SISTEMA_T4

EXTERN CS_SEL_32

GLOBAL cargo_cr3_kernel
GLOBAL cargo_cr3_task01

cargo_cr3_kernel:
  xor eax,eax
  push __PAGE_TABLES_VMA_LIN
  push 0x18;
      ;PWT SI
      ;PCD SI
  call __carga_CR3
  add esp,8
  mov cr3,eax
ret


cargo_cr3_task01:
  push eax
  push __PAGE_TABLES_VMA_TASK01_LIN
  push 0x18;
      ;PWT SI
      ;PCD SI
  call __carga_CR3
  add esp,8
  mov cr3,eax
  pop eax
ret

cargo_cr3_task02:
  xor eax,eax
  push __PAGE_TABLES_VMA_TASK02_LIN
  push 0x18;
      ;PWT SI
      ;PCD SI
  call __carga_CR3
  add esp,8
  mov cr3,eax
ret

cargo_cr3_task03:
  xor eax,eax
  push __PAGE_TABLES_VMA_TASK03_LIN
  push 0x18;
      ;PWT SI
      ;PCD SI
  call __carga_CR3
  add esp,8
  mov cr3,eax
ret

cargo_cr3_task04:
  xor eax,eax
  push __PAGE_TABLES_VMA_TASK04_LIN
  push 0x18;
      ;PWT SI
      ;PCD SI
  call __carga_CR3
  add esp,8
  mov cr3,eax
ret


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


apago_contexto_tarea01:
  push PAG_P_NO
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

  push PAG_P_NO
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

  push PAG_P_NO
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

  push PAG_P_NO
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

  push PAG_P_NO
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

  push PAG_P_NO
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

apago_contexto_tarea02:
  push PAG_P_NO
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

  push PAG_P_NO
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

  push PAG_P_NO
  push PAG_RW_R
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

  push PAG_P_NO
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

  push PAG_P_NO
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

  push PAG_P_NO
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

apago_contexto_tarea03:
  push PAG_P_NO
  push PAG_RW_R
  push PAG_US_US
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

  push PAG_P_NO
  push PAG_RW_R
  push PAG_US_US
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

  push PAG_P_NO
  push PAG_RW_R
  push PAG_US_US
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

  push PAG_P_NO
  push PAG_RW_R
  push PAG_US_US
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

  push PAG_P_NO
  push PAG_RW_W
  push PAG_US_US
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

  push PAG_P_NO
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

apago_contexto_tarea04:
  push PAG_P_NO
  push PAG_RW_R
  push PAG_US_US
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

  push PAG_P_NO
  push PAG_RW_R
  push PAG_US_US
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

  push PAG_P_NO
  push PAG_RW_R
  push PAG_US_US
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

  push PAG_P_NO
  push PAG_RW_R
  push PAG_US_US
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

  push PAG_P_NO
  push PAG_RW_W
  push PAG_US_US
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

  push PAG_P_NO
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

;pila y codigo
prendo_contexto_tarea01:
  
  push ISR14_Handler_PF ;offset (handler)
  push 0x0000008F ;atributos
  push CS_SEL_32 ;Selector
  push 0x0000000E ;offsetIDT   
  call __carga_IDT
  add esp,16
  
  push PAG_P_YES
  push PAG_RW_W
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

  push PAG_P_YES
  push PAG_RW_W
  push PAG_US_SUP
  push PAG_PWT_NO
  push PAG_PCD_NO
  push PAG_A
  push PAG_D
  push PAG_PAT
  push PAG_G_YES
  push dword(__PT_TASK_01_STACK)
  push 0x38F
  push dword(__PAGE_TABLES_VMA_LIN+0x1000+(0x1000*0x01))
  ;call __carga_TP 
  add esp,48

ret

prendo_contexto_tarea02:

  push ISR14_Handler_PF_Basico ;offset (handler)
  push 0x0000008F ;atributos
  push CS_SEL_32 ;Selector
  push 0x0000000E ;offsetIDT   
  call __carga_IDT
  add esp,16

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
  push PAG_RW_W
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

;  push PAG_P_YES
;  push PAG_RW_W
;  push PAG_US_US
;  push PAG_PWT_NO
;  push PAG_PCD_NO
;  push PAG_A
;  push PAG_D
;  push PAG_PAT
;  push PAG_G_YES
;  push dword(__PT_TASK_02_DATA+0x1000)
;  push 0x031
;  push dword(__PAGE_TABLES_VMA_LIN+0x1000+(0x1000*0x05))
;  call __carga_TP 
;  add esp,48

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
  push PAG_US_SUP
  push PAG_PWT_NO
  push PAG_PCD_NO
  push PAG_A
  push PAG_D
  push PAG_PAT
  push PAG_G_YES
  push dword(__PT_TASK_02_STACK)
  push 0x390
  push dword(__PAGE_TABLES_VMA_LIN+0x1000+(0x1000*0x01))
  ;call __carga_TP 
  add esp,48
ret

prendo_contexto_tarea03:
  
  push ISR14_Handler_PF_Basico ;offset (handler)
  push 0x0000008F ;atributos
  push CS_SEL_32 ;Selector
  push 0x0000000E ;offsetIDT   
  call __carga_IDT
  add esp,16
  
  push PAG_P_YES
  push PAG_RW_R
  push PAG_US_US
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
  push PAG_RW_W
  push PAG_US_US
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
  push PAG_RW_W
  push PAG_US_US
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
  push PAG_US_US
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
  push PAG_US_SUP
  push PAG_PWT_NO
  push PAG_PCD_NO
  push PAG_A
  push PAG_D
  push PAG_PAT
  push PAG_G_YES
  push dword(__PT_TASK_03_STACK)
  push 0x391
  push dword(__PAGE_TABLES_VMA_LIN+0x1000+(0x1000*0x01))
  ;call __carga_TP 
  add esp,48
ret

prendo_contexto_tarea04:
  
  push ISR14_Handler_PF_Basico ;offset (handler)
  push 0x0000008F ;atributos
  push CS_SEL_32 ;Selector
  push 0x0000000E ;offsetIDT   
  call __carga_IDT
  add esp,16
  
  push PAG_P_YES
  push PAG_RW_R
  push PAG_US_US
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
  push PAG_RW_W
  push PAG_US_US
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
  push PAG_RW_W
  push PAG_US_US
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
  push PAG_US_US
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
  push PAG_US_US
  push PAG_PWT_NO
  push PAG_PCD_NO
  push PAG_A
  push PAG_D
  push PAG_PAT
  push PAG_G_YES
  push dword(__PT_TASK_04_STACK)
  push 0x392
  push dword(__PAGE_TABLES_VMA_LIN+0x1000+(0x1000*0x01))
  ;call __carga_TP 
  add esp,48
ret

prender_todos_los_stacks:
  
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
  push PAG_US_US
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
  push PAG_US_US
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
  push dword(__PT_STACK_SISTEMA_T1)
  push 0x3F4
  push dword(__PAGE_TABLES_VMA_LIN+0x1000+(0x1000*0x7F))
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