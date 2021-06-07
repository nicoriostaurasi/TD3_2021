/*
linker básico
*/
ENTRY (reset)

    __EH_FRAME          = 0x00060000; /*seccion para c y c++ exception handling*/
    __DATA_NO_INIT      = 0x00050000; 

    __STACK_START_16    = 0x9000;  /*SS=0x9000*/
    __STACK_END_16      = 0x9FFF;

    /*
    Mapa de memoria a seguir:
        *Sys_tables      0x0000-0000
        *Tablas de Pag.  0x0001-0000
        *Rutinas         0x0005-0000
        *RAM VIDEO       0x000B-8000
        *Teclado + ISR   0x0010-0000
        *Digitos         0x0020-0000
        *Datos           0x0021-0000
        *Kernel          0x0022-0000
        *Tarea 1 TEXT    0x0031-0000
        *Tarea 1 BSS     0x0032-0000
        *Tarea 1 DATA    0x0033-0000
        *Tarea 1 RODATA  0x0034-0000
        *Stack Sistema   0x1FFF-8000
        *Stack Tarea 1   0x1FFF-F000
        *Init ROM        0xFFFF-0000
        *Reset Vector    0xFFFF-FFF0    
    */ 

    /*-----------------LMA-----------------*/
   
    /*se ensambla en otra zona*/ 
    __ROM_2_RAM             = 0xFFFF0000;  
    __FUNCTIONS_LMA         = __ROM_2_RAM;
  /*__TECLADO_ISR_LMA       = se completa abajo
    __DATOS_LMA             = se completa abajo
    __KERNEL_32_LMA         = se completa abajo
    
    __TASK_01_TEXT_LMA      = se completa abajo
    __TASK_01_BSS_LMA       = se completa abajo
    __TASK_01_DATA_LMA      = se completa abajo
    __TASK_01_RODATA_LMA    = se completa abajo*/

    /*Se Quedan en ROM*/
    __ROM_2_ROM             = 0xFFFF8000;
    __INIT_16_LMA           = __ROM_2_ROM; 
/*  __VGA_INIT_LMA          = se completa abajo    
    __INIT_32_LMA           = se completa abajo    
    __FUNCTIONS_ROM_LMA     = se completa abajo */
    __SYS_TABLES_16_LMA     = 0xFFFFF000;
    __RESET_LMA             = 0xFFFFFFF0;

    /*-----------------VMA-----------------*/
    /*Donde guardo la IDT32+GDT32*/
    __SYS_TABLES_32_VMA     = 0x00000000; 

    /*Sección de las Tablas de paginacion*/
    __PAGE_TABLES_VMA       = 0x00010000;
    
    /*Rutinas*/
    __FUNCTIONS_VMA         = 0x00050000; /*tengo los saltos referenciados a 0*/

    /*Sección de RAM de video*/
    __VIDEO_VGA             = 0x000B8000;

    /*Teclado + ISR*/
    __TECLADO_ISR_VMA       = 0x00100000;

    /*Sección de memoria con datos*/
    __DATOS_VMA             = 0x00200000;
    __RING_BUFFER_INIT      = 0x00200000;
    __RING_BUFFER_END       = 0x0020000F;
    __DATOS_TIMER_VMA       = 0x00200050;
    __DATOS_PROMEDIO_VMA    = 0x00200060;
    __DATOS_SCH_VMA         = 0x00200070;
    __DATOS_CONVERSION_VMA  = 0x00200090;

    /*Tabla de Dígitos*/
    __DIGITOS_VMA           = 0x00210000;

    /*Kernel*/
    __KERNEL_32_VMA         = 0x00220000;

    /*Task 1*/
    __TASK_01_VMA           = 0x00310000;

    __TASK_01_TEXT_VMA      = 0x00310000;
    __TASK_01_BSS_VMA       = 0x00320000;
    __TASK_01_DATA_VMA      = 0x00330000;
    __TASK_01_RODATA_VMA    = 0x00340000;

    /*Stack 32*/
    __STACK_START_32        = 0x1FFF8000;
    __STACK_END_32          = 0x1FFF8FFF;

    __STACK_SIZE_32 = ((__STACK_END_32 - __STACK_START_32) / 4); /*32b word*/
    
    __TASK_01_STACK_START   = 0x1FFFF000;
    __TASK_01_STACK_END     = 0x1FFFFFFF;
    __TASK_01_STACK_SIZE    = ((__TASK_01_STACK_END - __TASK_01_STACK_START) / 4); 

    /*Init ROM*/ 
    __INIT_16_VMA           = __INIT_16_LMA;
    __VGA_INIT_VMA          = __VGA_INIT_LMA; /*donde se encuentran las rutinas de VGA*/
    __INIT_32_VMA           = __INIT_32_LMA;
    __FUNCTIONS_ROM_VMA     = __FUNCTIONS_ROM_LMA;
    __SYS_TABLES_16_VMA     = __SYS_TABLES_16_LMA; /*donde guardo la GDT*/
    
    /*Vector de Reset*/
    __RESET_VMA             = 0xFFFFFFF0;
    
    /* Parametros de Paginacion*/
    /*Directorio*/
    __PDT_Sistema           = 0x00000000;
    /*Contiene a las paginas desde el inicio hasta Stack*/
    __PDT_Stack_Sistema     = __STACK_START_32;
    /*Contiene a las paginas del Stack*/

    /*Paginas*/
    __PT_SYS_TABLES         = __SYS_TABLES_32_VMA;
    __PT_TABLAS_PAGINACION  = __PAGE_TABLES_VMA;
    __PT_FUNCIONES          = __FUNCTIONS_VMA;
    __PT_VIDEO              = __VIDEO_VGA;
    __PT_TECLADO_ISR        = __TECLADO_ISR_VMA; 
    __PT_DATOS              = __DATOS_VMA;
    __PT_DIGITOS            = __DIGITOS_VMA; 
    __PT_KERNEL             = __KERNEL_32_VMA;
    __PT_TASK_01            = __TASK_01_VMA;
    __PT_TASK_01_TEXT       = __TASK_01_TEXT_VMA;      
    __PT_TASK_01_BSS        = __TASK_01_BSS_VMA;     
    __PT_TASK_01_DATA       = __TASK_01_DATA_VMA;      
    __PT_TASK_01_RODATA     = __TASK_01_RODATA_VMA;    
    __PT_STACK_SISTEMA      = __STACK_START_32;
    __PT_TASK_01_STACK      = __TASK_01_STACK_START;

