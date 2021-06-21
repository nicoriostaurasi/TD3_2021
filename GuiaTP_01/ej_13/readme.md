# Ejercicio 13 - Niveles de Privilegio

## Repositorio del TP#01-13

## Estructura de la carpeta

* ***Doc***: Se encuentran los .txt generados por bochs

* ***Inc***: Se encuentran archivos .h con distintos defines de utilidad

* ***Src***: Se encuentra el archivo fuente del TP.

* ***.bochsrc***: Archivo de configuración bochs

* ***Makefile***: Makefile para compilar

* ***linker.ld***: Linker Script del código


## Acceso rapido de la carpeta

* [Doc](/GuiaTP_01/ej_10/doc/)

* [Inc](/GuiaTP_01/ej_10/inc/)

* [Src](/GuiaTP_01/ej_10/src/)

* [.bochsrc](.bochsrc)

* [Makefile](Makefile)

* [linker.ld](linker.ld)

* [Guia de TP](http://wiki.electron.frba.utn.edu.ar/lib/exe/fetch.php?media=td3:gtp_td3_2021_1_v1_1.pdf)

## Descripción de los Fuentes

* **functions_rom.c**: Contiene la rutina copia en memoria quemada en ROM. [Fuente](src/functions_rom.c)

* **functions.c**: Contiene la rutina de copia en memoria, carga de los descriptores de tabla de página (DTP) como las tablas de página (TP), paginación de una ROM de 64KB, carga una determinada GDT según una determinada VMA, carga una determinada IDT según una determinada VMA. Funciones de utilidad para el buffer circular de teclado. Funcion de Handler de Interrupción de timer (systick). Funciones del buffer de pantalla. Funciones de Scheduler. Funciones de Paginación. [Fuente](src/functions.c)

* **init16.asm**: Contiene la rutina de inicialización, gate A20, setea un stack de 16, carga de GDT16, inicia el controlador VGA y pasa a modo protegido. [Fuente](src/init16.asm)

* **init32.asm**: Setea los descriptores de segmento, crea un stack de 32 y lo limpia, reprograma los pics y desempaqueta: Sys_Tables, Funciones, kernel, Tarea 1 con sus respectivas secciones y rutinas de interrupcion con teclado. Realiza las rutinas de paginación básica. Luego salta al Kernel32 habiendo cargado las idt y gdt de 32 junto con la Habilitación de la paginación. [Fuente](src/init32.asm)

* **isr_keyboard.asm**: Contiene la rutina de lectura de teclado por pooling (no utilizada desde el ej 05) y los handler de las distintas interrupciones (Por ahora solo Timer(*IRQ0*) y Teclado (*IRQ1*) ). Se agrego un controlador de PF, para una vez que se encuentre una página no presente agregar un TP y un DTP correspondiente a partir de la dirección física*0x0A000000*. [Fuente](src/isr_keyboard.asm)

* **main.asm**: Contiene el flujo principal del programa. [Fuente](src/main.asm)

* **reset.asm**: Contiene el vector de reset. [Fuente](src/reset.asm) 

* **scheduler.asm**: Contiene el Algoritmo para manejar varias tareas de manera secuencial y cooperativa, el mismo guarda el contexto de cada tarea y lo recupera al volver a realizar sus distintas llamadas. También se ocupa de la protección entre tareas para que no puedan ver su contenido de codigo y datos entre ellas. [Fuente](src/scheduler.asm). Para el diseño del mismo se implemento el siguiente [diagrama de estados](Scheduler_TD3.pdf)

* **simd.asm**: Contiene las funciones de utilidad para las tareas 2 y 3.[Fuente](src/simd.asm) 

* **sys_gdt_table16.asm**: Contiene la tabla GDT 16.
[Fuente](src/sys_gdt_table16.asm)

* **task_multiple.asm**: Contiene las rutinas de tareas en ASM. [Fuente](src/task_multiple.asm)

* **task01.c**: Contiene las funciones de la Tarea 1: Escribir en VGA, Calcular promedio.[Fuente](src/task01.c)

* **task02.c**: Contiene las funciones de la Tarea 2: Escribir en VGA, Calcular Sumatoria.[Fuente](src/task02.c)

* **task03.c**: Contiene las funciones de la Tarea 3: Escribir en VGA, Calcular Sumatoria.[Fuente](src/task02.c)

* **task04.c**: Contiene las funciones de la Tarea 4: Establecer el Procesador en alta impedancia.[Fuente](src/task04.c)

* **timer.c**: Contiene las funciones para contabilizar distintos tiempos. Contiene el algoritmo de scheduler en C pero el mismo fue descartado. [Fuente](src/timer.c)

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
        
        *Tarea 2 TEXT    0x0041-1000    *Tarea 2 TEXT    0x0141-0000    
        *Tarea 2 BSS     0x0042-0000    *Tarea 2 BSS     0x0142-0000    
        *Tarea 2 DATA    0x0043-0000    *Tarea 2 DATA    0x0143-0000    
        *Tarea 2 RODATA  0x0044-0000    *Tarea 2 RODATA  0x0144-0000
        
        *Tarea 3 TEXT    0x0051-0000    *Tarea 3 TEXT    0x0151-0000    
        *Tarea 3 BSS     0x0052-0000    *Tarea 3 BSS     0x0152-0000    
        *Tarea 3 DATA    0x0053-0000    *Tarea 3 DATA    0x0153-0000    
        *Tarea 3 RODATA  0x0054-0000    *Tarea 3 RODATA  0x0154-0000
        
        *Tarea 4 TEXT    0x0061-0000    *Tarea 4 TEXT    0x0161-0000    
        *Tarea 4 BSS     0x0062-0000    *Tarea 4 BSS     0x0162-0000    
        *Tarea 4 DATA    0x0063-0000    *Tarea 4 DATA    0x0163-0000    
        *Tarea 4 RODATA  0x0064-0000    *Tarea 4 RODATA  0x0164-0000
        
        *Stack Sistema   0x1FFF-8000    *Stack Sistema   0x1FFF-8000    
        *Stack Tarea 1   0x1FFF-F000    *Stack Tarea 1   0x0078-F000    
        *Stack Tarea 2   0x3000-0000    *Stack Tarea 2   0x2FFF-1000    
        *Stack Tarea 3   0x3001-0000    *Stack Tarea 3   0x2FFF-2000    
        *Stack Tarea 4   0x3002-0000    *Stack Tarea 4   0x2FFF-3000    

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
* Se modificó la Dirección Física correspondiente a la sección *text* de la tarea 2 ya que la misma solapa las TP de la memoria ROM.
* Se agrego el espacio de contexto de FPU a las tareas correspondientes a la mitad de la página de la TSS de cada tarea.