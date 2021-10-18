/******************************************************************* 
*   Cliente de eco remoto sobre UDP: 
* 
*        cliente dir_ip_maquina puerto 
* 
*   manda mensaje a maquina, quien responde un solo mensaje 
*   que el cliente imprime. 
********************************************************************/

#include <sys/types.h>
#include <netdb.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#define TAMANO  256
/* tamano del buffer de recepcion */

void error_fatal(char *);   
/* Imprimer un mensaje de error y sale del programa */

int main(int argc, char *argv[])
{
    int sock; /* descriptor del socket del cliente */
    int length, n;  
    struct sockaddr_in server, from; /* direcciones del socket del servidor y cliente */
    struct hostent *hp;      /* estructura para el nombre del servidor (ver gethostbyname) */
    char buffer[TAMANO];  /* buffer de recepcion y envio del mensaje */
    if (argc != 3) 
    { 
        fprintf(stderr,"Uso: servidor puerto\n");                    
        exit(1);
    }
    /* (1) creacion del socket UDP del cliente */   
    sock= socket(AF_INET, SOCK_DGRAM, 0);   
    if (sock < 0) error_fatal("socket");

    server.sin_family = AF_INET;   /*dominio de Internet*/
    /* (2) averigua la direccion IP a partir del nombre del servidor*/   
    hp = gethostbyname(argv[1]);  
    
    if (hp==0) error_fatal("Host desconocido");
    /* (3) copia la IP resuelta anteriormente en la direccion del socket del servidor */   
    memcpy((char *)&server.sin_addr,(char *)hp->h_addr,hp->h_length);
    /* (4) copia el puerto destino en la direccion del socket del servidor */   
    server.sin_port = htons(atoi(argv[2]));     
    length=sizeof(struct sockaddr_in);     
    printf("Por favor, introduce el mensaje: ");   
    memset(buffer,0,TAMANO);   /*limpio el buffer*/   
    fgets(buffer,TAMANO-1,stdin);
    /* (5) envia al socket del servidor el mensaje almacenado en el buffer*/   
    n=sendto(sock,buffer,strlen(buffer),0,&server,length);
    if (n < 0) error_fatal("Sendto");
    /* (6) lee del socket el mensaje de respuesta del servidor*/   
    n = recvfrom(sock,buffer,TAMANO,0,&from, &length);
    
    if (n < 0) error_fatal("recvfrom");
    buffer[n]='\0';  /* para poder imprimirlo con prinft*/   
    printf("Recibido en el cliente: %s\0", buffer);/*cerramos el socket*/
    if(close(sock) < 0) error_fatal("close");
}
    
void error_fatal(char *msg)
{    
    perror(msg);    
    exit(1);
}


