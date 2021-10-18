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
#include <sys/shm.h>
#include <fcntl.h>
#include "../inc/datos.h"

char* crear_shmem(key_t*,int*,char*,int,int, int);
void destruir_shmem(int,char*);

/**
 * \fn void crear_shmem (key_t *LLAVE, int *ID, int TAM, char *ATTACH, int _8bits, int PERMISOS)
 * \brief Funcion que crear una shared memory.
 * \details Esta funcion se encarga de reservar, crear y asignar el espacio de memoria compartida.
 * \param *LLAVE puntero a una variable que contendra la key para identificar el proceso. 
 * \param *ID puntero a la variable que contendra el identificador al espacio de memoria reservado/memoria compartida.
 * \param TAM es el tamaño del espacio de memoria reservado.
 * \param *ATTACH es un puntero, ya que representa al dato que "attacheamos" al espacio reservado.
 * \param _8bits representa el valor que debemos agregar en ftok y que utiliza dicha funcion para generar
	   la clave. Se lo otorga como variable, ya que variando ese parametro generamos claves diferentes
	   para un mismo archivo .c.
 * \param PERMISOS son los permisos que poseera el espacio de memoria reservado.
 * \return void 
 * \author	Luciano Ferreyro
**/	

char* crear_shmem(key_t *LLAVE, int *ID, char* ftok_file, int TAM, int _8bits, int PERMISOS)
	{
	char *ATTACH;
	//Se crea la llave del proceso, para identificar que procesos pueden usar o no ese espacio reservado	
	if(((*LLAVE) = ftok(ftok_file,_8bits))==-1)
		{
		perror("ftok");
		exit(1);	
		}
	
	/*Creo la shared memory para los procesos. Obtengo el identificador de la posicion de memoria compartida para cada proceso*/	
	if(((*ID) = shmget((*LLAVE),TAM,PERMISOS))==-1)
		{
		perror("shmget");
		exit(1);	
		}
	
	/*Ahora attacheamos ese espacio compartido a un dato*/
	ATTACH = shmat((*ID),(void*)0,0);
	if (ATTACH == (char*)(-1))
		{
		perror("shmat");
		exit(1);
		}	
	
	return((void*)ATTACH);
	}

/**
 * \fn void destruir_shmem (int ID, char *ATTACH)
 * \brief Funcion que destruye una shared memory.
 * \details Esta funcion se encarga de deligar (detach) de un segmento de memoria compartida y destruir dicho
		 segmento (eliminarlo del sistema).
 * \param ID identificador del segmento de memoria a eliminar.
 * \param *ATTACH es un puntero, ya que representa al dato que desligaremos de la memoria compartida.
 * \return void 
 * \author	Luciano Ferreyro
**/

void destruir_shmem (int ID, char *ATTACH)
	{
	/*Primero desligo ATTACH del segmento*/	
	if(shmdt(ATTACH) == -1)
		{
		 if(errno!=EINVAL)
		    perror("shmdt");
	//	exit(1);
		}
	/*Elimino el segmento*/
	if(shmctl(ID,IPC_RMID,NULL) == -1)
		{
		 if(errno!=EINVAL)
		    perror("shmctl");
	//	exit(1);
		}
	}
