#include <string.h>
#include <fcntl.h>
#include <string.h>
#include <stdlib.h>
#include <errno.h>
#include <stdio.h>
#include <netinet/in.h>
#include <resolv.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <sys/shm.h>	 /* semaphore functions and structs.     */
#include <sys/sem.h>	 /* shared memory functions and structs. */
#include <arpa/inet.h>
#include <unistd.h>
#include <pthread.h>
#include <string.h>
#include <sys/ipc.h>     

#include "driver_handler.h"
#include "file_handler.h"
#include "filtrado.h"
#include "servidor.h"

/*Puerto*/
#define PORT       7000

/*Longitud del buffer*/
#define BUFFERSIZE 512

#define CLIENTE_DEF 100
#define CONEC_DEF   20
#define VENTANA_DEF 2
#define FREC_DEF 1

#define SEM_ID    250	 /* ID del semaforo */

typedef struct
{
  int muestra;
  int promedio;
}data;

typedef struct mediciones
{   
    int16_t raw_ac_x;
    int16_t raw_ac_y;
    int16_t raw_ac_z;
    int16_t raw_temp;
    int16_t raw_gy_x;
    int16_t raw_gy_y;
    int16_t raw_gy_z;
    
    int16_t mva_ac_x;
    int16_t mva_ac_y;
    int16_t mva_ac_z;
    int16_t mva_temp;
    int16_t mva_gy_x;
    int16_t mva_gy_y;
    int16_t mva_gy_z;
}mediciones;

typedef union smun{
    int val;
    struct semid_ds *buff;
    unsigned short *array;
}smun;