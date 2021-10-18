/**
 * @file main.c
 * @author Nicolas Rios Taurasi (nicoriostaurasi@frba.utn.edu.ar)
 * @brief Ejemplo de servidor concurrente con comandos y clientes configurados por txt
 * @version 0.1
 * @date 21-09-2021
 * 
 * @copyright Copyright (c) 2021
 * 
 */
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

/** Puerto  */
#define PORT       7000

/** Longitud del buffer  */
#define BUFFERSIZE 512

#define CLIENTE_DEF 2
#define CONEC_DEF   2
#define CANTIDAD_BUFFER 2
#define FREC_DEF 1

int AtiendeCliente(int socket, struct sockaddr_in addr,char* shm_addr);
int DemasiadosClientes(int socket, struct sockaddr_in addr);
int Lector_CFG(int* pipe_lector,int* driver_pipe);
void error(int code, char *err);
void colector_sensor(int* driver_pipe,char* shm_addr);

int main(int argv, char** argc)
{    
    int clientes_maximos=1;
    int socket_host;
    struct sockaddr_in client_addr;
    struct sockaddr_in my_addr;
    struct timeval tv;      /* Para el timeout del accept */
    socklen_t size_addr = 0;
    int socket_client;
    fd_set rfds;        /* Conjunto de descriptores a vigilar */
    int childcount=0;
    int exitcode;

    int childpid;
    int pidstatus;

    int activated=1;
    int PID_lector;
    int fd_pipe[2]; 

    int cantidad_pipe;
    int buff_rx[CANTIDAD_BUFFER];

    int PID_driver;
    int driver_pipe[2];
 
    int shm_id;	      	       /* ID of the shared memory segment.   */
    char* shm_addr; 	       /* address of shared memory segment.  */

    /* allocate a shared memory segment with size of 2048 bytes. */
    shm_id = shmget("memoria", 512, IPC_CREAT | IPC_EXCL | 0600);
    if (shm_id == -1) {
        perror("main: shmget: ");
        exit(1);
    }

    /* attach the shared memory segment to our process's address space. */
    shm_addr = shmat(shm_id, NULL, 0);
    if (!shm_addr) { /* operation failed. */
        perror("main: shmat: ");
        exit(1);
    }

    *shm_addr=0;

    if(pipe(fd_pipe)==-1)
      error(1, "No puedo crearse el pipe");

    if(pipe(driver_pipe)==-1)
      error(1, "No puedo crearse el pipe");


    PID_lector=fork();

    if(PID_lector==0)
    {
        Lector_CFG(fd_pipe,driver_pipe);
    }

    PID_driver=fork();

    if(PID_driver==0)
    {
      colector_sensor(driver_pipe,shm_addr);
    }


    socket_host = socket(AF_INET, SOCK_STREAM, 0);
    if(socket_host == -1)
      error(1, "No puedo inicializar el socket");
   
    my_addr.sin_family = AF_INET ;
    my_addr.sin_port = htons(PORT);
    my_addr.sin_addr.s_addr = INADDR_ANY ;

   
    if( bind( socket_host, (struct sockaddr*)&my_addr, sizeof(my_addr)) == -1 )
      error(2, "El puerto está en uso"); /* Error al hacer el bind() */

    if(listen( socket_host, 10) == -1 )
      error(3, "No puedo escuchar en el puerto especificado");

    size_addr = sizeof(struct sockaddr_in);
    
    printf("Se inicia el loop infinito\n");
    while(activated)
    {
    /* select() se carga el valor de rfds */
    FD_ZERO(&rfds);
    FD_SET(socket_host, &rfds);
    tv.tv_sec = 0;
    FD_SET(fd_pipe[0], &rfds);

    /* select() se carga el valor de tv */
    tv.tv_usec = 500000;    /* Tiempo de espera */

    if (select(socket_host+1, &rfds, NULL, NULL, &tv))
      {
        if(FD_ISSET(fd_pipe[0],&rfds))
        {
        read(fd_pipe[0],&cantidad_pipe,sizeof(int));
        read(fd_pipe[0],buff_rx,cantidad_pipe*sizeof(int));
        clientes_maximos=buff_rx[1];
         printf("Clientes Maximos: %d\n",buff_rx[1]);
        }

        if(FD_ISSET(socket_host,&rfds))
        {
                if((socket_client = accept( socket_host, (struct sockaddr*)&client_addr, &size_addr))!= -1)
                {
                    switch ( childpid=fork() )
                    {
                          case -1:  /* Error */
                          error(4, "No se puede crear el proceso hijo");
                          break;

                          case 0:   /* Somos proceso hijo */
                          if (childcount<clientes_maximos)
                          {
                          printf("\nSe ha conectado %s por su puerto %d\n", inet_ntoa(client_addr.sin_addr), client_addr.sin_port);
                          exitcode=AtiendeCliente(socket_client, client_addr,shm_addr);
                          }
                          else
                          {
                          printf("\nSe ha intentado conectar %s por su puerto %d, pero no hay lugar para otro cliente"
                          "\n", inet_ntoa(client_addr.sin_addr), client_addr.sin_port);
                          exitcode=DemasiadosClientes(socket_client, client_addr);
                          }
                          exit(exitcode); /* Código de salida */

                          default:  /* Somos proceso padre */
                          printf("Linux dame un hijo por favor: \n");
                          printf("Aqui tiene señor %d, cliente: %s puerto: %d. Hijo N°:%d\n",childpid,inet_ntoa(client_addr.sin_addr), client_addr.sin_port,childcount);
                          childcount++; /* Acabamos de tener un hijo */
                          close(socket_client); /* Nuestro hijo se las apaña con el cliente que
                                   entró, para nosotros ya no existe. */
                          break;
                    }
                }
              else
              {
                  fprintf(stderr, "ERROR AL ACEPTAR LA CONEXIÓN\n");
              }
        }

      }

    /* Miramos si se ha cerrado algún hijo últimamente */
    childpid=waitpid(0, &pidstatus, WNOHANG);
    if (childpid>0)
        {
        childcount--;   /* Se acaba de morir un hijo */
        printf("Se desconecto un cliente PID:%d \n",childpid);
        /* Muchas veces nos dará 0 si no se ha muerto ningún hijo, o -1 si no tenemos hijos
         con errno=10 (No child process). Así nos quitamos esos mensajes*/

        if (WIFEXITED(pidstatus))
          {

        /* Tal vez querremos mirar algo cuando se ha cerrado un hijo correctamente */
        /*
        if (WEXITSTATUS(pidstatus)==99)
          {
            printf("\nSe ha pedido el cierre del programa\n");
            activated=0;
          }
        */
          }
        }
    }
    close(socket_host);
    return 0;
}

    
int DemasiadosClientes(int socket, struct sockaddr_in addr)
{
    char buffer[BUFFERSIZE];  
    int bytecount;

    memset(buffer, 0, BUFFERSIZE);
   
    sprintf(buffer, "Demasiados clientes conectados. Por favor, espere unos minutos\n");

    if((bytecount = send(socket, buffer, strlen(buffer), 0))== -1)
      error(6, "No puedo enviar información");
   
    close(socket);

    return 0;
}

