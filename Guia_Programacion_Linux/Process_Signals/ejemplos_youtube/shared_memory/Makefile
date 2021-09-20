main:
	gcc src/main.c -o sm_create -lrt
	gcc src/main2.c -o sm_write -lrt
	gcc src/main3.c -o sm_read -lrt

	./sm_create
	./sm_write
	./sm_read
clean:
	rm -f -r ./sup/*.lst ./bin/*.elf ./bin/*.bin ./obj/*.o

