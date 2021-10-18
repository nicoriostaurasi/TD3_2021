#include <netdb.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <time.h>

#define MAX 80
#define PORT 7000
#define SA struct sockaddr

void dormir(void);

void func(int sockfd)
{
  int puerto_udp;
  char buff[MAX];
  int pid;
  read(sockfd, buff, 11*sizeof(char));
  buff[11]='\0';
  if(strcmp("bienvenido!",buff)==0)
  {
      printf("[CLIENTE]: From Server : %s\n", buff);
  }
  write(sockfd,"send_port!", 10*sizeof(char));
  read(sockfd, &puerto_udp, sizeof(int));
  printf("[CLIENTE]: El puerto UDP a comunicarme es: %d\n",puerto_udp);
  write(sockfd,"puerto_ok!", 11*sizeof(char));
  //-------------------
  //ahora debo levantar un cliente UDP para enviar un keep_alive cada 200mS
  //por otro lado debo escuchar el streaming de datos por parte del server

  struct sockaddr_in server_udp;
  int socket_udp;

  socket_udp=socket(AF_INET, SOCK_DGRAM, 0);
  if(socket_udp<0)
  {
      printf("[CLIENTE]: Error al crear socket UDP\n");
      exit(1);
  }

  server_udp.sin_family = AF_INET;   /*dominio de Internet*/
  server_udp.sin_addr.s_addr=inet_addr("127.0.0.1"); 
  server_udp.sin_port = htons(puerto_udp);

  printf("[CLIENTE]: Envio 1er paquete UDP\n");
  sendto(socket_udp,"ACK!",4*sizeof(char),0,&server_udp,sizeof(struct sockaddr_in));
  int n;
  int length = sizeof(struct sockaddr_in);
  struct sockaddr_in from_server;
//  n = recvfrom(socket_udp,buff,MAX,0,&from_server, &length);
//  buff[n]='\0';  /* para poder imprimirlo con prinft*/   
//printf("Recibido en el cliente: %s\0", buff);/*cerramos el socket*/

  pid=fork();
  
  
  if(pid==0)
  {
    while(1)
    {
    //printf("[CLIENTE]: keep alive!\n");
    sendto(socket_udp,"ACK!",4*sizeof(char),0,&server_udp,sizeof(struct sockaddr_in));
    usleep(500000);
    } 
   }
  else
  {
    int muestra;
    while(1)
    {
    recvfrom(socket_udp,&muestra,sizeof(int),0,&from_server, &length);
    printf("[CLIENTE] Medicion: %d\n",muestra);
    }
  }



  close(sockfd);
}
   
void dormir()
{
  usleep(200000);
}

int main()
{
    int sockfd, connfd;
    struct sockaddr_in servaddr, cli;
   
    // socket create and varification
    sockfd = socket(AF_INET, SOCK_STREAM, 0);
    if (sockfd == -1) {
        printf("socket creation failed...\n");
        exit(0);
    }
    else
        printf("Socket successfully created..\n");
    bzero(&servaddr, sizeof(servaddr));
   
    // assign IP, PORT
    servaddr.sin_family = AF_INET;
    servaddr.sin_addr.s_addr = inet_addr("127.0.0.1");
    servaddr.sin_port = htons(PORT);
   
    // connect the client socket to server socket
    if (connect(sockfd, (SA*)&servaddr, sizeof(servaddr)) != 0) {
        printf("connection with the server failed...\n");
        exit(0);
    }
    else
        printf("connected to the server..\n");
   
    // function for chat
    func(sockfd);
   
    // close the socket
    close(sockfd);
}