MEMORY
{
    ram (!x) : ORIGIN = 0x00000000, LENGTH = 0xFFFF0000 /*2 a la 32 (4GB) - 2 a la 16 (64KB)*/
    rom (rx) : ORIGIN = 0xFFFF0000, LENGTH = 64K
}
/*
defino diferentes secciones con diferentes permisos
rx: read and executable
!x: todo y executable

Origen
Longitud rom: 64kb antes del final

Puedo colocar mas secciones del mapa de memoria
*/
SECTIONS
{
/*
defino la seccion de salida segun la seccion de entrada
*/
    .functions __FUNCTIONS_VMA :
        AT (__FUNCTIONS_LMA)
        { *(.functions); 
          ./bin/functions.elf(.note*);
          ./bin/functions.elf(.bss);
          ./bin/functions.elf(.data);
          ./bin/functions.elf(.rodata);
        }> ram
    __functions_size = SIZEOF(.functions);

    __TECLADO_ISR_LMA = LOADADDR(.functions) + SIZEOF(.functions); 

    .teclados_isr __TECLADO_ISR_VMA :
        AT (__TECLADO_ISR_LMA)
        { *(.teclado_and_ISR)} > ram 
    __teclados_isr_size = SIZEOF(.teclados_isr);

    __DATOS_LMA = LOADADDR(.teclados_isr) + SIZEOF(.teclados_isr);

    .datos __DATOS_VMA :
        AT (__DATOS_LMA)
        { ./bin/main.elf(.data); } > ram
    __datos_size = SIZEOF(.datos);

    __KERNEL_32_LMA = LOADADDR(.datos) + SIZEOF(.datos);

    .codigo_kernel32 __KERNEL_32_VMA :
        AT (__KERNEL_32_LMA)
        { *(.kernel32); } > ram
    __codigo_kernel32_size = SIZEOF(.codigo_kernel32); 

    __TASK_01_TEXT_LMA = LOADADDR(.codigo_kernel32) + SIZEOF(.codigo_kernel32);

    /*-----TAREA 1-----*/
    .task01_texto __TASK_01_TEXT_VMA :
    AT (__TASK_01_TEXT_LMA)
    {*(.functions_task01);
     ./bin/task01.elf(.note*);} > ram
    __codigo_task_01 = SIZEOF(.task01_texto);

    __TASK_01_BSS_LMA = LOADADDR(.task01_texto) + SIZEOF(.task01_texto);

    .task01_bss __TASK_01_BSS_VMA :
    AT (__TASK_01_BSS_LMA)
    {./bin/task01.elf(.bss);} > ram
    __bss_task_01 = SIZEOF(.task01_bss);

    __TASK_01_DATA_LMA = LOADADDR(.task01_bss) + SIZEOF(.task01_bss);

    .task01_data __TASK_01_DATA_VMA :
    AT (__TASK_01_DATA_LMA)
    {./bin/task01.elf(.data);} > ram
    __data_task_01 = SIZEOF(.task01_data);

    __TASK_01_RODATA_LMA = LOADADDR(.task01_data) + SIZEOF(.task01_data);  

    .task01_rodata __TASK_01_RODATA_VMA :
    AT (__TASK_01_RODATA_LMA)
    {./bin/task01.elf(.rodata);} > ram
    __rodata_task_01 = SIZEOF(.task01_rodata);
    

    /*-----ROM-----*/
    .codigo_init16 __INIT_16_VMA :
        AT (__INIT_16_LMA)
        { *(.ROM_init); } > rom 

    __VGA_INIT_LMA = LOADADDR(.codigo_init16) + SIZEOF(.codigo_init16);

    .video __VGA_INIT_VMA :
        AT (__VGA_INIT_LMA )
        {*(.video);} > rom

    __INIT_32_LMA = LOADADDR(.video) + SIZEOF(.video);

    .codigo_init32 __INIT_32_VMA :
        AT (__INIT_32_LMA)
        { *(.start32); } > rom 

    __FUNCTIONS_ROM_LMA = LOADADDR(.codigo_init32) + SIZEOF(.codigo_init32);

    .functions_rom __FUNCTIONS_ROM_VMA :
        AT (__FUNCTIONS_ROM_LMA)
        { *(.functions_rom);
          ./bin/functions_rom.elf(.note*);
          ./bin/functions_rom.elf(.data);
          ./bin/functions_rom.elf(.bss);
          ./bin/functions_rom.elf(.rodata);
          *(.utils32) } > rom

    .sys_tables_16 __SYS_TABLES_16_VMA :
        AT (__SYS_TABLES_16_LMA)
        { *(.sys_table_gdt_16);} > rom 

    .codigo_reset __RESET_VMA :
        AT (__RESET_LMA)
        { *(.resetVector); } > rom 

    .fill_rom :
        { FILL(0x90);
          . = ORIGIN(rom) + LENGTH(rom)-1;      
          BYTE(0x90);
        } > rom

}