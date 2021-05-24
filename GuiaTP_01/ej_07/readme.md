# Ejercicio 7 - Rutina Temporizada y Controladora de Video

## Repositorio del TP#01-07

## Estructura de la carpeta

* ***Doc***: Se encuentran los .txt generados por bochs

* ***Inc***: Se encuentran archivos .h con distintos defines de utilidad

* ***Src***: Se encuentra el archivo fuente del TP.

* ***.bochsrc***: Archivo de configuración bochs

* ***Makefile***: Makefile para compilar

* ***linker.ld***: Linker Script del código


## Acceso rapido de la carpeta

* [Doc](/GuiaTP_01/ej_07/doc/)

* [Inc](/GuiaTP_01/ej_07/inc/)

* [Src](/GuiaTP_01/ej_07/src/)

* [.bochsrc](.bochsrc)

* [Makefile](Makefile)

* [linker.ld](linker.ld)

* [Guia de TP](http://wiki.electron.frba.utn.edu.ar/lib/exe/fetch.php?media=td3:gtp_td3_2021_1_v1_1.pdf)

## Descripción de los Fuentes

* **functions_rom.c**: Contiene la rutina copia en memoria quemada en ROM. [Fuente](src/functions_rom.c)

* **functions.c**: Contiene la rutina de copia en memoria, carga una determinada GDT según una determinada VMA, carga una determinada IDT según una determinada VMA. Funciones de utilidad para el buffer circular de teclado. Funcion de Handler de Interrupción de timer (systick). Funciones del buffer de pantalla. Funciones de Scheduler. [Fuente](src/functions.c)

* **init16.asm**: Contiene la rutina de inicialización, gate A20, setea un stack de 16, carga de GDT16 y pasa a modo protegido. [Fuente](src/init16.asm)

* **init32.asm**: Setea los descriptores de segmento, crea un stack de 32 y lo limpia, reprograma los pics y desempaqueta: Sys_Tables, Funciones, kernel y rutinas de interrupcion con teclado. Luego salta al Kernel32 habiendo cargado las idt y gdt de 32. [Fuente](src/init32.asm)

* **isr_keyboard.asm**: Contiene la rutina de lectura de teclado por pooling (no utilizada desde el ej 05) y los handler de las distintas interrupciones (Por ahora solo Timer(*IRQ0*) y Teclado (*IRQ1*) ) [Fuente](src/isr_keyboard.asm)

* **main.asm**: Contiene el flujo principal del programa. [Fuente](src/main.asm)

* **reset.asm**: Contiene el vector de reset. [Fuente](src/reset.asm) 

* **sys_gdt_table16.asm**: Contiene la tabla GDT 16.
[Fuente](src/sys_gdt_table16.asm)

* **task01.c**: Contiene las funciones de la Tarea 1: Escribir en VGA, Calcular promedio.[Fuente](src/task01.c)

* **utils32.asm**: Contiene rutinas utiles: Programar pics. Cargar una IDT segun la VMA. Cargar un GDT segun la VMA, Iniciar PIT. 
[Fuente](src/utils_32.asm)

* **Linker Script**: Mapeo de memoria. [Fuente](linker.ld)


```ld
        *Sys_tables      0x0000-0000
        *RAM VIDEO       0x000B-8000
        *Teclado + ISR   0x0010-0000
        *Digitos         0x0020-0000
        *Datos           0x0021-0000
        *Kernel          0x0020-2000
        *Tarea 1         0x0030-0000
        *Stack           0x2FF8-0000
        *Init ROM        0xFFFF-0000
        *Reset Vector    0xFFFF-FFF0      
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
* Las instrucciones no permiten realizar el promedio de un numero de 64 bits, por lo que por ahora se calcula la sumatoria y se imprime en hexa.