/*
linker básico
*/
ENTRY (reset)

    __EH_FRAME = 0x00060000; /*seccion para c y c++ exception handling*/
    __DATA_NO_INIT = 0x00050000; 
    __STACK_START_16 = 0x9000;  /*SS=0x9000*/
    __STACK_END_16 = 0x9FFF;
    
    /*__BOOT_SEG = 0xF0000;*/
    /*-----------------VMA-----------------*/
    /*Rutinas*/ 
    __FUNCTIONS_VMA         = 0x0010000; /*tengo los saltos referenciados a 0*/
    
    /*Kernel*/
    __KERNEL_32_VMA         = 0x00202000;
    
    /*Stack 32*/
    __STACK_START_32        = 0x2FFF8000;
    __STACK_END_32          = 0x2FFF8FFF;
    __STACK_SIZE_32 = ((__STACK_END_32 - __STACK_START_32) / 4); /*32b word*/
    
    /*Init ROM*/
    __INIT_16_VMA           = 0xFFFF0000;
    __INIT_32_VMA           = 0xFFFFF800;
    __FUNCTIONS_ROM_VMA     = 0xFFFFFC00;
    __SYS_TABLES_VMA        = 0xFFFFFD00; /*donde guardo la GDT*/
    
    /*Vector de Reset*/
    __RESET_VMA             = 0xFFFFFFF0;
    
    /*-----------------LMA-----------------*/
    __INIT_16_LMA           = 0xFFFF0000; 

    __FUNCTIONS_LMA         = 0xFFFF1000; /*se ensambla en otra zona*/
    __KERNEL_32_LMA         = 0xFFFF2000;

    __INIT_32_LMA           = 0xFFFFF800;    
    __FUNCTIONS_ROM_LMA     = 0xFFFFFC00;
    __SYS_TABLES_LMA        = 0xFFFFFD00;
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
    .codigo_kernel32 __KERNEL_32_VMA :
        AT (__KERNEL_32_LMA)
        { *(.kernel32); } > ram
    __codigo_kernel32_size = SIZEOF(.codigo_kernel32); 

    .functions __FUNCTIONS_VMA :
        AT (__FUNCTIONS_LMA)
        { *(.functions); } > ram
    __functions_size = SIZEOF(.functions);

    .codigo_init16 __INIT_16_VMA :
        AT (__INIT_16_LMA)
        { *(.ROM_init); } > rom 

    .codigo_init32 __INIT_32_VMA :
        AT (__INIT_32_LMA)
        { *(.start32); } > rom 

    .functions_rom __FUNCTIONS_ROM_VMA :
        AT (__FUNCTIONS_ROM_LMA)
        { *(.functions_rom);
          *(.note.gnu.property); } > rom

    .data __SYS_TABLES_VMA :
        AT (__SYS_TABLES_LMA)
        { *(.sys_tables*); } > rom 

    .codigo_reset __RESET_VMA :
        AT (__RESET_LMA)
        { *(.resetVector); } > rom 


    .fill_rom :
        { FILL(0x90);
          . = ORIGIN(rom) + LENGTH(rom)-1;      
          BYTE(0x90);
        } > rom

}