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
        *Teclado + ISR   0x0010-0000
        *Datos           0x0021-0000
        *Kernel          0x0020-2000
        *Stack           0x2FF8-0000
        *Init ROM        0xFFFF-0000
        *Reset Vector    0xFFFF-FFF0    
    
    */  
    /*-----------------VMA-----------------*/
    __SYS_TABLES_32_VMA     = 0x00000000; /*donde guardo la IDT32+GDT32*/
    

    /*Rutinas*/
    __FUNCTIONS_VMA         = 0x00010000; /*tengo los saltos referenciados a 0*/
    
    /*Teclado + ISR*/
    __TECLADO_ISR_VMA       = 0x00100000;

    /*Sección de memoria con datos*/
    __DATOS_VMA             = 0x00210000;
    __RING_BUFFER_INIT      = 0x00210000;
    __RING_BUFFER_END       = 0x0021000F;
    /*Kernel*/
    __KERNEL_32_VMA         = 0x00202000;
    
    /*Stack 32*/
    __STACK_START_32        = 0x2FFF8000;
    __STACK_END_32          = 0x2FFF8FFF;
    __STACK_SIZE_32 = ((__STACK_END_32 - __STACK_START_32) / 4); /*32b word*/
    
    /*Init ROM*/
    __INIT_16_VMA           = 0xFFFF0000;
    __INIT_32_VMA           = 0xFFFFF800;
    __FUNCTIONS_ROM_VMA     = 0xFFFFFA00;
    __SYS_TABLES_16_VMA     = 0xFFFFFE00; /*donde guardo la GDT*/
    
    /*Vector de Reset*/
    __RESET_VMA             = 0xFFFFFFF0;
    
    /*-----------------LMA-----------------*/
    __INIT_16_LMA           = 0xFFFF0000; 
   
    __KERNEL_32_LMA         = 0xFFFF1000;
    
    __SYS_TABLES_32_LMA     = 0xFFFF2000;
    __TECLADO_ISR_LMA       = 0xFFFF3000;
    __DATOS_LMA             = 0xFFFF4000;
    __FUNCTIONS_LMA         = 0xFFFF5000; /*se ensambla en otra zona*/


    __INIT_32_LMA           = 0xFFFFF800;    
    __FUNCTIONS_ROM_LMA     = 0xFFFFFA00;
    __SYS_TABLES_16_LMA     = 0xFFFFFE00;
    __RESET_LMA             = 0xFFFFFFF0;


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
    /* 
    .sys_tables_32 __SYS_TABLES_32_VMA :
        AT (__SYS_TABLES_32_LMA)
        { *(.sys_table_idt_32);
          *(.sys_table_gdt_32);} > ram 
    __sys_tables_size = SIZEOF(.sys_tables_32);
    */
    
    .teclados_isr __TECLADO_ISR_VMA :
        AT (__TECLADO_ISR_LMA)
        { *(.teclado_and_ISR)} > ram 
    __teclados_isr_size = SIZEOF(.teclados_isr);
    
    .functions __FUNCTIONS_VMA :
        AT (__FUNCTIONS_LMA)
        { *(.functions); 
          *(.note*);
          *(.rodata);
          *(.bss);
        } > ram
    __functions_size = SIZEOF(.functions);

    .datos __DATOS_VMA :
        AT (__DATOS_LMA)
        { *(.data); } > ram
    __datos_size = SIZEOF(.datos);

    .codigo_kernel32 __KERNEL_32_VMA :
        AT (__KERNEL_32_LMA)
        { *(.kernel32); } > ram
    __codigo_kernel32_size = SIZEOF(.codigo_kernel32); 

    .codigo_init16 __INIT_16_VMA :
        AT (__INIT_16_LMA)
        { *(.ROM_init); } > rom 

    .codigo_init32 __INIT_32_VMA :
        AT (__INIT_32_LMA)
        { *(.start32); } > rom 

    .functions_rom __FUNCTIONS_ROM_VMA :
        AT (__FUNCTIONS_ROM_LMA)
        { *(.functions_rom);
          *(.note.gnu.property);
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