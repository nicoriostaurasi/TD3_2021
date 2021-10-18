BINPATH				= ./bin/
CFLAGS				= -pthread -lrt -o 
EJ_NAME				= server
OBJS = $(SRCPATH)main.c $(SRCPATH)driver_dummy.c $(SRCPATH)servidor.c $(SRCPATH)file_handler.c 
SRCPATH				= ./src/

all:
	mkdir -p bin
	@echo Generando Ejecutable
	gcc $(OBJS) $(CFLAGS) $(BINPATH)$(EJ_NAME) 
	$(BINPATH)$(EJ_NAME)

clean:
	rm -f -r ./sup/*.lst ./bin/*.elf ./bin/*.bin ./obj/*.o

run:
	$(BINPATH)$(EJ_NAME)

