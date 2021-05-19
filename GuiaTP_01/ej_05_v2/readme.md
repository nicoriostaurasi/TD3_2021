# Ejercicio 5

## Repositorio del TP#01-05

## Estructura de la carpeta

* ***Doc***: Se encuentran los .txt generados por bochs

* ***Inc***: Se encuentran archivos .h con distintos defines de utilidad

* ***Src***: Se encuentra el archivo fuente del TP.

* ***.bochsrc***: Archivo de configuración bochs

* ***Makefile***: Makefile para compilar

* ***linker.ld***: Linker Script del código


## Acceso rapido de la carpeta

* [Doc](/GuiaTP_01/ej_05_v2/doc/)

* [Inc](/GuiaTP_01/ej_05_v2/inc/)

* [Src](/GuiaTP_01/ej_05_v2/src/)

* [.bochsrc](.bochsrc)

* [Makefile](Makefile)

* [linker.ld](linker.ld)

* [Guia de TP](http://wiki.electron.frba.utn.edu.ar/lib/exe/fetch.php?media=td3:gtp_td3_2021_1_v1_1.pdf)

## Descripción de los Fuentes

* **init16.asm**: Contiene la rutina de inicialización, gate A20, setea un stack de 16, carga de GDT16 y pasa a modo protegido. [Fuente](src/init16.asm)

* **init32.asm**: Setea los descriptores de segmento, crea un stack de 32 y lo limpia, reprograma los pics y desempaqueta: Sys_Tables, Funciones, kernel y rutinas de interrupcion con teclado. Luego salta al Kernel32 habiendo cargado las idt y gdt de 32. [Fuente](src/init32.asm)

* **isr_keyboard.asm**: Contiene la rutina de lectura de teclado por pooling y los handler de las distintas interrupciones [Fuente](src/isr_keyboard.asm)

* **main.asm**: Contiene el flujo principal del programa. [Fuente](src/main.asm)

* **reset.asm**: Contiene el vector de reset. [Fuente](src/reset.asm) 

* **sys_gdt_table.asm**: Contiene la tabla GDT 32. [Fuente](src/sys_gdt_table.asm)

* **sys_gdt_table16.asm**: Contiene la tabla GDT 16.
[Fuente](src/sys_gdt_table16.asm)

* **sys_idt_table.asm**: Contiene la tabla IDT.
[Fuente](src/sys_idt_table.asm)

* **utils32.asm**: Contiene rutinas utiles: Programar pics. 
[Fuente](src/utils32.asm)

* **Linker Script**: Mapeo de memoria

```ld
    *Sys_tables      0x0000-0000
    *Teclado + ISR   0x0010-0000
    *Datos           0x0021-0000
    *Kernel          0x0020-2000
    *Stack           0x2FF8-0000
    *Init ROM        0xFFFF-0000
    *Reset Vector    0xFFFF-FFF0 
```
[Fuente](/linker.ld)

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
Se cargaron 2 GDT distintas ya que el flujo no dejaba cargar las IDT.
