# Ejercicio 4 - Modo Protegido 32 Bits

## Repositorio del TP#01-04

## Estructura de la carpeta

* ***Doc***: Se encuentran los .txt generados por bochs

* ***Inc***: Se encuentran archivos .h con distintos defines de utilidad

* ***Src***: Se encuentra el archivo fuente del TP.

* ***.bochsrc***: Archivo de configuración bochs

* ***Makefile***: Makefile para compilar

* ***linker.ld***: Linker Script del código


## Acceso rapido de la carpeta

* [Doc](/GuiaTP_01/ej_04/doc/)

* [Inc](/GuiaTP_01/ej_04/inc/)

* [Src](/GuiaTP_01/ej_04/src/)

* [.bochsrc](.bochsrc)

* [Makefile](Makefile)

* [linker.ld](linker.ld)

* [Guia de TP](http://wiki.electron.frba.utn.edu.ar/lib/exe/fetch.php?media=td3:gtp_td3_2021_1_v1_1.pdf)

## Descripción de los Fuentes

* **functions.c**: Contiene la rutina de copia en memoria. [Fuente](src/functions.c)

* **functions_rom.c**: Contiene la rutina copia en memoria quemada en ROM. [Fuente](src/functions_rom.c)

* **init16.asm**: Contiene la rutina de inicialización, gate A20, setea un stack de 16, carga de GDT32 y pasa a modo protegido. [Fuente](src/init16.asm)

* **init32.asm**: Setea los descriptores de segmento, crea un stack de 32 y lo limpia, desempaqueta desde ROM: Funciones y kernel. Luego salta al Kernel32. [Fuente](src/init32.asm)

* **main.asm**: Contiene el flujo principal del programa. [Fuente](src/main.asm)

* **reset.asm**: Contiene el vector de reset. [Fuente](src/reset.asm) 

* **sys_tables.asm**: Contiene la tabla GDT 32. [Fuente](src/sys_tables.asm)

* **Linker Script**: Mapeo de memoria. [Fuente](linker.ld)


```ld
    *Rutinas   0x0010-0000
    *Kernel          0x0020-2000
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
