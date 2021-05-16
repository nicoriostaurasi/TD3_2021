
        ;directivas
USE16
GLOBAL start16
%macro	DRAM_Enable 0
	nop	;* Simula la habilitación de la DRAM y su controlador que Bochs
		;* ya tiene habilitados por simulación :)
		;* Luego de esta macro usar se puede definir un stack y llamar 
		;* a las rutinas que se necesite ...
%endmacro

;destino EQU 0x0FFFF
destino EQU 0xF000

start16_size EQU fin_start16 - inicio_start16 

section .start16
inicio_start16:
idle:
        hlt
        jmp    idle
start16:
    test eax,0x0    ;verificar que el uP no este en falla
    jne fault_end

;* Se activa la DRAM y su controlador
	DRAM_Enable
;* Seteamos un stack
	mov 	sp,0x3000
    mov     ax,0
    mov     es,ax
    mov     di,destino
    mov     si,inicio_start16
    mov     cx,start16_size
    call    memcopy
    jmp     0x0:destino

memcopy:                    ;rutina de memcpy
next:
    mov     al,byte[cs:si]  
    stosb                   ;[es:di]<-al , di++
    inc     si              ;apuntamos al siguiente byte en la ROM
    loop    next            ;cx--, if(FLAGS.ZF==0) goto next 
    ret

fault_end:          ;debe ir al final de la sección
    hlt
fin_start16:
