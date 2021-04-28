output=./bin/mimemcopy.bin
LINKER_OBJETS=./obj/mimemcopy.o
LIST=./sup/mimemcopy.list 
NASM_FLAGS=-o $(output) -fbin -Wall -l ./sup/mimemcopy.lst
SOURCE=./src/memcopy.asm

all:
	mkdir -p sup obj bin
	nasm $(SOURCE) $(NASM_FLAGS)

bochs:
	bochs -f .bochsrc

clean:
	rm -R obj sup bin
