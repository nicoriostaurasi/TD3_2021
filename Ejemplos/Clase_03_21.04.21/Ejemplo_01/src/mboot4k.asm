; Armamos una ROM de 4 KBytes
; El procesador arranca en FFFF0 y en modo real, con
; lo cual el mapa de memoria es de 1MB

ORG 0xFF000	; Esto es: 1MB - 4KB + 1 -> 0xFFFFF-0x1000 = 0xFEFFF. Entonces
		; el origen de nuestra ROM es: 0xFEFFF +  1 (que es la sig posición
		; de memoria): 0xFF000

USE16
code_size EQU (end - init16)		

; Rellenamos la ROM con 0x90 (NOP)
times (4096-code_size) db 0x90 ; Otra opción: times 4096 resb 1

init16:				
	cli
	jmp	init16
aqui:
	hlt		; Si por algún motivo sale del loop: HALT
	jmp	aqui    ; Solo sale por reset o por interrupción
align 16		; Completa hasta la siguiente dirección múltiplo
			; de 16 (verificar con que completa con NOP ’s).

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