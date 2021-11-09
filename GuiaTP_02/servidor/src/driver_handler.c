/**
 * @file driver_handler.c
 * @author Nicolas Rios Taurasi (nicoriostaurasi@frba.utn.edu.ar)
 * @brief Este archivo contiene las funciones que realizan el manejo del p device
 * @version 0.1
 * @date 02-11-2021
 * 
 * @copyright Copyright (c) 2021
 * 
 */

#include "../inc/main.h"

volatile int colector_fin=1;

void handler_driver_sigusr2(int signal)
{
    colector_fin=0;
}

/**
 * @brief Proceso principal colecta los datos y hace el filtrado y compartido a los demas procesos
 * 
 * @param fd_pipe 
 * @param shm_addr 
 * @param sem_set_id 
 */
void colector_sensor(int* fd_pipe,char* shm_addr, int sem_set_id)
{
  //Vector de datos
  char vector_data[238];
  //Variables de datos
  float raw_accel_xout, raw_accel_yout, raw_accel_zout, raw_gyro_xout, raw_gyro_yout, raw_gyro_zout, raw_temp_out;
  float mva_accel_xout, mva_accel_yout, mva_accel_zout, mva_gyro_xout, mva_gyro_yout, mva_gyro_zout, mva_temp_out;
  //Ventana de Filtro
  int ventana=VENTANA_DEF;
  //Variable para el for
  int i=0;
  //Struct para la shmem
  mediciones data_s;
  //Buffers para los vectores
  int32_t buffer_ac_x[250];
  int32_t buffer_ac_y[250];
  int32_t buffer_ac_z[250];
  int32_t buffer_temp[250];
  int32_t buffer_gy_x[250];
  int32_t buffer_gy_y[250];
  int32_t buffer_gy_z[250];
  
  //Auxiliares para el select
  struct timeval tv;      
  fd_set rfds; 
  //file* del /dev/
  int fp_driver;
  //Buffer para leer del driver
  uint8_t* buff_driver;

  //handler para recargar el handler
  struct sigaction muerte;
  muerte.sa_handler=handler_driver_sigusr2;
  muerte.sa_flags=0;
  sigemptyset(&muerte.sa_mask);
  sigaction(SIGUSR2,&muerte,NULL);
  //Ignoro la señal de sigusr1
  signal(SIGUSR1,SIG_IGN);

  //Vacio la memoria del buffer
  for(i=0;i<ventana;i++)
  {
    buffer_ac_x[i]=0;
    buffer_ac_y[i]=0;
    buffer_ac_z[i]=0;
    buffer_temp[i]=0;
    buffer_gy_x[i]=0;
    buffer_gy_y[i]=0;
    buffer_gy_z[i]=0;
  }

  //Abro el driver
  fp_driver=open("/dev/NRT_td3_i2c_dev",O_RDWR);

  if(fp_driver<0)
  {
    printf("[SERVER]: Error al abrir el device\n");
    exit(1);  
  }

  //Pido memoria para los datos del sensor
  buff_driver=malloc(14*sizeof(uint8_t));

  if(buff_driver == NULL)
  {
    printf("[SERVER]: Error al asignar memoria dinamica\n");
    exit(1);
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

      rellenar(buffer_ac_x,ventana);
      rellenar(buffer_ac_y,ventana);
      rellenar(buffer_ac_z,ventana);
      rellenar(buffer_temp,ventana);
      rellenar(buffer_gy_x,ventana);
      rellenar(buffer_gy_y,ventana);
      rellenar(buffer_gy_z,ventana);
    }

    usleep(200000);
    read(fp_driver,buff_driver,14);

    //14 las dejo directas
    data_s.raw_ac_x=(0xFF&buff_driver[0])<<8  | (0xFF&buff_driver[1]);
    data_s.raw_ac_y=(0xFF&buff_driver[2])<<8 | (0xFF&buff_driver[3]);
    data_s.raw_ac_z=(0xFF&buff_driver[4])<<8 | (0xFF&buff_driver[5]);
    data_s.raw_temp=(0xFF&buff_driver[6])<<8 | (0xFF&buff_driver[7]);
    data_s.raw_gy_x=(0xFF&buff_driver[8])<<8 | (0xFF&buff_driver[9]);
    data_s.raw_gy_y=(0xFF&buff_driver[10])<<8 | (0xFF&buff_driver[11]);
    data_s.raw_gy_z=(0xFF&buff_driver[12])<<8 | (0xFF&buff_driver[13]);

    //14 las filtro
    data_s.mva_ac_x = filtro(buffer_ac_x,ventana,data_s.raw_ac_x);
    data_s.mva_ac_y = filtro(buffer_ac_y,ventana,data_s.raw_ac_y);
    data_s.mva_ac_z = filtro(buffer_ac_z,ventana,data_s.raw_ac_z);
    data_s.mva_temp = filtro(buffer_temp,ventana,data_s.raw_temp);
    data_s.mva_gy_x = filtro(buffer_gy_x,ventana,data_s.raw_gy_x);
    data_s.mva_gy_y = filtro(buffer_gy_y,ventana,data_s.raw_gy_y);
    data_s.mva_gy_z = filtro(buffer_gy_z,ventana,data_s.raw_gy_z);
    
    raw_accel_xout=(float)data_s.raw_ac_x * ARES_2G; 
    raw_accel_yout=(float)data_s.raw_ac_y * ARES_2G; 
    raw_accel_zout=(float)data_s.raw_ac_z * ARES_2G; 
    raw_gyro_xout =(float)data_s.raw_gy_x * GYR_250; 
    raw_gyro_yout =(float)data_s.raw_gy_y * GYR_250; 
    raw_gyro_zout =(float)data_s.raw_gy_z * GYR_250; 
    raw_temp_out  =((float)data_s.raw_temp)/340+36.53;

    mva_accel_xout=(float)data_s.mva_ac_x * ARES_2G; 
    mva_accel_yout=(float)data_s.mva_ac_y * ARES_2G;
    mva_accel_zout=(float)data_s.mva_ac_z * ARES_2G;
    mva_gyro_xout =(float)data_s.mva_gy_x * GYR_250; 
    mva_gyro_yout =(float)data_s.mva_gy_y * GYR_250; 
    mva_gyro_zout =(float)data_s.mva_gy_z * GYR_250; 
    mva_temp_out  =((float)data_s.mva_temp)/340+36.53;

    sprintf(vector_data,"%.5f\n%.5f\n%.5f\n%.5f\n%.5f\n%.5f\n%.5f\n%.5f\n%.5f\n%.5f\n%.5f\n%.5f\n%.5f\n%.5f\n",
    raw_accel_xout, raw_accel_yout, raw_accel_zout, raw_gyro_xout, raw_gyro_yout, raw_gyro_zout, raw_temp_out,
    mva_accel_xout, mva_accel_yout, mva_accel_zout, mva_gyro_xout, mva_gyro_yout, mva_gyro_zout, mva_temp_out);

    //en la shmem escribo el string
    sem_lock(sem_set_id);
    memcpy(shm_addr,vector_data,sizeof(vector_data));
    sem_unlock(sem_set_id);
    //Aviso a los atiende clientes
    kill(0,SIGUSR1);
  }
  close(fp_driver);
  close(fd_pipe[0]);
}

