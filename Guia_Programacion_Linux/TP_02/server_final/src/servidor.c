#include "../inc/servidor.h"

volatile int flag_lectura = 0;
volatile int fin=0;


void handler_cliente_sigusr1(int signal)
{
    flag_lectura=0;
}

void handler_cliente_sigusr2(int signal)
{
    fin=1;
}

void handler_sigalarm(int signal)
{
    fin=1;
}

int AtiendeCliente(int socket_tcp, struct sockaddr_in addr,char* shm_addr, int sem_set_id)
{
    struct sigaction alarma;
    alarma.sa_handler=handler_sigalarm;
    alarma.sa_flags=0;
    sigemptyset(&alarma.sa_mask);
    sigaction(SIGALRM,&alarma,NULL);

    struct sigaction lectura;
    lectura.sa_handler=handler_cliente_sigusr1;
    lectura.sa_flags=0;
    sigemptyset(&lectura.sa_mask);
    sigaction(SIGUSR1,&lectura,NULL);

    int socket_udp;
    struct sockaddr_in server_udp;

    char buffer[BUFFERSIZE];
    char aux[BUFFERSIZE];
    int bytecount;
    int muestra;
    char buff[3];
    int puerto_udp=0;

    int pid;
    int n;
    struct sockaddr_in from;
    int fromlen = sizeof(struct sockaddr_in);
    
    if(send(socket_tcp,"bienvenido!",11,0)==-1)
    {
        printf("[SERVER]: No se pudo enviar información cliente %s, puerto %d\n",inet_ntoa(addr.sin_addr),addr.sin_port);                
    }
    
    memset(buffer, 0, BUFFERSIZE);
    if(recv(socket_tcp,buffer,BUFFERSIZE,0)==0)
    {
        printf("[SERVER]: Cliente desconectado\n");
        close(socket_udp);
        close(socket_tcp);
        return 0;
    }

    if(strncmp(buffer,"send_port!",10)==0)
    {
        printf("[SERVER]: El cliente espera recibir puerto UDP\n");
    }
    else
    {
        printf("[SERVER]: Cliente desconectado\n");
        close(socket_udp);
        close(socket_tcp);
        return 0;
    }
    
    socket_udp=socket(AF_INET, SOCK_DGRAM, 0);
    
    if(socket_udp<0)
    {
        printf("[SERVER]: No se puede crear socket UDP");
        printf("[SERVER]: Cliente desconectado\n");
        close(socket_udp);
        close(socket_tcp);
        return 0;
    }

    memset(&server_udp,0,sizeof(server_udp));  /*limpio la direccion del socket del servidor*/
    /* (2) vinculo la direccion IP y puerto local al socket creado anteriormente */   
    server_udp.sin_family=AF_INET;   
    server_udp.sin_addr.s_addr=INADDR_ANY;   
    srand(time(NULL));
    do
    {
    puerto_udp=rand()%1000+5000;
    server_udp.sin_port=htons(puerto_udp);
    }
    while(bind(socket_udp,(struct sockaddr*)&server_udp,sizeof(server_udp))<0);
    printf("[SERVER]: Puerto %d UDP bindeado con exito\n",(int) ntohs(server_udp.sin_port));

    if(send(socket_tcp,&puerto_udp,sizeof(int),0)==-1)
    {
        printf("[SERVER]: No se pudo enviar información cliente %s, puerto %d\n",inet_ntoa(addr.sin_addr),addr.sin_port); 
        printf("[SERVER]: Cliente desconectado\n");
        close(socket_udp);
        close(socket_tcp);
        return 0;       
    }

    memset(buffer, 0, BUFFERSIZE);
    if(recv(socket_tcp,buffer,BUFFERSIZE,0)==0)
    {
        printf("[SERVER]: Cliente desconectado\n");
        close(socket_udp);
        close(socket_tcp);
        return 0;
    }

    if(strncmp(buffer,"puerto_ok!",10)==0)
    {
        printf("[SERVER]: El cliente recibio el Puerto UDP con exito\n");
    }
    else
    {
        printf("[SERVER]: Cliente desconectado\n");
        close(socket_udp);
        close(socket_tcp);
        return 0;
    }
    
    close(socket_tcp);
    //--------------------------------------------------------
    memset(buffer, 0, BUFFERSIZE);
    alarm(2);
    n=recvfrom(socket_udp,buffer,BUFFERSIZE,0,(struct sockaddr *)&from,&fromlen);
    printf("[SERVER]: Puerto UDP Cliente %d\n",(int) ntohs(from.sin_port));
    alarm(0);
    if (n<0) 
    {
      printf("[SERVER]: Error de recepcion, el cliente nunca envió nada\n");
    }
    if(strncmp(buffer,"ACK!",10)==0)
    {
      printf("[SERVER]: Comienzo del streaming de datos\n");        
    }
    else
    {
        printf("[SERVER]: Cliente desconectado\n");
        close(socket_udp);
        close(socket_tcp);
        return 0;
    }         
    //n=sendto(socket_udp,"Recibi tu mensaje\n",18,0,(struct sockaddr *)&from,fromlen);    
    
    //--------------------------------------------------------
    pid=fork();
    if(pid==0)
    {
        while(!fin)
        {
            if(flag_lectura==0)
            {
            flag_lectura=1;
            muestra=*shm_addr;
            sendto(socket_udp,&muestra,sizeof(int),0,(struct sockaddr *)&from,fromlen);
            }
        }        
    }  
    else
    {
        alarm(5);
        signal(SIGUSR1,SIG_IGN);
        while(!fin)
        {
            n=recvfrom(socket_udp,buffer,BUFFERSIZE,0,(struct sockaddr *)&from,&fromlen);

            if(n<0)
            {
                fin=1;
            }
            
            if(strncmp(buffer,"ACK!",4)==0)
            {
            //printf("[SERVER]: Recibo ACK!\n");
            alarm(2);   
            }
            else
            {
            //printf("[SERVER]: ACK erroneo\n");
            fin=1;
            kill(pid,SIGALRM);
            }
        }
        printf("[SERVER]: No recibi mas ACK!\n");
        kill(pid,SIGALRM);
        printf("[SERVER]: Cierro conexion con el cliente %s, puerto %d\n",inet_ntoa(addr.sin_addr),addr.sin_port);
    }
    wait(NULL);
    close(socket_udp);
    close(socket_tcp);
    return 0;    
}

int DemasiadosClientes(int socket, struct sockaddr_in addr)
{
    char buffer[BUFFERSIZE];  
    int bytecount;

    memset(buffer, 0, BUFFERSIZE);
   
    sprintf(buffer, "Demasiados clientes conectados. Por favor, espere unos minutos\n");

    if((bytecount = send(socket, buffer, strlen(buffer), 0))== -1)
    {
    printf("[SERVER]: No se pudo enviar información cliente %s, puerto %d\n",inet_ntoa(addr.sin_addr),addr.sin_port);                
    }
   
    close(socket);
    return 0;
}