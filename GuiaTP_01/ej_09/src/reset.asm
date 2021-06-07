;/**
; * @file reset.asm
; * @author Nicolas Rios Taurasi (nicoriostaurasi@frba.utn.edu.ar)
; * @brief Reset vector
; * @version 1.1
; * @date 01-06-2021
; * 
; * @copyright Copyright (c) 2021
; * 
; */
USE16                  ;decodifica el codigo para instrucciones de 16 bits

EXTERN start16
GLOBAL reset

section .resetVector

reset:
    cli                  ;clear interrupts
    cld                  ;clear directions para la copia de memoria
    jmp start16
    halted:
        hlt
        jmp halted

end: