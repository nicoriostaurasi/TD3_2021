#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <sys/wait.h>
#include <fcntl.h>
#include <sys/sem.h>
#include "../inc/datos.h"

int crear_semaforo(key_t*,int,int,int);
int control_semaforo(int,int,int);

/**
 * \fn int crear_semaforo (key_t *LLAVE, int nsems, int ATRIBUTOS, int _8bits)
 * \brief Funcion que crea e inicializa uno o varios semaforos.
 * \details Esta funcion se encarga de crear e inicializar uno o varios semaforos (segun se asigne a nsems)
		 Verifica que no exista ya un semaforo, con esa key_t y se lo intenta reutilziar si se puede.
 * \param *LLAVE es un puntero a la variable que almacena el id del semaforo, dentro del programa que invoca
		a esta funcion.
 * \param nsems es el numero de semaforos que contendra el set a crear.
 * \param ATRIBUTOS son los atributos del mismo. 
 * \param _8bits parametros para completar el proceso de creacion de la llave.
 * \return int ante un exito, retorna el id del semaforo creado. Retorna -1 si no hubo exito con ERRNO
		indicando el error.
 * \author	Luciano Ferreyro
**/

int crear_semaforo (key_t *LLAVE,int nsems, int ATRIBUTOS, int _8bits)
	{
	int semid, e, ready, i;
	semun arg;
	struct semid_ds buf;
	struct sembuf sb;
	
	//Se crea la llave del proceso, para identificar que procesos pueden usar o no ese espacio reservado	
	if(((*LLAVE) = ftok("my_ftok_file.txt",_8bits))==-1)
		{
		perror("ftok");
		exit(1);	
		}	
	/*Obtengo el identificador de un semaforo*/
	semid = semget(*LLAVE, nsems, ATRIBUTOS);
	e = errno; 
	if(semid >= 0)	//Nos fijamos que se haya creado el identificador
		{
		sb.sem_op = 0;		//Lo inicializamos en 0 (cero)
		sb.sem_flg = 0;		//Las banderas en 0 (por lo general sera asi)
		arg.setval = 1;		
		for(sb.sem_num = 0; sb.sem_num < nsems; sb.sem_num++)
			{
			//En este paso, se setea sb.sem_otime
			if(semop(semid,&sb,1) == -1)	//Cuando retorna -1 es porque no pudo liberar el semaforo
				{							
				e = errno;					//Salvo el valor de ERRNO
				semctl(semid,0,IPC_RMID);	//Si existia lo remuevo del sistema, se debe volver a llamar: crear_semaforo
				errno = e;					//Lo recupero
				return -1;					//Regreso con -1 indicando que no se pudo crear el semaforo o alguno de los semaforos del set indicado
				}
			}		
		}
	else
		{
		if(errno == EEXIST)		//Si llegamos a aca es porque ya se habia tomado el semaforo, algun proceso ya lo tenia tomado.
			{
			ready = 0;
			semid = semget(*LLAVE,nsems,0);	//Obtenemos su identificador,colocando 0 donde irian los atributos
			if(semid < 0)
				{
				return semid;				//No se pudo, se retorna el ID obtenido, que en realidad vale -1
				}
											//Llegar a este punto quiere decir que se pudo obtener el ID del semaforo.
			arg.buf = &buf;					//semctl precisa que se le envia como parametro una union como la declarada, donde se guardaran los datos
											//solicitados, segun corresponda.
			for(i = 0; i< MAX_RETRIES && !ready; i++)
				{
				semctl(semid, nsems-1, IPC_STAT, arg);	//Con IPC_STAT obtenemos el estado del set de semaforos, y lo cargamos en buf.
				if(arg.buf->sem_otime!=0)
					{
					ready = 1;
					}
				else
					{
					sleep(1);
					}
				}
			if(!ready)
				{
				errno = ETIME;	//Seteamos a errno como un error por sem_otime
				return -1;
				}
			}
			else
			{
			return semid;		//Se retorna exitosamente el identificador del semaforo.
			}		
			
			
		}
	return semid;		//Se retorna exitosamente el identificador del semaforo.		
	}

/**
 * \fn int control_semaforo (int ID, int N_SEM)
 * \brief Funcion que bloquea o libera un semaforo de un determinado set.
 * \details Esta funcion se encarga de bloquear o liberar a un semaforo dentro de un determinado set de 
		 semaforos. Esta funcion es validad unicamente para 1 solo set de semaforos, y no para un array de 
		 struct sembuf - aunque esta funcion es facilmente modificable para cumplir con eso.
 * \param ID es el identificador del semaforo o set de semaforos que se desea bloquear.
 * \param N_SEM es el numero de semaforo que se quiere bloquear, dentro de un set de semaforos.
 * \param ACCION puede ser SEM_TAKE o SEM_FREE, segun se desee.
 * \return int Retorna -1 si no hubo exito, y retorna 1 si lo hubo
 * \author	Luciano Ferreyro
**/

int control_semaforo (int ID, int N_SEM, int ACCION)
	{
	struct sembuf BUF;	
	int ret;
		
	BUF.sem_num = N_SEM;	
	BUF.sem_op = ACCION;
	BUF.sem_flg = SEM_UNDO;
	
	ret = semop(ID,&BUF,1);
	if(ret == 0)
		{
		return 1;	//Se pudo realizar la accion con semop
		}
	else
		{
		return -1;	//No pudo realizarse la accion con semop
		}
	}
