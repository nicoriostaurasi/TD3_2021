#define ERROR_DEFECTO 0
#define EXITO 1
#define CANT_GDTS 3
//https://stanislavs.org/helppc/make_codes.html        
#define TECLA_ENTER 0x9C
#define TECLA_1     0x82
#define TECLA_2     0x83
#define TECLA_3     0x84
#define TECLA_4     0x85
#define TECLA_5     0x86
#define TECLA_6     0x87
#define TECLA_7     0x88
#define TECLA_8     0x89
#define TECLA_9     0x8A
#define TECLA_0     0x8B
#define LONG_BUFFER 16


extern long unsigned __SYS_TABLES_32_VMA;
extern long unsigned __DATOS_VMA;


typedef long unsigned direccion;
typedef unsigned char byte;
typedef unsigned long dword;

//https://embeddedartistry.com/blog/2017/05/17/creating-a-circular-buffer-in-c-and-c/
typedef struct ring_buffer
{

    byte* cabeza;        //puntero a cabeza
    byte* cola;          //puntero a la cola
    byte buffer[LONG_BUFFER];            //buffer
    byte* inicio;        //puntero al inicio    //byte dato_dummy5;
    byte* fin;           //puntero al fin
    byte progreso;       //cantidad de datos ingresados
    byte longitud;       //longitud en elementos
    byte longitud_en_bytes;
    byte tam_elemento;   //tamaño de cada elemento
}ring_buffer;

byte __fast_memcpy( dword*,dword *,dword);
void __carga_GDT(dword,dword,dword,dword);
void __carga_IDT(dword,dword,dword,dword);
void __chequeo_tecla(byte);
void __ring_buffer_init(ring_buffer*);
void __ring_buffer_clear(ring_buffer*);
void ring_buffer_push(ring_buffer*,byte);