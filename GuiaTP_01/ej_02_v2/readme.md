# Ejercicio 2 - Interacción Básica utilizando solo el ensamblador con acceso a 1 MB

## Repositorio del TP#01-02

## Estructura de la carpeta

* ***Doc***: Se encuentran los txt generados por bochs
 
* ***Src***: Se encuentra el archivo fuente del TP.

* ***.bochsrc***: Archivo de configuración bochs

* ***Makefile***: Makefile para compilar

* ***linker.ld***: Linker Script del código

## Acceso rapido de la carpeta

* [Src](/GuiaTP_01/ej_02_v2/src/)

* [Doc](/GuiaTP_01/ej_02_v2/doc/)

* [.bochsrc](.bochsrc)

* [Makefile](Makefile)

* [linker.ld](linker.ld)

* [Guia de TP](http://wiki.electron.frba.utn.edu.ar/lib/exe/fetch.php?media=td3:gtp_td3_2021_1_v1_1.pdf)

## Descripción de los Fuentes

* **init16.asm**: Contiene la rutina de inicialización, setea un stack de 16 y llama a memcpy. [Fuente](src/init16.asm)

* **reset.asm**: Contiene el vector de reset. [Fuente](src/reset.asm) 
  
* **reset.asm**: Contiene la definicion de ROM. [Fuente](src/rom_define.asm) 

* **Linker Script**: Mapeo de memoria. [Fuente](linker.ld)


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
## Observaciones

* El ejercicio es muy similar al ejemplo de la clase, únicamente se define la ROM de 64KB en lugar de 4KB
* No es posible copiar en la memoria 0xF0000, ya que no podemos acceder a ella en 16 bits.