int AtiendeCliente(int socket, struct sockaddr_in addr,char* shm_addr)
{
    char buffer[BUFFERSIZE];
    char aux[BUFFERSIZE];
    int bytecount;
    int fin=0;
    int muestra;
    char buff[3];
    while (!fin)
    {
        memset(buffer, 0, BUFFERSIZE);

        if(recv(socket, buffer, BUFFERSIZE, 0)== 0)
        {
          printf("Cliente desconectado\n");
          fin=1;
        }

        /* Evaluamos los comandos */
        /* Comando EXIT - Cierra la conexión actual */
        /* Comando send_data - Establece un streaming de datos */

        if(strncmp(buffer,"send_data",9)==0)
        {
            muestra=*shm_addr;


            buff[1]=muestra%10 + 48;
            muestra=muestra/10;
            buff[0]=muestra%10 + 48;
            buff[2]='\0';
            if(send(socket,buff,2*sizeof(char),0)==-1)
            error(6, "No puedo enviar información");
        }
        
        else if (strncmp(buffer, "EXIT", 4)==0)
        {
            memset(buffer, 0, BUFFERSIZE);
            sprintf(buffer, "Hasta luego. Vuelve pronto %s\n", inet_ntoa(addr.sin_addr));
            printf("El cliente %s, puerto %d. Se desconecto.. bye!\n",inet_ntoa(addr.sin_addr),addr.sin_port);
            fin=1;
        }
                
    }
    close(socket);
    return 0;
}

