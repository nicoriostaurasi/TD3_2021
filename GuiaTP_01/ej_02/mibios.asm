USE16

GLOBAL	Entry

section .resetVector
Entry:                          
        cli
        jmp dword init 
aqui:
        hlt
        jmp aqui

align 16                
end:

resetVector_size EQU $ - Entry 
destino EQU 0x7c00

section .ROM_init
init_bootstrap:
idle:
        hlt
        jmp    idle
init:
;* Se activa la DRAM y su controlador
	DRAM_Enable
;* Seteamos un stack
	mov 	sp,0x3000
        mov     ax,0
        mov     es,ax
        mov     di,destino
        mov     si,init_bootstrap
        mov     cx,init_size
        call    memcopy
        jmp     0x0:destino


memcopy:
next:
        mov     al,byte[cs:si]  ; ver commentario al final
        stosb                   ;[es:di]<-al , di++
        inc     si              ;apuntamos al siguiente byte en la ROM
        loop    next            ;cx--, if(FLAGS.ZF==0) goto next 
        ret
init_size EQU $ - init_bootstrap 


%macro	DRAM_Enable 0
	nop	;* Simula la habilitación de la DRAM y su controlador que Bochs
		;* ya tiene habilitados por simulación :)
		;* Luego de esta macro usar se puede definir un stack y llamar 
		;* a las rutinas que se necesite ...
%endmacro

