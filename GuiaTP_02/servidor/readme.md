# Servidor TCP Concurrente

## Estructura de la carpeta

* ***inc***: Se encuentran archivos .h con distintos defines de utilidad y funciones implementadas

* ***src***: Se encuentra el archivo fuente del servidor

* ***cfg.txt***: Archivo de configuración para el servidor

* ***Makefile***: Makefile para compilar e instalar el módulo

## Acceso rapido de la carpeta

* [Inc](/GuiaTP_02/servidor/inc/)
  
* [Src](/GuiaTP_02/servidor/src/)

* [CFG](/GuiaTP_02/servidor/cfg.txt)

* [Makefile](/GuiaTP_02/servidor/Makefile)


## Descripción de los Fuentes

* **driver_handler.c**: Contiene la función que ejecuta el proceso colector de datos [Fuente](src/driver_handler.c)

* **file_handler.c**: Contiene la funcion que colecta los datos del archivo de configuración [Fuente](src/filtrado.c)

* **filtrado.c**: Contiene la funcion que realiza el filtro de media movil [Fuente](src/file_handler.c)

* **main.c**: Contiene el programa principal, se encarga de levantar los recursos del sistema operativo y luego levantar los distintos procesos para delegar tareas [Fuente](src/main.c)

* **servidor.c**: Contiene las funciones que se encargan de atender las peticiones de los clientes mientras los mismos se encuentren conectados[Fuente](src/servidor.c)

* **Makefile**: Para correr
```sh
make 
```
Versiones:
```sh
```