/**
 * @brief Rellena el buffer de medicion con la 1er muestra
 * 
 * @param buffer 
 * @param largo 
 */
void rellenar(int* buffer,int largo)
{
  int i;
  for(i=0;i<largo;i++)
  {
    buffer[i]=buffer[0];
  }
}

/**
 * @brief Redimensiona el vector de datos
 * 
 * @param vector 
 * @param elementos 
 */
void realocacion(int* vector,int elementos)
{
    vector=(int*)realloc(vector,elementos*sizeof(int32_t));
    if(vector == NULL)
    {
      printf("[SERVER]: Error al asignar memoria dinámica\n");
      exit(1);
    }
}


/**
 * @brief Bloquea el semaforo
 * 
 * @param sem_set_id 
 */
void sem_lock(int sem_set_id)
{
    struct sembuf sem_op;
    sem_op.sem_num = 0;
    sem_op.sem_op = -1;
    sem_op.sem_flg = 0;
    semop(sem_set_id, &sem_op, 1);
}

/**
 * @brief Libera el semaforo
 * 
 * @param sem_set_id 
 */
void sem_unlock(int sem_set_id)
{
    struct sembuf sem_op;
    sem_op.sem_num = 0;
    sem_op.sem_op = 1;  
    sem_op.sem_flg = 0;
    semop(sem_set_id, &sem_op, 1);
}