void error(int code, char *err)
{
  char *msg=(char*)malloc(strlen(err)+14);
  sprintf(msg, "Error %d: %s\n", code, err);
  fprintf(stderr, msg);
  exit(1);
}

int Lector_CFG(int* fd_pipe, int* dver_pipe)
{
  int flag_escritura=0;
  int cantidad_buff_hijo;
  FILE* fp_cfg;
  int buff_tx[CANTIDAD_BUFFER];
  int conexiones_ant,clientes_ant,frec_ant;
  int conexiones_now,clientes_now,frec_now;
  int flag_escritura_driver=0;
  conexiones_ant=CONEC_DEF;
  clientes_ant=CLIENTE_DEF;
  frec_ant=FREC_DEF;
  
  buff_tx[0]=CONEC_DEF;
  buff_tx[1]=CLIENTE_DEF;
  cantidad_buff_hijo=CANTIDAD_BUFFER;

  while(1)
  {
    fp_cfg=fopen("cfg.txt","r");
    if(fp_cfg==NULL)
    {
      error(1,"No se puede abrir el archivo de configuración\n");
    }

    fscanf(fp_cfg,"conexiones %d\n",&conexiones_now);
    
    if(conexiones_now<=0)
    {
      printf("Error en el archivo de configuracion campo: Conexiones\n");
      conexiones_now=1;
    }

    fscanf(fp_cfg,"clientes %d\n",&clientes_now);
    
    if(clientes_now<=0)
    {
        printf("Error en el archivo de configuracion campo: Clientes\n");
        clientes_now=1;
    }

    fscanf(fp_cfg,"frecuencia %d\n",&frec_now);

    if(frec_now<=0)
    {
        printf("Error en el archivo de configuracion campo: Frecuencia\n");
        frec_now=1;
    }


    if(conexiones_now != conexiones_ant)
    {      
      if(conexiones_now>=0)
      {
      conexiones_ant=conexiones_now;
      flag_escritura=1;
      buff_tx[0]=conexiones_now;
      }
    }

    if(clientes_now != clientes_ant)
    {
      if(clientes_now>=0)
      {
        clientes_ant=clientes_now;
        flag_escritura=1;
        buff_tx[1]=clientes_now;
      }
    }
        
    if(frec_now != frec_ant)
    {
      if(frec_now>=0)
      {
        frec_ant=frec_now;
        flag_escritura_driver=1;
      }
    }

    if(flag_escritura==1)
    {
      flag_escritura=0;
      write(fd_pipe[1],&cantidad_buff_hijo,sizeof(int));
      write(fd_pipe[1],buff_tx,cantidad_buff_hijo*sizeof(int));
    }        

    if(flag_escritura_driver==1)
    {
      flag_escritura_driver=0;
      write(dver_pipe[1],&frec_now,sizeof(int));
    }        


    usleep(500000);
    fclose(fp_cfg);
  }
  
  return 0;
}

void colector_sensor(int* fd_pipe,char* shm_addr)
{
  int muestra;
  struct timeval tv;      
  fd_set rfds; 
  srand(time(NULL));
  int delay_time=0;
  while(1)
  {
    FD_ZERO(&rfds);
    FD_SET(fd_pipe[0], &rfds);
    tv.tv_sec = 0;
    tv.tv_usec = 0;
  
    if (select(fd_pipe[0]+1, &rfds, NULL, NULL, &tv))
    {
    read(fd_pipe[0],&delay_time,sizeof(int));
    printf("Tiempo de muestra: %d\n",delay_time);
    }
    muestra=rand()%100;
    *shm_addr=muestra;

    printf("muestra %d\n",*shm_addr);
    usleep(200000);
    //aca escribo en el shmem
  }
  return 0;
}