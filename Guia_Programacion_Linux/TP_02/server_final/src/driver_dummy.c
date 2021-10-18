#include "../inc/driver_dummy.h"

volatile int colector_fin=1;

void handler_driver_sigusr2(int signal)
{
    colector_fin=0;
}



void colector_sensor(int* fd_pipe,char* shm_addr, int sem_set_id)
{
  int ventana=VENTANA_DEF;
  int i=0;

  struct sigaction muerte;
  muerte.sa_handler=handler_driver_sigusr2;
  muerte.sa_flags=0;
  sigemptyset(&muerte.sa_mask);
  sigaction(SIGUSR2,&muerte,NULL);

  signal(SIGUSR1,SIG_IGN);

  int muestra;

  struct timeval tv;      
  fd_set rfds; 

  srand(time(NULL));

  int* buffer;
  buffer=(int*)malloc(ventana*sizeof(int));

  for(i=0;i<ventana;i++)
  {
    buffer[i]=0;
  }

  while(colector_fin)
  {
    FD_ZERO(&rfds);
    FD_SET(fd_pipe[0], &rfds);
    tv.tv_sec = 0;
    tv.tv_usec = 0;  
    if (select(fd_pipe[0]+1, &rfds, NULL, NULL, &tv))
    {
    read(fd_pipe[0],&ventana,sizeof(int));
    printf("[SERVER]: Actualizada ventana del filtro %d\n",ventana);
    realocacion(buffer,ventana);
    rellenar(buffer,ventana);
    }
    muestra=rand()%100;
    sem_lock(sem_set_id);
    *shm_addr=muestra;
    sem_unlock(sem_set_id);
    filtro(buffer,ventana,muestra);
    kill(0,SIGUSR1);
    usleep(200000);
  }
  free(buffer);
  return 0;
}

void rellenar(int* buffer,int largo)
{
  int i;
  for(i=0;i<largo;i++)
  {
    buffer[i]=buffer[0];
  }
}

void realocacion(int* vector,int elementos)
{
    vector=(int*)realloc(vector,elementos*sizeof(int));
}

int filtro(int* buffer,int largo, int muestra)
{
  int aux=0;
  int i;

  for(i=0;i<(largo-1);i++)
  {
  buffer[largo-(i+1)]=buffer[largo-(i+1)-1];
  }

  buffer[0]=muestra;

  for(i=0;i<largo;i++)
  {
    aux=aux+buffer[i];
  }
  aux=aux/largo;  
  return aux;
}

void sem_lock(int sem_set_id)
{
    struct sembuf sem_op;
    sem_op.sem_num = 0;
    sem_op.sem_op = -1;
    sem_op.sem_flg = 0;
    semop(sem_set_id, &sem_op, 1);
}


void sem_unlock(int sem_set_id)
{
    struct sembuf sem_op;
    sem_op.sem_num = 0;
    sem_op.sem_op = 1;  
    sem_op.sem_flg = 0;
    semop(sem_set_id, &sem_op, 1);
}

