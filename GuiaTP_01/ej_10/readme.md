# Ejercicio 9 - Paginación Avanzada

## Repositorio del TP#01-09

## Estructura de la carpeta

* ***Doc***: Se encuentran los .txt generados por bochs

* ***Inc***: Se encuentran archivos .h con distintos defines de utilidad

* ***Src***: Se encuentra el archivo fuente del TP.

* ***.bochsrc***: Archivo de configuración bochs

* ***Makefile***: Makefile para compilar

* ***linker.ld***: Linker Script del código


## Acceso rapido de la carpeta

* [Doc](/GuiaTP_01/ej_09/doc/)

* [Inc](/GuiaTP_01/ej_09/inc/)

* [Src](/GuiaTP_01/ej_09/src/)

* [.bochsrc](.bochsrc)

* [Makefile](Makefile)

* [linker.ld](linker.ld)

* [Guia de TP](http://wiki.electron.frba.utn.edu.ar/lib/exe/fetch.php?media=td3:gtp_td3_2021_1_v1_1.pdf)

## Descripción de los Fuentes

* **functions_rom.c**: Contiene la rutina copia en memoria quemada en ROM. [Fuente](src/functions_rom.c)

* **functions.c**: Contiene la rutina de copia en memoria, carga de los descriptores de tabla de página (DTP) como las tablas de página (TP), paginación de una ROM de 64KB, carga una determinada GDT según una determinada VMA, carga una determinada IDT según una determinada VMA. Funciones de utilidad para el buffer circular de teclado. Funcion de Handler de Interrupción de timer (systick). Funciones del buffer de pantalla. Funciones de Scheduler. [Fuente](src/functions.c)

* **init16.asm**: Contiene la rutina de inicialización, gate A20, setea un stack de 16, carga de GDT16, inicia el controlador VGA y pasa a modo protegido. [Fuente](src/init16.asm)

* **init32.asm**: Setea los descriptores de segmento, crea un stack de 32 y lo limpia, reprograma los pics y desempaqueta: Sys_Tables, Funciones, kernel, Tarea 1 con sus respectivas secciones y rutinas de interrupcion con teclado. Realiza las rutinas de paginación básica. Luego salta al Kernel32 habiendo cargado las idt y gdt de 32 junto con la Habilitación de la paginación. [Fuente](src/init32.asm)

* **isr_keyboard.asm**: Contiene la rutina de lectura de teclado por pooling (no utilizada desde el ej 05) y los handler de las distintas interrupciones (Por ahora solo Timer(*IRQ0*) y Teclado (*IRQ1*) ) [Fuente](src/isr_keyboard.asm)

* **main.asm**: Contiene el flujo principal del programa. [Fuente](src/main.asm)

* **reset.asm**: Contiene el vector de reset. [Fuente](src/reset.asm) 

* **sys_gdt_table16.asm**: Contiene la tabla GDT 16.
[Fuente](src/sys_gdt_table16.asm)

* **task01.c**: Contiene las funciones de la Tarea 1: Escribir en VGA, Calcular promedio.[Fuente](src/task01.c)

* **utils32.asm**: Contiene rutinas utiles: Programar pics. Cargar una IDT segun la VMA. Cargar un GDT segun la VMA, Iniciar PIT, Rutinas de Carga de PDT y PT junto con cr3.
[Fuente](src/utils_32.asm)

* **Linker Script**: Mapeo de memoria. [Fuente](linker.ld)


```ld
        *Direccion Lineal:              *Direccion Física:
        *Sys_tables      0x0000-0000    *Sys_tables      0x0000-0000    
        *Tablas de Pag.  0x0001-0000    *Tablas de Pag.  0x0001-0000    
        *Rutinas         0x0005-0000    *Rutinas         0x0005-0000    
        *RAM VIDEO       0x000B-8000    *RAM VIDEO       0x00E8-0000  
        *Teclado + ISR   0x0010-0000    *Teclado + ISR   0x0010-0000    
        *Datos           0x0020-0000    *Datos           0x0120-0000
        *Digitos         0x0021-0000    *Digitos         0x0121-0000    
        *Kernel          0x0022-0000    *Kernel          0x0122-0000    
        *Tarea 1 TEXT    0x0031-0000    *Tarea 1 TEXT    0x0131-0000    
        *Tarea 1 BSS     0x0032-0000    *Tarea 1 BSS     0x0132-0000    
        *Tarea 1 DATA    0x0033-0000    *Tarea 1 DATA    0x0133-0000    
        *Tarea 1 RODATA  0x0034-0000    *Tarea 1 RODATA  0x0134-0000    
        *Stack Sistema   0x1FFF-8000    *Stack Sistema   0x1FFF-8000    
        *Stack Tarea 1   0x1FFF-F000    *Stack Tarea 1   0x0078-F000    
        *Init ROM        0xFFFF-0000    *Init ROM        0xFFFF-0000    
        *Reset Vector    0xFFFF-FFF0    *Reset Vector    0xFFFF-FFF0    
```

* **Makefile**: Para correr
```sh
make
```
Versiones:
```sh
gcc -v
gcc version 10.2.0 (Ubuntu 10.2.0-13ubuntu1) 
ld -v
GNU ld (GNU Binutils for Ubuntu) 2.35.1
```

## Observaciones:
* Se cargaron 2 GDT distintas ya que el flujo no dejaba cargar las IDT. *Una solución a este problema es usar el prefijo o32*
* Las instrucciones no permiten realizar el promedio de un numero de 64 bits, por lo que por ahora se calcula la sumatoria y se imprime en hexa. *Solucionado realizando la división bit a bit en un algoritmo en C*
* La guía propone una dirección para el Stack del Sistema que al mapearse su TP queda en una sección del mapa de memoria que contiene ROM, por lo que por el momento se esta mapeando en la posición de la errata (0X1FFF8000), al igual que la posición del stack de tarea 1 (0x1FFFF000).
* En donde la guía indica *Dirección Inicial* debe decir *Dirección Física Inicial*