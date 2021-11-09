#include "../inc/driver_dummy.h"

volatile int colector_fin=1;

void handler_driver_sigusr2(int signal)
{
    colector_fin=0;
}



void colector_sensor(int* fd_pipe,char* shm_addr, int sem_set_id)
{
  mediciones data_s;


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

  int32_t* buffer_ac_x;
  int32_t* buffer_ac_y;
  int32_t* buffer_ac_z;
  int32_t* buffer_temp;
  int32_t* buffer_gy_x;
  int32_t* buffer_gy_y;
  int32_t* buffer_gy_z;


  buffer_ac_x=(int32_t*)malloc(ventana*sizeof(int32_t));
  buffer_ac_y=(int32_t*)malloc(ventana*sizeof(int32_t));
  buffer_ac_z=(int32_t*)malloc(ventana*sizeof(int32_t));
  buffer_temp=(int32_t*)malloc(ventana*sizeof(int32_t));
  buffer_gy_x=(int32_t*)malloc(ventana*sizeof(int32_t));
  buffer_gy_y=(int32_t*)malloc(ventana*sizeof(int32_t));
  buffer_gy_z=(int32_t*)malloc(ventana*sizeof(int32_t));

  for(i=0;i<ventana;i++)
  {
    buffer[i]=0;
    buffer_ac_x[i]=0;
    buffer_ac_y[i]=0;
    buffer_ac_z[i]=0;
    buffer_temp[i]=0;
    buffer_gy_x[i]=0;
    buffer_gy_y[i]=0;
    buffer_gy_z[i]=0;
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
//    realocacion(buffer,ventana);
   // rellenar(buffer,ventana);

  //  buffer_ac_x=realloc(buffer_ac_x,ventana*sizeof(int32_t));
    realocacion(buffer_ac_x,ventana);
    realocacion(buffer_ac_y,ventana);
    realocacion(buffer_ac_z,ventana);
    realocacion(buffer_temp,ventana);
    realocacion(buffer_gy_x,ventana);
    realocacion(buffer_gy_y,ventana);
    realocacion(buffer_gy_z,ventana);
    
    rellenar(buffer_ac_x,ventana);
    rellenar(buffer_ac_y,ventana);
    rellenar(buffer_ac_z,ventana);
    rellenar(buffer_temp,ventana);
    rellenar(buffer_gy_x,ventana);
    rellenar(buffer_gy_y,ventana);
    rellenar(buffer_gy_z,ventana);

    }
    muestra=rand()%100;
    //fread
    //------------------

    //me da 14 muestras

    //14 las dejo crudas
    data_s.raw_ac_x=rand()%100;
    data_s.raw_ac_y=rand()%100;
    data_s.raw_ac_z=rand()%100;
    data_s.raw_temp=rand()%100;
    data_s.raw_gy_x=rand()%100;
    data_s.raw_gy_y=rand()%100;
    data_s.raw_gy_z=rand()%100;

    //14 las filtro
    data_s.mva_ac_x = filtro(buffer_ac_x,ventana,data_s.raw_ac_x);
    data_s.mva_ac_y = filtro(buffer_ac_y,ventana,data_s.raw_ac_y);
    data_s.mva_ac_z = filtro(buffer_ac_z,ventana,data_s.raw_ac_z);
    data_s.mva_temp = filtro(buffer_temp,ventana,data_s.raw_temp);
    data_s.mva_gy_x = filtro(buffer_gy_x,ventana,data_s.raw_gy_x);
    data_s.mva_gy_y = filtro(buffer_gy_y,ventana,data_s.raw_gy_y);
    data_s.mva_gy_z = filtro(buffer_gy_z,ventana,data_s.raw_gy_z);
    

    //en la shmem escribo una estructura
    //----------------
    sem_lock(sem_set_id);
//    *shm_addr=muestra;
    memcpy(shm_addr,&data_s,sizeof(mediciones));
    sem_unlock(sem_set_id);
    filtro(buffer,ventana,muestra);
    kill(0,SIGUSR1);
    usleep(100000);
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
    vector=(int*)realloc(vector,elementos*sizeof(int32_t));
    if(vector == NULL)
    {
      printf("null pointer pa\n");
    }

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

