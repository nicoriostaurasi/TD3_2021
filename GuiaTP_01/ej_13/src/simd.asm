;/**
; * @file simd.asm
; * @author Nicolas Rios Taurasi (nicoriostaurasi@frba.utn.edu.ar)
; * @brief Funciones de SIMD para tareas
; * @version 0.1
; * @date 16-06-2021
; * 
; * @copyright Copyright (c) 2021
; * 
; */

 USE32
 
section .functions_task02

GLOBAL suma_aritmetica_saturada
;Mismo define en functions.h
%define CANT_DIGITOS 50         

;realiza la suma aritmetica saturada en words
;paddusw
suma_aritmetica_saturada:
xor ecx,ecx
mov eax,[esp+4]
mov ebx,50
add eax,16
pxor mm0,mm0

ciclo:
    paddusw mm0, qword[eax]
    add eax,8
    inc ecx
    cmp ecx,ebx
jne ciclo

;copio en edx:eax el contenido del registro mm0
movd eax,mm0
psrlq mm0,32
movd edx,mm0

pxor mm0,mm0
ret

section .functions_task03
;realiza la suma aritmetica en qwords words
;paddq
GLOBAL suma_quad_word

suma_quad_word:
xor ecx,ecx
mov eax,[esp+4]
mov ebx,CANT_DIGITOS
add eax,16
pxor mm0,mm0

ciclo2:
    paddq mm0, qword[eax]
    add eax,8
    inc ecx
    cmp ecx,ebx
jne ciclo2

;copio en edx:eax el contenido del registro mm0
movd eax,mm0
psrlq mm0,32
movd ebx,mm0


ret