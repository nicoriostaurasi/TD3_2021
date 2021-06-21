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
        *Direccion Lineal:              *Direccion Física:
        *Sys_tables      0x0000-0000    *Sys_tables      0x0000-0000    
        *Tablas de Pag.  0x0001-0000    *Tablas de Pag.  0x0001-0000    
        *Rutinas         0x0005-0000    *Rutinas         0x0005-0000    
        *RAM VIDEO       0x000B-8000    *RAM VIDEO       0x00E8-0000  
        *Teclado + ISR   0x0010-0000    *Teclado + ISR   0x0010-0000    
        *Datos           0x0020-0000    *Datos           0x0120-0000
        *Digitos         0x0021-0000    *Digitos         0x0121-0000    
        *Kernel          0x0022-0000    *Kernel          0x0122-0000

        *Tarea 1 TEXT    0x0031-0000    *Tarea 1 TEXT    0x0131-0000    
        *Tarea 1 BSS     0x0032-0000    *Tarea 1 BSS     0x0132-0000    
        *Tarea 1 DATA    0x0033-0000    *Tarea 1 DATA    0x0133-0000    
        *Tarea 1 RODATA  0x0034-0000    *Tarea 1 RODATA  0x0134-0000
        
        *Tarea 2 TEXT    0x0041-1000    *Tarea 2 TEXT    0x0141-0000    
        *Tarea 2 BSS     0x0042-0000    *Tarea 2 BSS     0x0142-0000    
        *Tarea 2 DATA    0x0043-0000    *Tarea 2 DATA    0x0143-0000    
        *Tarea 2 RODATA  0x0044-0000    *Tarea 2 RODATA  0x0144-0000
        
        *Tarea 3 TEXT    0x0051-0000    *Tarea 3 TEXT    0x0151-0000    
        *Tarea 3 BSS     0x0052-0000    *Tarea 3 BSS     0x0152-0000    
        *Tarea 3 DATA    0x0053-0000    *Tarea 3 DATA    0x0153-0000    
        *Tarea 3 RODATA  0x0054-0000    *Tarea 3 RODATA  0x0154-0000
        
        *Tarea 4 TEXT    0x0061-0000    *Tarea 4 TEXT    0x0161-0000    
        *Tarea 4 BSS     0x0062-0000    *Tarea 4 BSS     0x0162-0000    
        *Tarea 4 DATA    0x0063-0000    *Tarea 4 DATA    0x0163-0000    
        *Tarea 4 RODATA  0x0064-0000    *Tarea 4 RODATA  0x0164-0000
        
        *Stack Sistema   0x1FFF-8000    *Stack Sistema   0x1FFF-8000    
        *Stack Tarea 1   0x1FFF-F000    *Stack Tarea 1   0x0078-F000    
        *Stack Tarea 2   0x3000-0000    *Stack Tarea 2   0x2FFF-1000    
        *Stack Tarea 3   0x3001-0000    *Stack Tarea 3   0x2FFF-2000    
        *Stack Tarea 4   0x3002-0000    *Stack Tarea 4   0x2FFF-3000    

        *Init ROM        0xFFFF-0000    *Init ROM        0xFFFF-0000    
        *Reset Vector    0xFFFF-FFF0    *Reset Vector    0xFFFF-FFF0        
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

    /*-------------VMA-Fisica-------------*/
    /*Donde guardo la IDT32+GDT32*/
    __SYS_TABLES_32_VMA_PHI     = 0x00000000; 

    /*Sección de la DTP Tarea 1*/
    __PAGE_TABLES_VMA_TASK01_PHI       = 0x0000C000;
    /*Sección de la DTP Tarea 2*/
    __PAGE_TABLES_VMA_TASK02_PHI       = 0x0000D000;
    /*Sección de la DTP Tarea 3*/
    __PAGE_TABLES_VMA_TASK03_PHI       = 0x0000E000;
    /*Sección de la DTP Tarea 4*/
    __PAGE_TABLES_VMA_TASK04_PHI       = 0x0000F000;
    
    /*Sección de las Tablas de paginacion*/
    __PAGE_TABLES_VMA_PHI       = 0x00010000;
    
    /*Rutinas*/
    __FUNCTIONS_VMA_PHI         = 0x00050000; /*tengo los saltos referenciados a 0*/

    /*Sección de RAM de video*/
    __VIDEO_VGA_PHI             = 0x000B8000;

    /*Teclado + ISR*/
    __TECLADO_ISR_VMA_PHI       = 0x00100000;

    /*TSS*/
    __TSS_TASK_01_PHI           = 0x001F0000;
    __TSS_TASK_02_PHI           = 0x001F1000;
    __FPU_TASK_02_PHI           = 0x001F1800;
    __TSS_TASK_03_PHI           = 0x001F2000;
    __FPU_TASK_03_PHI           = 0x001F2800;
    __TSS_TASK_04_PHI           = 0x001F3000;


    /*Sección de memoria con datos*/
    __DATOS_VMA_PHI             = 0x00200000;
    __RING_BUFFER_INIT_PHI      = 0x00200000;
    __RING_BUFFER_END_PHI       = 0x0020000F;
    __DATOS_TIMER_VMA_PHI       = 0x00200050;
    __DATOS_PROMEDIO_VMA_PHI    = 0x00200060;
    __DATOS_SCH_VMA_PHI         = 0x00200070;
    __DATOS_CONVERSION_VMA_PHI  = 0x00200090;

    /*Tabla de Dígitos*/
    __DIGITOS_VMA_PHI           = 0x00210000;

    /*Kernel*/
    __KERNEL_32_VMA_PHI         = 0x00220000;

    /*Task 1*/
    __TASK_01_VMA_PHI           = 0x00310000;

    __TASK_01_TEXT_VMA_PHI      = 0x00310000;
    __TASK_01_BSS_VMA_PHI       = 0x00320000;
    __TASK_01_DATA_VMA_PHI      = 0x00330000;
    __TASK_01_RODATA_VMA_PHI    = 0x00340000;

    /*Task 2*/
    __TASK_02_TEXT_VMA_PHI      = 0x00411000;
    __TASK_02_BSS_VMA_PHI       = 0x00420000;
    __TASK_02_DATA_VMA_PHI      = 0x00430000;
    __TASK_02_RODATA_VMA_PHI    = 0x00440000;

    /*Task 3*/
    __TASK_03_TEXT_VMA_PHI      = 0x00510000;
    __TASK_03_BSS_VMA_PHI       = 0x00520000;
    __TASK_03_DATA_VMA_PHI      = 0x00530000;
    __TASK_03_RODATA_VMA_PHI    = 0x00540000;

    /*Task 4*/
    __TASK_04_TEXT_VMA_PHI      = 0x00610000;
    __TASK_04_BSS_VMA_PHI       = 0x00620000;
    __TASK_04_DATA_VMA_PHI      = 0x00630000;
    __TASK_04_RODATA_VMA_PHI    = 0x00640000;


    /*Memoria Dinamica de Tarea 1*/
    __MEMORIA_FISICA_DINAMICA   = 0x0A000000;
    /*Stack 32*/
    __STACK_START_32            = 0x1FFF8000;
    __STACK_END_32              = 0x1FFF8FFF;

    __STACK_SIZE_32 = ((__STACK_END_32 - __STACK_START_32) / 4); /*32b word*/
    
    __TASK_01_STACK_START_PHI   = 0x2FFF0000;
    __TASK_01_STACK_END_PHI     = 0x2FFF0FFF;
    __TASK_01_STACK_SIZE        = ((__TASK_01_STACK_END_PHI - __TASK_01_STACK_START_PHI) / 4); 

    __TASK_02_STACK_START_PHI   = 0x2FFF1000;
    __TASK_02_STACK_END_PHI     = 0x2FFF1FFF;
    __TASK_02_STACK_SIZE        = ((__TASK_02_STACK_END_PHI - __TASK_02_STACK_START_PHI) / 4); 

    __TASK_03_STACK_START_PHI   = 0x2FFF2000;
    __TASK_03_STACK_END_PHI     = 0x2FFF2FFF;
    __TASK_03_STACK_SIZE        = ((__TASK_03_STACK_END_PHI - __TASK_03_STACK_START_PHI) / 4); 

    __TASK_04_STACK_START_PHI   = 0x2FFF3000;
    __TASK_04_STACK_END_PHI     = 0x2FFF3FFF;
    __TASK_04_STACK_SIZE        = ((__TASK_04_STACK_END_PHI - __TASK_04_STACK_START_PHI) / 4); 

    /*Init ROM*/ 
    __INIT_16_VMA_PHI           = __INIT_16_LMA;
    __VGA_INIT_VMA_PHI          = __VGA_INIT_LMA; /*donde se encuentran las rutinas de VGA*/
    __INIT_32_VMA_PHI           = __INIT_32_LMA;
    __FUNCTIONS_ROM_VMA_PHI     = __FUNCTIONS_ROM_LMA;
    __SYS_TABLES_16_VMA_PHI     = __SYS_TABLES_16_LMA; /*donde guardo la GDT*/
    
    /*Vector de Reset*/
    __RESET_VMA_PHI             = 0xFFFFFFF0;
    
    /*-------------VMA-Lineal-------------*/
    /*Donde guardo la IDT32+GDT32*/
    __SYS_TABLES_32_VMA_LIN     = 0x00000000; 


    /*Sección de la DTP Tarea 1*/
    __PAGE_TABLES_VMA_TASK01_LIN = 0x0000C000;
    /*Sección de la DTP Tarea 2*/
    __PAGE_TABLES_VMA_TASK02_LIN = 0x0000D000;
    /*Sección de la DTP Tarea 3*/
    __PAGE_TABLES_VMA_TASK03_LIN = 0x0000E000;
    /*Sección de la DTP Tarea 4*/
    __PAGE_TABLES_VMA_TASK04_LIN = 0x0000F000;
 
    /*Sección de las Tablas de paginacion*/
    __PAGE_TABLES_VMA_LIN       = 0x00010000;
    
    /*Rutinas*/
    __FUNCTIONS_VMA_LIN         = 0x00050000; /*tengo los saltos referenciados a 0*/

    /*Sección de RAM de video*/
    __VIDEO_VGA_LIN             = 0x00E80000;

    /*Teclado + ISR*/
    __TECLADO_ISR_VMA_LIN       = 0x00100000;

    /*TSS*/
    __TSS_TASK_01_LIN           = 0x011F0000;
    __TSS_TASK_02_LIN           = 0x011F1000;
    __FPU_TASK_02_LIN           = 0x001F1800;
    __TSS_TASK_03_LIN           = 0x011F2000;
    __FPU_TASK_03_LIN           = 0x001F2800;
    __TSS_TASK_04_LIN           = 0x011F3000;

    /*Sección de memoria con datos*/
    __DATOS_VMA_LIN             = 0x01200000;
    __RING_BUFFER_INIT_LIN      = 0x01200000;
    __RING_BUFFER_END_LIN       = 0x0120000F;
    __DATOS_TIMER_VMA_LIN       = 0x01200050;
    __DATOS_PROMEDIO_VMA_LIN    = 0x01200060;
    __DATOS_SCH_VMA_LIN         = 0x01200070;
    __DATOS_CONVERSION_VMA_LIN  = 0x01200090;

    /*Tabla de Dígitos*/
    __DIGITOS_VMA_LIN           = 0x01210000;

    /*Kernel*/
    __KERNEL_32_VMA_LIN         = 0x01220000;

    /*Task 1*/
    __TASK_01_VMA_LIN           = 0x01310000;

    __TASK_01_TEXT_VMA_LIN      = 0x01310000;
    __TASK_01_BSS_VMA_LIN       = 0x01320000;
    __TASK_01_DATA_VMA_LIN      = 0x01330000;
    __TASK_01_RODATA_VMA_LIN    = 0x01340000;

    /*Task 2*/
    __TASK_02_TEXT_VMA_LIN      = 0x01410000;
    __TASK_02_BSS_VMA_LIN       = 0x01420000;
    __TASK_02_DATA_VMA_LIN      = 0x01430000;
    __TASK_02_RODATA_VMA_LIN    = 0x01440000;

    /*Task 3*/
    __TASK_03_TEXT_VMA_LIN      = 0x01510000;
    __TASK_03_BSS_VMA_LIN       = 0x01520000;
    __TASK_03_DATA_VMA_LIN      = 0x01530000;
    __TASK_03_RODATA_VMA_LIN    = 0x01540000;

    /*Task 4*/
    __TASK_04_TEXT_VMA_LIN      = 0x01610000;
    __TASK_04_BSS_VMA_LIN       = 0x01620000;
    __TASK_04_DATA_VMA_LIN      = 0x01630000;
    __TASK_04_RODATA_VMA_LIN    = 0x01640000;

    /*Stacks*/
    __TASK_01_STACK_START_LIN   = 0x0078F000;
    __TASK_01_STACK_END_LIN     = 0x0078FFFF;

    __TASK_02_STACK_START_LIN   = 0x00790000;
    __TASK_02_STACK_END_LIN     = 0x00790FFF;

    __TASK_03_STACK_START_LIN   = 0x00791000;
    __TASK_03_STACK_END_LIN     = 0x00791FFF;

    __TASK_04_STACK_START_LIN   = 0x00792000;
    __TASK_04_STACK_END_LIN     = 0x00792FFF;

    /*Init ROM*/ 
    __INIT_16_VMA_LIN           = __INIT_16_LMA;
    __VGA_INIT_VMA_LIN          = __VGA_INIT_LMA; /*donde se encuentran las rutinas de VGA*/
    __INIT_32_VMA_LIN           = __INIT_32_LMA;
    __FUNCTIONS_ROM_VMA_LIN     = __FUNCTIONS_ROM_LMA;
    __SYS_TABLES_16_VMA_LIN     = __SYS_TABLES_16_LMA; /*donde guardo la GDT*/
    
    /*Vector de Reset*/
    __RESET_VMA_LIN             = 0xFFFFFFF0;


    /* Parametros de Paginacion*/
    /*Directorio*/
    __PDT_Sistema               = 0x00000000;
    /*Contiene a las paginas desde el inicio hasta Stack*/
    __PDT_Stack_Sistema         = __STACK_START_32;
    /*Contiene a las paginas del Stack*/

    /*Paginas*/
    __PT_SYS_TABLES             = __SYS_TABLES_32_VMA_PHI;
    __PT_TABLAS_PAGINACION      = __PAGE_TABLES_VMA_PHI;
    __PT_FUNCIONES              = __FUNCTIONS_VMA_PHI;
    __PT_VIDEO                  = __VIDEO_VGA_PHI;
    __PT_TECLADO_ISR            = __TECLADO_ISR_VMA_PHI; 
    __PT_DATOS                  = __DATOS_VMA_PHI;
    __PT_DIGITOS                = __DIGITOS_VMA_PHI; 
    __PT_KERNEL                 = __KERNEL_32_VMA_PHI;
    __PT_TASK_01                = __TASK_01_VMA_PHI;
    __PT_TASK_01_TEXT           = __TASK_01_TEXT_VMA_PHI;      
    __PT_TASK_01_BSS            = __TASK_01_BSS_VMA_PHI;     
    __PT_TASK_01_DATA           = __TASK_01_DATA_VMA_PHI;      
    __PT_TASK_01_RODATA         = __TASK_01_RODATA_VMA_PHI;    
    
    __PT_TASK_02_TEXT           = __TASK_02_TEXT_VMA_PHI;      
    __PT_TASK_02_BSS            = __TASK_02_BSS_VMA_PHI;     
    __PT_TASK_02_DATA           = __TASK_02_DATA_VMA_PHI;      
    __PT_TASK_02_RODATA         = __TASK_02_RODATA_VMA_PHI;    

    __PT_TASK_03_TEXT           = __TASK_03_TEXT_VMA_PHI;      
    __PT_TASK_03_BSS            = __TASK_03_BSS_VMA_PHI;     
    __PT_TASK_03_DATA           = __TASK_03_DATA_VMA_PHI;      
    __PT_TASK_03_RODATA         = __TASK_03_RODATA_VMA_PHI;    

    __PT_TASK_04_TEXT           = __TASK_04_TEXT_VMA_PHI;      
    __PT_TASK_04_BSS            = __TASK_04_BSS_VMA_PHI;     
    __PT_TASK_04_DATA           = __TASK_04_DATA_VMA_PHI;      
    __PT_TASK_04_RODATA         = __TASK_04_RODATA_VMA_PHI;    

    __PT_STACK_SISTEMA          = __STACK_START_32;
    __PT_TASK_01_STACK          = __TASK_01_STACK_START_PHI;
    __PT_TASK_02_STACK          = __TASK_02_STACK_START_PHI;
    __PT_TASK_03_STACK          = __TASK_03_STACK_START_PHI;
    __PT_TASK_04_STACK          = __TASK_04_STACK_START_PHI;

    __PT_TSS_T1                 = __TSS_TASK_01_PHI;
    __PT_TSS_T2                 = __TSS_TASK_02_PHI;
    __PT_TSS_T3                 = __TSS_TASK_03_PHI;
    __PT_TSS_T4                 = __TSS_TASK_04_PHI;


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
    .functions __FUNCTIONS_VMA_LIN :
        AT (__FUNCTIONS_LMA)
        { *(.functions);
          ./bin/functions.elf(.note*);
          ./bin/functions.elf(.text);
          ./bin/functions.elf(.bss);
          ./bin/functions.elf(.data);
          ./bin/functions.elf(.rodata);
          
          ./bin/timer.elf(.note*);
          ./bin/timer.elf(.text);
          ./bin/timer.elf(.bss);
          ./bin/timer.elf(.data);
          ./bin/timer.elf(.rodata);
        }> ram
    __functions_size = SIZEOF(.functions);

    __TECLADO_ISR_LMA = LOADADDR(.functions) + SIZEOF(.functions); 

    .teclados_isr __TECLADO_ISR_VMA_LIN :
        AT (__TECLADO_ISR_LMA)
        { *(.teclado_and_ISR);
          *(.utils_scheduler);
          ./bin/scheduler.elf(.text)} > ram 
    __teclados_isr_size = SIZEOF(.teclados_isr);

    __DATOS_LMA = LOADADDR(.teclados_isr) + SIZEOF(.teclados_isr);

    .datos __DATOS_VMA_LIN :
        AT (__DATOS_LMA)
        { ./bin/main.elf(.data); } > ram
    __datos_size = SIZEOF(.datos);

    __KERNEL_32_LMA = LOADADDR(.datos) + SIZEOF(.datos);

    .codigo_kernel32 __KERNEL_32_VMA_LIN :
        AT (__KERNEL_32_LMA)
        { *(.kernel32); } > ram
    __codigo_kernel32_size = SIZEOF(.codigo_kernel32); 

    __TASK_01_TEXT_LMA = LOADADDR(.codigo_kernel32) + SIZEOF(.codigo_kernel32);

    /*-----TAREA 1-----*/
    .task01_texto __TASK_01_TEXT_VMA_LIN :
    AT (__TASK_01_TEXT_LMA)
    {*(.functions_task01);
     ./bin/task01.elf(.text);
     ./bin/task01.elf(.note*);} > ram
    __codigo_task_01 = SIZEOF(.task01_texto);

    __TASK_01_BSS_LMA = LOADADDR(.task01_texto) + SIZEOF(.task01_texto);

    .task01_bss __TASK_01_BSS_VMA_LIN :
    AT (__TASK_01_BSS_LMA)
    {./bin/task01.elf(.bss);} > ram
    __bss_task_01 = SIZEOF(.task01_bss);

    __TASK_01_DATA_LMA = LOADADDR(.task01_bss) + SIZEOF(.task01_bss);

    .task01_data __TASK_01_DATA_VMA_LIN :
    AT (__TASK_01_DATA_LMA)
    {./bin/task01.elf(.data);} > ram
    __data_task_01 = SIZEOF(.task01_data);

    __TASK_01_RODATA_LMA = LOADADDR(.task01_data) + SIZEOF(.task01_data);  

    .task01_rodata __TASK_01_RODATA_VMA_LIN :
    AT (__TASK_01_RODATA_LMA)
    {./bin/task01.elf(.rodata);} > ram
    __rodata_task_01 = SIZEOF(.task01_rodata);
    

    __TASK_02_TEXT_LMA = LOADADDR(.task01_rodata) + SIZEOF(.task01_rodata);

    /*-----TAREA 2-----*/
    .task02_texto __TASK_02_TEXT_VMA_LIN :
    AT (__TASK_02_TEXT_LMA)
    {*(.functions_task02);
       ./bin/task02.elf(.text);
       ./bin/task02.elf(.note*);} > ram
    __codigo_task_02 = SIZEOF(.task02_texto);

    __TASK_02_BSS_LMA = LOADADDR(.task02_texto) + SIZEOF(.task02_texto);

    .task02_bss __TASK_02_BSS_VMA_LIN :
    AT (__TASK_02_BSS_LMA)
    {./bin/task02.elf(.bss);} > ram
    __bss_task_02 = SIZEOF(.task02_bss);

    __TASK_02_DATA_LMA = LOADADDR(.task02_bss) + SIZEOF(.task02_bss);

    .task02_data __TASK_02_DATA_VMA_LIN :
    AT (__TASK_02_DATA_LMA)
    {./bin/task02.elf(.data);} > ram
    __data_task_02 = SIZEOF(.task02_data);

    __TASK_02_RODATA_LMA = LOADADDR(.task02_data) + SIZEOF(.task02_data);  

    .task02_rodata __TASK_02_RODATA_VMA_LIN :
    AT (__TASK_02_RODATA_LMA)
    {./bin/task02.elf(.rodata);} > ram
    __rodata_task_02 = SIZEOF(.task02_rodata);

    __TASK_03_TEXT_LMA = LOADADDR(.task02_rodata) + SIZEOF(.task02_rodata);

    /*-----TAREA 3-----*/

    .task03_texto __TASK_03_TEXT_VMA_LIN :
    AT (__TASK_03_TEXT_LMA)
    {*(.functions_task03);
     ./bin/task03.elf(.note.gnu.property);
     ./bin/task03.elf(.note.gnu.note);} > ram
    __codigo_task_03 = SIZEOF(.task03_texto);

    __TASK_03_BSS_LMA = LOADADDR(.task03_texto) + SIZEOF(.task03_texto);

    .task03_bss __TASK_03_BSS_VMA_LIN :
    AT (__TASK_03_BSS_LMA)
    {./bin/task03.elf(.bss);} > ram
    __bss_task_03 = SIZEOF(.task03_bss);

    __TASK_03_DATA_LMA = LOADADDR(.task03_bss) + SIZEOF(.task03_bss);

    .task03_data __TASK_03_DATA_VMA_LIN :
    AT (__TASK_03_DATA_LMA)
    {./bin/task03.elf(.data);} > ram
    __data_task_03 = SIZEOF(.task03_data);

    __TASK_03_RODATA_LMA = LOADADDR(.task03_data) + SIZEOF(.task03_data);  

    .task03_rodata __TASK_03_RODATA_VMA_LIN :
    AT (__TASK_03_RODATA_LMA)
    {./bin/task03.elf(.rodata);} > ram
    __rodata_task_03 = SIZEOF(.task03_rodata);

    __TASK_04_TEXT_LMA = LOADADDR(.task03_rodata) + SIZEOF(.task03_rodata);

    /*-----TAREA 4-----*/
    .task04_texto __TASK_04_TEXT_VMA_LIN :
    AT (__TASK_04_TEXT_LMA)
    {*(.functions_task04);
     ./bin/task04.elf(.text);
     ./bin/task04.elf(.note*);} > ram
    __codigo_task_04 = SIZEOF(.task04_texto);

    __TASK_04_BSS_LMA = LOADADDR(.task04_texto) + SIZEOF(.task04_texto);

    .task04_bss __TASK_04_BSS_VMA_LIN :
    AT (__TASK_04_BSS_LMA)
    {./bin/task04.elf(.bss);} > ram
    __bss_task_04 = SIZEOF(.task04_bss);

    __TASK_04_DATA_LMA = LOADADDR(.task04_bss) + SIZEOF(.task04_bss);

    .task04_data __TASK_04_DATA_VMA_LIN :
    AT (__TASK_04_DATA_LMA)
    {./bin/task04.elf(.data);} > ram
    __data_task_04 = SIZEOF(.task04_data);

    __TASK_04_RODATA_LMA = LOADADDR(.task04_data) + SIZEOF(.task04_data);  

    .task04_rodata __TASK_04_RODATA_VMA_LIN :
    AT (__TASK_04_RODATA_LMA)
    {./bin/task04.elf(.rodata);} > ram
    __rodata_task_04 = SIZEOF(.task04_rodata);


    /*-----ROM-----*/
    .codigo_init16 __INIT_16_VMA_LIN :
        AT (__INIT_16_LMA)
        { *(.ROM_init); } > rom 

    __VGA_INIT_LMA = LOADADDR(.codigo_init16) + SIZEOF(.codigo_init16);

    .video __VGA_INIT_VMA_LIN :
        AT (__VGA_INIT_LMA )
        {*(.video);} > rom

    __INIT_32_LMA = LOADADDR(.video) + SIZEOF(.video);

    .codigo_init32 __INIT_32_VMA_LIN :
        AT (__INIT_32_LMA)
        { *(.start32); } > rom 

    __FUNCTIONS_ROM_LMA = LOADADDR(.codigo_init32) + SIZEOF(.codigo_init32);

    .functions_rom __FUNCTIONS_ROM_VMA_LIN :
        AT (__FUNCTIONS_ROM_LMA)
        { *(.functions_rom);
          ./bin/functions_rom.elf(.note*);
          ./bin/functions_rom.elf(.text);
          ./bin/functions_rom.elf(.data);
          ./bin/functions_rom.elf(.bss);
          ./bin/functions_rom.elf(.rodata);
          *(.utils32) } > rom

    .sys_tables_16 __SYS_TABLES_16_VMA_LIN :
        AT (__SYS_TABLES_16_LMA)
        { *(.sys_table_gdt_16);} > rom 

    .codigo_reset __RESET_VMA_LIN :
        AT (__RESET_LMA)
        { *(.resetVector); } > rom 

    .fill_rom :
        { FILL(0x90);
          . = ORIGIN(rom) + LENGTH(rom)-1;      
          BYTE(0x90);
        } > rom

}