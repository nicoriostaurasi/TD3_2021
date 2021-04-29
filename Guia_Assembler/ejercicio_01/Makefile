all:
	nasm -g -f elf64 -F DWARF -omain.o main.asm
	ld main.o -o main -g

clean:
	rm -f *.o main
