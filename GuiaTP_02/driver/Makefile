KERNEL_SOURCE = /lib/modules/$(shell uname -r)/build
MOD_NAME = NRT_td3_i2c_dev

#Converts a module object in LKM
obj-m += src/$(MOD_NAME).o

#Compila el modulo haciendo una llamada al makefile que esta en '/lib/modules/$(shell uname -r)/build'
all: softclean build insmod

build:
	make -C ${KERNEL_SOURCE} M=${PWD} modules

#Limpia todos los archivos objetos
softclean:
	make -C ${KERNEL_SOURCE} M=${PWD} clean

clean: rmmod softclean

rebuild: rmmod all

#Revisa si el modulo esta instalado
cat:
	cat /proc/module | grep $(MOD_NAME)

#instala el modulo
insmod:
	sudo insmod src/$(MOD_NAME).ko

#desinstala el modulo
rmmod:
	sudo rmmod src/$(MOD_NAME).ko

#Muestra los mensajes (dmesg), en el ejemplo todos los printk imprimen el nombre del archivo
dmesg:
	dmesg | grep $(MOD_NAME)

tail:
	tail -f /var/log/syslog

info:
	modinfo src/$(MOD_NAME).ko

dev:
	ls -l /dev/ | grep $(MOD_NAME)

test: btest
	./bin/test

btest:
	gcc -o bin/test test_src/main.c
