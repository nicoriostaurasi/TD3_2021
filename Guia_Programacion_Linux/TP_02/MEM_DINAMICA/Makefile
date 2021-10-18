LINKER_OBJECTS		= 
LINKER_SRIPT		= 
LINKER_DEPENDENCIES	= 
LINKER_ENTRY_POINT	= 
OUTPUT 				= 
AFLAG 				= 
CFLAG 				= -o 

$(OUTPUT): $(LINKER_DEPENDENCIES)
	@echo Generando $@...
	ld -z max-page-size=0x1000 --oformat=binary -m elf_i386 -T $(LINKER_SRIPT) -e $(LINKER_ENTRY_POINT) $(LINKER_OBJECTS) -o $(OUTPUT) 

main: ./src/main.c
	@echo Generando $@.o...				
	mkdir -p bin
	mkdir -p sup
	gcc $(CFLAG) ./bin/$@.bin ./src/$@.c -g
	./bin/main.bin

clean:
	rm -f -r ./sup/*.lst ./bin/*.elf ./bin/*.bin ./obj/*.o

run:
	./bin/main.bin

