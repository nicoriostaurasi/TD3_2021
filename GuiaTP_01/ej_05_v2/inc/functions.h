#define ERROR_DEFECTO 0
#define EXITO 1
#define CANT_GDTS 3

typedef unsigned char byte;
typedef unsigned long dword;

extern long unsigned __SYS_TABLES_32_VMA;

byte __fast_memcpy_rom( dword*,dword *,dword);
byte __fast_memcpy( dword*,dword *,dword);
void __carga_GDT(dword,dword,dword,dword);
void __carga_IDT(dword,dword,dword,dword);