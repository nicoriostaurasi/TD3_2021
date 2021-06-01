/*
linker básico
*/
ENTRY (reset)

    __EH_FRAME = 0x00060000; /*seccion para c y c++ exception handling*/
    __DATA_NO_INIT = 0x00050000; 

    __STACK_START_16 = 0x9000;  /*SS=0x9000*/
    __STACK_END_16 = 0x9FFF;
    
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
        *Stack           0x2FFF-8000
        *Init ROM        0xFFFF-0000
        *Reset Vector    0xFFFF-FFF0    
    */  

    /*-----------------VMA-----------------*/
    __SYS_TABLES_32_VMA     = 0x00000000; /*donde guardo la IDT32+GDT32*/

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
/*    __DATOS_IMPRESION_VMA   = 0x00200110;*/

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
/*    __STACK_START_32        = 0x2FFF8000;
    __STACK_END_32          = 0x2FFF8FFF;*/

    /*      config 2020   */
    __STACK_START_32        = 0x1FF08000;
    __STACK_END_32          = 0x1FF08FFF;

    __STACK_SIZE_32 = ((__STACK_END_32 - __STACK_START_32) / 4); /*32b word*/
    
    /*Init ROM*/
    __INIT_16_VMA           = 0xFFFFD000;
    __VGA_INIT_VMA          = 0XFFFFE000; /*donde se encuentran las rutinas de VGA*/
    __SYS_TABLES_16_VMA     = 0xFFFFF600; /*donde guardo la GDT*/
    __INIT_32_VMA           = 0xFFFFF700;
    __FUNCTIONS_ROM_VMA     = 0xFFFFF900;
    
    /*Vector de Reset*/
    __RESET_VMA             = 0xFFFFFFF0;
    
    /*-----------------LMA-----------------*/
   
    __KERNEL_32_LMA         = 0xFFFF1000;
    
    __SYS_TABLES_32_LMA     = 0xFFFF2000;
    __TECLADO_ISR_LMA       = 0xFFFF3000;
    __DATOS_LMA             = 0xFFFF4000;
    __FUNCTIONS_LMA         = 0xFFFF5000; /*se ensambla en otra zona*/   
    
    __TASK_01_LMA           = 0xFFFF7000;
    __TASK_01_TEXT_LMA      = 0xFFFF7000;
    __TASK_01_BSS_LMA       = 0xFFFF7C00;
    __TASK_01_DATA_LMA      = 0xFFFF7D00;
    __TASK_01_RODATA_LMA    = 0xFFFF7E00;

    /*Se Quedan en ROM*/
    __INIT_16_LMA           = 0xFFFFD000; 
    __VGA_INIT_LMA          = 0XFFFFE000;    
    __SYS_TABLES_16_LMA     = 0xFFFFF600;
    __INIT_32_LMA           = 0xFFFFF700;    
    __FUNCTIONS_ROM_LMA     = 0xFFFFF900;
    __RESET_LMA             = 0xFFFFFFF0;

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

    .teclados_isr __TECLADO_ISR_VMA :
        AT (__TECLADO_ISR_LMA)
        { *(.teclado_and_ISR)} > ram 
    __teclados_isr_size = SIZEOF(.teclados_isr);
    
    .functions __FUNCTIONS_VMA :
        AT (__FUNCTIONS_LMA)
        { *(.functions); 
          ./bin/functions.elf(.note*);
          ./bin/functions.elf(.bss);
          ./bin/functions.elf(.data);
          ./bin/functions.elf(.rodata);
        }> ram
    __functions_size = SIZEOF(.functions);

    .datos __DATOS_VMA :
        AT (__DATOS_LMA)
        { ./bin/main.elf(.data); } > ram
    __datos_size = SIZEOF(.datos);

    .codigo_kernel32 __KERNEL_32_VMA :
        AT (__KERNEL_32_LMA)
        { *(.kernel32); } > ram
    __codigo_kernel32_size = SIZEOF(.codigo_kernel32); 

    .task01_texto __TASK_01_TEXT_VMA :
    AT (__TASK_01_TEXT_LMA)
    {*(.functions_task01);
     ./bin/task01.elf(.note*);} > ram
    __codigo_task_01 = SIZEOF(.task01_texto);

    .task01_bss __TASK_01_BSS_VMA :
    AT (__TASK_01_BSS_LMA)
    {./bin/task01.elf(.bss);} > ram
    __bss_task_01 = SIZEOF(.task01_bss);

    .task01_data __TASK_01_DATA_VMA :
    AT (__TASK_01_DATA_LMA)
    {./bin/task01.elf(.data);} > ram
    __data_task_01 = SIZEOF(.task01_data);

    .task01_rodata __TASK_01_RODATA_VMA :
    AT (__TASK_01_RODATA_LMA)
    {./bin/task01.elf(.rodata);} > ram
    __rodata_task_01 = SIZEOF(.task01_rodata);

    .codigo_init16 __INIT_16_VMA :
        AT (__INIT_16_LMA)
        { *(.ROM_init); } > rom 

    .video __VGA_INIT_VMA :
        AT (__VGA_INIT_LMA )
        {*(.video);} > rom

    .codigo_init32 __INIT_32_VMA :
        AT (__INIT_32_LMA)
        { *(.start32); } > rom 

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