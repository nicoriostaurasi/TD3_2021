OUTPUT=./bin/elf_hw
LINKER_OBJETS=./obj/main.o ./obj/functions.o

all: main functions
	mkdir -p bin
	gcc -o $(OUTPUT) $(LINKER_OBJETS)

main:
	mkdir -p obj
	gcc -c ./src/$@.c -o ./obj/$@.o

functions:
	mkdir -p obj
	gcc -c ./src/$@.c -o ./obj/$@.o

exec:
	$(OUTPUT)

clean:
	rm -R ./bin
	rm -R ./obj

dump:
	objdump -s $(OUTPUT)