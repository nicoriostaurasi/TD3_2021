# Ejercicio 3 - Inicialización Básica con el linker

## Repositorio del TP#01-03

## Estructura de la carpeta

* ***Src***: Se encuentra el archivo fuente del TP.

* ***.bochsrc***: Archivo de configuración bochs

* ***Makefile***: Makefile para compilar

* ***linker.ld***: Linker Script del código

## Acceso rapido de la carpeta

* [Src](/GuiaTP_01/ej_03/src/)

* [.bochsrc](.bochsrc)

* [Makefile](Makefile)

* [linker.ld](linker.ld)

* [Guia de TP](http://wiki.electron.frba.utn.edu.ar/lib/exe/fetch.php?media=td3:gtp_td3_2021_1_v1_1.pdf)

## Descripción de los Fuentes

* **init16.asm**: Contiene la rutina de inicialización, setea un stack de 16 y llama a memcpy. [Fuente](src/init16.asm)

* **reset.asm**: Contiene el vector de reset. [Fuente](src/reset.asm) 
  
* **Linker Script**: Mapeo de memoria. [Fuente](linker.ld)


```ld
    *Copia           0x0000-7C00
    *Stack           0x0068-0000
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
