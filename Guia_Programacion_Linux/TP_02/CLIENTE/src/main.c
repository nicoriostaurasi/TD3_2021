#include <netdb.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>

#include <sys/signal.h>
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
  read(sockfd, buff, 2*sizeof(char));
  buff[2]='\0';
  if(strcmp("OK",buff)==0)
  {
      printf("[CLIENTE]: From Server : %s\n", buff);
  }
  write(sockfd,"AKN", 3*sizeof(char));

  pid=fork();
  
  
  if(pid==0)
  {
    while(1)
    {
    write(sockfd,"KA", 2*sizeof(char));
    usleep(500000);
    
    } 
  }
  else
  {
    int muestra;
    while(1)
    {
    if(read(sockfd, &muestra, sizeof(int))<=0)
    {
      kill(pid,SIGKILL);
      break;
      close(sockfd);
    }
    printf("[CLIENTE] Medicion: %d\n",muestra);
    }
  }

  wait(NULL);

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