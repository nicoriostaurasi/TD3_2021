BINPATH				= ./bin/
CFLAGS				= -Ofast -pthread -lrt 
EJ_NAME				= server
OBJS = $(SRCPATH)main.c $(SRCPATH)driver_handler.c $(SRCPATH)servidor.c $(SRCPATH)file_handler.c $(SRCPATH)filtrado.c 
SRCPATH				= ./src/

all:
	mkdir -p bin
	@echo Generando Ejecutable
	gcc $(OBJS) $(CFLAGS) -o $(BINPATH)$(EJ_NAME) 
	$(BINPATH)$(EJ_NAME)

compile:
	gcc $(OBJS) $(CFLAGS) $(BINPATH)$(EJ_NAME) 

clean:
	rm -f -r ./sup/*.lst ./bin/*.elf ./bin/*.bin ./obj/*.o

run:
	$(BINPATH)$(EJ_NAME)

asm_ofast:
	gcc -S -Ofast $(SRCPATH)filtrado.c

asm_simple:
	gcc -S $(SRCPATH)filtrado.c

