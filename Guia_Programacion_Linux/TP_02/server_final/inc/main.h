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
    uint16_t raw_ac_x;
    uint16_t raw_ac_y;
    uint16_t raw_ac_z;
    int16_t  raw_temp;
    uint16_t raw_gy_x;
    uint16_t raw_gy_y;
    uint16_t raw_gy_z;

    uint16_t mva_ac_x;
    uint16_t mva_ac_y;
    uint16_t mva_ac_z;
    int16_t  mva_temp;
    uint16_t mva_gy_x;
    uint16_t mva_gy_y;
    uint16_t mva_gy_z;
}mediciones;
