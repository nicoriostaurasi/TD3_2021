

//Defines generales
#define PUERTO_TCP_COMU 23400
#define PUERTO_UDP_1 23401
#define PUERTO_UDP_2 23402
#define CONEX_MAX 5				
#define TAM_MAX_DAT 1024

//Para los handshake, path y mensajes generales							
#define PATH_PROC1 "/usr/bin/td3/proceso_1"
#define COMM_PROC1 "proceso_1"
#define PATH_PROC2 "/usr/bin/td3/proceso_2"								
#define COMM_PROC2 "proceso_2"
#define KEEP_ALIVE "keep_alive"
#define KEEP 1
#define STOP_THREAD 2
#define MSJ_SERVER "Conexion TCP nueva aceptada"
#define MSJ_SEND_AK "AKN"	//Aknowledge
#define MSJ_SEND_OK "OK"
#define MSJ_CLIENT "Conectado con el Server"
#define MSJ_REF_SER "Conexion con Client TCP rechazada, maxima cantidad de conexiones"
#define MSJ_REF_CLI "Conexion con Server TCP rechazada, maxima cantidad de conexiones"
#define LIM_TIMEOUT 30		//Timeout de 30 segundos

//Para la shared memory, control de los semaforos y control de peticiones
#define ATRIB_SHDMEM 0666 //(rw-rw-rw-)		
#define MAX_RETRIES 10
#define SEM_TAKE -1						
#define SEM_FREE 1
#define PROC_1 "Proceso 1"
#define PROC_2 "Proceso 2"

typedef struct
	{
	int dato_1;
	int dato_2;	
	float dato_3;
	char string[10];
	} dato_generico;

typedef union
	{
	int setval;				//Usado solamente para SETVAL
	struct semid_ds *buf;	//Usado solamente para IPC_STAT e IPC_SET
	ushort *array;			//Usado solamente para GETALL y SETALL
	struct semino *_buf;	//Buffer usado solamente para IPC_INFO (solo en Linux)	
	} semun;

typedef struct
	{
	struct sockaddr_in INFO_CLIENTE;
	int socketfd;
	int client;
	int id_sem_1;
	int id_sem_2;			
	} arg_thread;
	
