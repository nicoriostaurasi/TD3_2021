.PHONY:clean edit bless bochs

LINKER_OBJETS = ./bin/init16.o ./bin/init32.o ./bin/reset.o
LINKER_SCRIPT = ./linker.ld 
LINKER_DEPENDENCIES = init16 init32 reset 
LINKER_ENTRY_POINT = Reset 
OUTPUT = bios.bin 

$(OUTPUT): $(LINKER_DEPENDENCIES)
	@echo Generando $@...
	ld -z max-page-size=0x01000 --oformat=binary -m elf_i386 -T $(LINKER_SCRIPT) -e $(LINKER_ENTRY_POINT) $(LINKER_OBJETS) -o ./bin/$(OUTPUT)

init16: ./src/init16.asm
	@echo Generando $@.asm...
	mkdir -p bin
	mkdir -p sup
	nasm -f elf32 ./src/$@.asm -o ./bin/$@.o -l ./sup/$@.lst 

init32: ./src/init32.asm
	@echo Generando $@.asm...
	mkdir -p bin
	mkdir -p sup
	nasm -f elf32 ./src/$@.asm -o ./bin/$@.o -l ./sup/$@.lst 

reset: ./src/reset.asm
	@echo Generando $@.asm...
	mkdir -p bin
	mkdir -p sup
	nasm -f elf32 ./src/$@.asm -o ./bin/$@.o -l ./sup/$@.lst 

bless:
	bless ./bin/bios.bin

clean:
	rm -f -r ./src/*.lst ./bin/*.elf ./bin/*.o

edit:
	kate ./src/*.asm ./src/*.c ./src/*.cpp ./src/*.h ./src/*.inc ./src/*.lst Makefile linker.lds bochs

bochs:
	bochs -f bochsrc