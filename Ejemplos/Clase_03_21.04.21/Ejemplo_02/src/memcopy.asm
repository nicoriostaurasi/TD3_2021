; Armamos una ROM de 4 KBytes
; El procesador arranca en FFFF0 y en modo real, con
; lo cual el mapa de memoria es de 1MB

ORG 0xFF000	; Esto es: 1MB - 4KB + 1 -> 0xFFFFF-0x1000 = 0xFEFFF. Entonces
		; el origen de nuestra ROM es: 0xFEFFF +  1 (que es la sig posición
		; de memoria): 0xFF000

USE16
code_size EQU end - init_bootstrap		

; Rellenamos la ROM con 0x90 (NOP)
times (4096-code_size) db 0x90 ; Otra opción: times 4096 resb 1

init_bootstrap:

idle:
	hlt
	jmp	idle

;/**
;* Subrutina: memcopy
;* Recibe:
;*  es:di la dirección lógica de destino (a donde quiero copiar)
;*  ds:si la dirección lógica de origen (lo que quiero copiar)
;*  cx la cantidad de bytes a copiar
;* Retorna:
;*  NULL si hubo error
;*  puntero a la dirección de inicio de la nueva copia
memcopy:
	cld
next:
	mov	al,byte[cs:si]	; ver commentario al final
	stosb			;[es:di]<-al , di++
	inc 	si		;apuntamos al siguiente byte en la ROM
	loop	next		;cx--, if(FLAGS.ZF==0) goto next 
	mov	bx,ret0
	jmp 	bx
init:
	xor	bx,bx		;Inicializamos el registro es en 0
	mov	es,bx		;Si bien es su valor luego del reset...
	mov	di,0x7c00	;Offset dentro del segmento destino
	mov	si,init_bootstrap;Offset dentro del segmento origen
	mov	cx,code_size	;Cantidad de bytes a copiar (parte útil de la ROM)
	mov	bx,memcopy	;Como no se ha inicializado la RAM aun....
	jmp	bx		;saltamos en vez de llamar a subrutina 
ret0:
	jmp	0x0:0x7C00	;saltamos a la copia
align 16
init16:				
	cli
	jmp	init
aqui:
	hlt
	jmp	aqui

align 16		
end:

;/**
;* ¿Porque se utiliza [cs:si] para direccionar los bytes en oirgen? 
;* Luego de un Reset, lso procesadores x86 inician como un 8086. Esto es:
;* 1. Direccionan 1 Mbyte de memoria.
;* 2. El modo de trabajo es en 16 bits.
;* 3. los registros CS e IP valen: cs=0xF000, y IP = 0xFFF0, lo cual en Modo 
;*    Real lleva a la dirección de Memoria 0xFFFF0 para buscar la primer 
;*    instrucción a ejecutar.
;* Debido a 3., el diseñador de Hardware debería mapear en ese espacio una 
;* memoria de tipo No Volatil. 
;* En un procesador x86 con arquitectura IA-32, se dispone de un espacio físico
;* de 4Gbytes. Poner una ROM alrrededor de la dirección 1 Mega... no suena muy
;* apropiado.
;* Para evitarlo lso diseñadores de Intel introducen una facilidad de modo 
;* protegido disponible en modo real. Usan en modo real el registro hidden
;* del registro CS con valores default:
;* Base = 0xFFFF0000
;* Limite = 0xFFFF
;* De este modo el procesador buscará su primer instrucción en:
;*     Base: FFFF0000
;*     + 
;*       IP:     FFF0
;*    ---------------------
;*           FFFFFFF0
;* Permitiendo al procesador acceder a un área de memoria cercana a los 4Gbytes.
;* El precio es no poder cambiar CS. Ni bien se modifique su valor, se borran 
;* los valores default del regstro cache hidden asociado a CS, quedando ahora
;* restringido al primer Megabyte de memoria.
;* Por este motivo no podemos replicar esta accesibilidad a otros registros de 
;* segmento ya que sus registros hidden no están accesibles nunca en modo Real.
;* Entonces utilizamos el prefijo de segmento CS para modificar el registro de 
;* segmento que la instrucción utilizará por default utilizando a SI como 
;* offset  
;*/