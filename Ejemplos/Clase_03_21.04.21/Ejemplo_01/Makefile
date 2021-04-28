output=./bin/mibios.bin
LINKER_OBJETS=./obj/mibios.o
LIST=./sup/mibios.list 
NASM_FLAGS=-o $(output) -fbin -Wall -l ./sup/mibios.lst
SOURCE=./src/mboot4k.asm

all:
	mkdir -p sup obj bin
	nasm $(SOURCE) $(NASM_FLAGS)

bochs:
	bochs -f .bochsrc

clean:
	rm -R obj sup bin
