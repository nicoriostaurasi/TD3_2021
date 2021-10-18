#include <sys/types.h>
#include <netdb.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#define TAMANO 256

void error_fatal(char *msg)
{    
    perror(msg);    
    exit(1);
}

int main(int argc, char *argv[])
{
    int sock, length, fromlen, n;
    struct sockaddr_in server;
    struct sockaddr_in from;
    char buffer[TAMANO];
    /* (1) creacion del socket del servidor*/

    sock=socket(AF_INET, SOCK_DGRAM, 0);
    
    if (sock < 0) error_fatal("Creando el socket");   
    length = sizeof(server);   
    memset(&server,0,length);  /*limpio la direccion del socket del servidor*/
    /* (2) vinculo la direccion IP y puerto local al socket creado anteriormente */   
    server.sin_family=AF_INET;   
    server.sin_addr.s_addr=INADDR_ANY;   


    srand(time(NULL));

//    server.sin_port=htons(rand());

    server.sin_port=htons(5242);

    if (bind(sock,(struct sockaddr *)&server,length)<0)        
    {    
    //error_fatal("binding");   
    printf("puerto tomado\n");
    }
    fromlen = sizeof(struct sockaddr_in);
    
    /* (3) bucle principal. Pongo a recibir y responder mensajes a traves del socket*/
    printf("puerto bindeado %d\n",(int) ntohs(server.sin_port));
    

        n = recvfrom(sock,buffer,TAMANO,0,(struct sockaddr *)&from,&fromlen);
        printf("puerto cliente %d\n",(int) ntohs(from.sin_port));
        if (n < 0) error_fatal("recvfrom");/*datagrama recibido*/   
        buffer[n]='\0';  /* para poder imprimirlo con prinft*/   
        printf("Recibido en el servidor: %s", buffer);/*enviar respuesta*/       
        n = sendto(sock,"Recibi tu mensaje\n",18,0,(struct sockaddr *)&from,fromlen);
        
        if (n  < 0) error_fatal("sendto");   

    close(sock);    
}


