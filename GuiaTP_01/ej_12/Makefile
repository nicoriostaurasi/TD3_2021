.PHONY: clean

BINPATH = ./bin/
DOCPATH = ./doc/
INCPATH = ./inc/
LIBPATH = ./lib/
SRCPATH = ./src/
SUPPATH = ./sup/

AC = nasm
CC = gcc 
AFLAGS = -f elf32
CFLAGS = -c -m32 -fno-stack-protector -fno-asynchronous-unwind-tables -Wall -fno-PIC

LDFLAGS = -z max-page-size=0x01000 --oformat=binary -m elf_i386 

LDSCRIPT = linker.ld
ODFLAGS = -CprsSx --prefix-addresses
#en objs guardo todos mis objetos elf
OBJS = $(BINPATH)simd.elf $(BINPATH)init32.elf $(BINPATH)reset.elf $(BINPATH)init16.elf $(BINPATH)main.elf $(BINPATH)task01.elf $(BINPATH)timer.elf $(BINPATH)task02.elf $(BINPATH)task03.elf $(BINPATH)task04.elf $(BINPATH)functions.elf $(BINPATH)functions_rom.elf $(BINPATH)utils_32.elf $(BINPATH)scheduler.elf $(BINPATH)isr_keyboard.elf $(BINPATH)sys_gdt_table16.elf $(BINPATH)init_screen.elf 
#obj temp
#OBJS = $(BINPATH)reset.elf $(BINPATH)sys_gdt_table16.elf $(BINPATH)functions.elf

SRC_NAME = mi_bios

all:$(BINPATH)$(SRC_NAME).bin $(BINPATH)$(SRC_NAME).elf bochs
	mkdir -p doc bin 
	clean
	mkdir -p doc
	hexdump -C $(BINPATH)$(SRC_NAME).bin > $(DOCPATH)$(SRC_NAME)_hexdump.txt
	objdump $(ODFLAGS) $(BINPATH)$(SRC_NAME).elf > $(DOCPATH)$(SRC_NAME)_objdump.txt
	readelf -a $(BINPATH)$(SRC_NAME).elf > $(DOCPATH)$(SRC_NAME)_readelf.txt


$(BINPATH)$(SRC_NAME).bin: $(OBJS)
	ld $(LDFLAGS) -T $(LDSCRIPT) $(OBJS) -o $@ -Map $(SRC_NAME).map

$(BINPATH)$(SRC_NAME).elf: $(OBJS)
	ld -z max-page-size=0x01000 -m elf_i386 -T $(LDSCRIPT) $(OBJS) -o $@

$(BINPATH)main.elf: $(SRCPATH)main.asm
	@echo Generando $@
	mkdir -p bin
	$(AC) $(AFLAGS) $< -o $@ -l $@.lst

$(BINPATH)reset.elf: $(SRCPATH)reset.asm
	@echo Generando $@
	mkdir -p bin
	$(AC) $(AFLAGS) $< -o $@ -l $@.lst

$(BINPATH)init16.elf: $(SRCPATH)init16.asm
	@echo Generando $@
	mkdir -p bin
	$(AC) $(AFLAGS) $< -o $@ -l $@.lst

$(BINPATH)init32.elf: $(SRCPATH)init32.asm
	@echo Generando $@
	mkdir -p bin
	$(AC) $(AFLAGS) $< -o $@ -l $@.lst

$(BINPATH)utils_32.elf: $(SRCPATH)utils_32.asm
	@echo Generando $@
	mkdir -p bin
	$(AC) $(AFLAGS) $< -o $@ -l $@.lst

$(BINPATH)scheduler.elf: $(SRCPATH)scheduler.asm
	@echo Generando $@
	mkdir -p bin
	$(AC) $(AFLAGS) $< -o $@ -l $@.lst

$(BINPATH)simd.elf: $(SRCPATH)simd.asm
	@echo Generando $@
	mkdir -p bin
	$(AC) $(AFLAGS) $< -o $@ -l $@.lst

$(BINPATH)isr_keyboard.elf: $(SRCPATH)isr_keyboard.asm
	@echo Generando $@
	mkdir -p bin
	$(AC) $(AFLAGS) $< -o $@ -l $@.lst

$(BINPATH)sys_gdt_table16.elf: $(SRCPATH)sys_gdt_table16.asm
	@echo Generando $@
	mkdir -p bin
	$(AC) $(AFLAGS) $< -o $@ -l $@.lst

$(BINPATH)sys_gdt_table.elf: $(SRCPATH)sys_gdt_table.asm
	@echo Generando $@
	mkdir -p bin
	$(AC) $(AFLAGS) $< -o $@ -l $@.lst

$(BINPATH)sys_idt_table.elf: $(SRCPATH)sys_idt_table.asm
	@echo Generando $@
	mkdir -p bin
	$(AC) $(AFLAGS) $< -o $@ -l $@.lst

$(BINPATH)init_screen.elf: $(SRCPATH)init_screen.asm
	@echo Generando $@
	mkdir -p bin
	$(AC) $(AFLAGS) $< -o $@ -l $@.lst


$(BINPATH)functions_rom.elf: $(SRCPATH)functions_rom.c
	@echo Generando $@
	mkdir -p bin
	$(CC) $(CFLAGS) $< -o $@ -l $@.lst 

$(BINPATH)task01.elf: $(SRCPATH)task01.c
	@echo Generando $@
	mkdir -p bin
	$(CC) $(CFLAGS) $< -o $@ -l $@.lst

$(BINPATH)task02.elf: $(SRCPATH)task02.c
	@echo Generando $@
	mkdir -p bin
	$(CC) $(CFLAGS) $< -o $@ -l $@.lst

$(BINPATH)task03.elf: $(SRCPATH)task03.c
	@echo Generando $@
	mkdir -p bin
	$(CC) $(CFLAGS) $< -o $@ -l $@.lst

$(BINPATH)task04.elf: $(SRCPATH)task04.c
	@echo Generando $@
	mkdir -p bin
	$(CC) $(CFLAGS) $< -o $@ -l $@.lst


$(BINPATH)functions.elf: $(SRCPATH)functions.c
	@echo Generando $@
	mkdir -p bin
	$(CC) $(CFLAGS) $< -o $@

$(BINPATH)timer.elf: $(SRCPATH)timer.c
	@echo Generando $@
	mkdir -p bin
	$(CC) $(CFLAGS) $< -o $@


bochs:
	@echo llamando a bochs
	@echo listo! "\ n_n /"
	bochs -q

clean:
	@echo limpiando carpeta..
	rm $(BINPATH)*.bin $(BINPATH)*.elf $(BINPATH)*.lst *.map
