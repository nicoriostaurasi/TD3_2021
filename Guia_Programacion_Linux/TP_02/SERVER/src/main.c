/**
 * @file main.c
 * @author Nicolas Rios Taurasi (nicoriostaurasi@frba.utn.edu.ar)
 * @brief Ejemplo de servidor concurrente con comandos
 * @version 0.1
 * @date 21-09-2021
 * 
 * @copyright Copyright (c) 2021
 * 
 */

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
#include <arpa/inet.h>
#include <unistd.h>
#include <pthread.h>
#include <string.h>

/** Puerto  */
#define PORT       7000

/** Número máximo de hijos */
#define MAX_CHILDS 3

/** Longitud del buffer  */
#define BUFFERSIZE 512

int AtiendeCliente(int socket, struct sockaddr_in addr);
int DemasiadosClientes(int socket, struct sockaddr_in addr);
void error(int code, char *err);

int main(int argv, char** argc)
{    
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
    /* select() se carga el valor de tv */
    tv.tv_sec = 0;
    tv.tv_usec = 500000;    /* Tiempo de espera */
    int sel;
    sel=select(socket_host+1, &rfds, NULL, NULL, &tv);
    if (sel)
      {
        if((socket_client = accept( socket_host, (struct sockaddr*)&client_addr, &size_addr))!= -1)
        {
            printf("\nSe ha conectado %s por su puerto %d\n", inet_ntoa(client_addr.sin_addr), client_addr.sin_port);
            switch ( childpid=fork() )
            {
                case -1:  /* Error */
                error(4, "No se puede crear el proceso hijo");
                break;
            
                case 0:   /* Somos proceso hijo */
                if (childcount<MAX_CHILDS)
                exitcode=AtiendeCliente(socket_client, client_addr);
                else
                exitcode=DemasiadosClientes(socket_client, client_addr);

                exit(exitcode); /* Código de salida */
                
                default:  /* Somos proceso padre */
                childcount++; /* Acabamos de tener un hijo */
                close(socket_client); /* Nuestro hijo se las apaña con el cliente que
                         entró, para nosotros ya no existe. */
                break;
            }
        }
        else
        fprintf(stderr, "ERROR AL ACEPTAR LA CONEXIÓN\n");
      }

    /* Miramos si se ha cerrado algún hijo últimamente */
    childpid=waitpid(0, &pidstatus, WNOHANG);
    if (childpid>0)
        {
        childcount--;   /* Se acaba de morir un hijo */

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

int AtiendeCliente(int socket, struct sockaddr_in addr)
{
    char buffer[BUFFERSIZE];
    char aux[BUFFERSIZE];
    int bytecount;
    int fin=0;

    while (!fin)
    {
        memset(buffer, 0, BUFFERSIZE);
    
        if((bytecount = recv(socket, buffer, BUFFERSIZE, 0))== -1)
          error(5, "No puedo recibir información");

        /* Evaluamos los comandos */
        /* Comando EXIT - Cierra la conexión actual */
        if (strncmp(buffer, "EXIT", 4)==0)
        {
            memset(buffer, 0, BUFFERSIZE);
            sprintf(buffer, "Hasta luego. Vuelve pronto %s\n", inet_ntoa(addr.sin_addr));
            printf("El cliente %s, puerto %d. Se desconecto.. bye!\n",inet_ntoa(addr.sin_addr),addr.sin_port);
            fin=1;
        }
        /* Un comando no válido envia un eco */
        else
        {    
            sprintf(aux, "ECHO: %s\n", buffer);
            strcpy(buffer, aux);
        }

        if((bytecount = send(socket, buffer, strlen(buffer), 0))== -1)
        error(6, "No puedo enviar información");
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