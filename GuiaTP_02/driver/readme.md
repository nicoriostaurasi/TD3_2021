# Driver I2C - MPU6050

## Estructura de la carpeta

* ***device_tree***: Se encuentra el *device tree source* utilizado para compilar el *dtb* correspondiente al TP

* ***inc***: Se encuentran archivos .h con distintos defines de utilidad y funciones implementadas

* ***src***: Se encuentra el archivo fuente del driver

* ***test_src***: Archivo fuente para probar el driver de I2C

* ***Makefile***: Makefile para compilar e instalar el módulo


## Acceso rapido de la carpeta

* [Device tree](/GuiaTP_02/driver/device_tree/)

* [Inc](/GuiaTP_02/driver/inc/)

* [Src](/GuiaTP_02/driver/src/)

* [Test Src](/GuiaTP_02/driver/test_src/)

* [Makefile](/GuiaTP_02/driver/Makefile)


## Descripción de los Fuentes

* **NRT_file_operations.c**: Contiene la funciones de read, write, open, close e ioctl para que pueda usar el usuario. [Fuente](src/NRT_file_operations.c)

* **NRT_globals.c**: Contiene las variables globales utilizadas para los distintos archivos [Fuente](src/NRT_globals.c)

* **NRT_i2c_rw.c**: Contiene las funciones de lectura y escritura en el bus de I2C. Las mismas pueden ser extensibles a n bytes [Fuente](src/NRT_i2c_rw.c)

* **NRT_mpu_6050.c**: Contiene funciones de utilidad para el módulo del sensor [Fuente](src/NRT_mpu_6050.c)

* **NRT_platform_device.c**: Contiene las funciones de probe, remove y el handler de interrupción de I2C [Fuente](src/NRT_platform_device.c)


* **NRT_td3_i2c_dev.c**: Contiene las funciones de inicialización y salida del módulo [Fuente](src/NRT_td3_i2c_dev.c)

* **test_src/main.c**: Contiene una rutina de lectura por ráfaga de 14 bytes de la FIFO del sensor [Fuente](test_src/main.c)

* **Makefile**: Para correr
```sh
make build

make insmod
```
Versiones:
```sh
```
