/**
 * @file servidor.c
 * @author Nicolas Rios Taurasi (nicoriostaurasi@frba.utn.edu.ar)
 * @brief Este archivo contiene los principales codigo de los procesos que atienden a los clientes
 * @version 0.1
 * @date 02-11-2021
 * 
 * @copyright Copyright (c) 2021
 * 
 */
#include "../inc/main.h"

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

/**
 * @brief Proceso que atiende a los clientes
 * 
 * @param socket_tcp 
 * @param addr 
 * @param shm_addr 
 * @param sem_set_id 
 * @return int 
 */
int AtiendeCliente(int socket_tcp, struct sockaddr_in addr,char* shm_addr, int sem_set_id)
{
    mediciones buff_medido;
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

    char vector[238];    
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
    
    if(send(socket_tcp,"OK",2,0)==-1)
    {
        printf("[SERVER]: No se pudo enviar información cliente %s, puerto %d\n",inet_ntoa(addr.sin_addr),addr.sin_port);                
    }
    memset(buffer, 0, BUFFERSIZE);
    if(recv(socket_tcp,buffer,BUFFERSIZE,0)==0)
    {
        printf("[SERVER]: Cliente desconectado por timeout\n");
        close(socket_udp);
        close(socket_tcp);
        return 0;
    }

    if(strncmp(buffer,"AKN",3)==0)
    {
        printf("[SERVER]: El cliente espera recibir datos\n");

    }
    else
    {
        printf("[SERVER]: Cliente desconectado\n");
        close(socket_udp);
        close(socket_tcp);
        return 0;
    }

    if(send(socket_tcp,"OK",2,0)==-1)
    {
        printf("[SERVER]: No se pudo enviar información cliente %s, puerto %d\n",inet_ntoa(addr.sin_addr),addr.sin_port);                
    }

    printf("[SERVER]: Comienzo del streaming de datos\n");        
    //--------------------------------------------------------
    pid=fork();
    if(pid==0)
    {
        while(!fin)
        {
            if(flag_lectura==0)
            {
            flag_lectura=1;
            memcpy(vector,shm_addr,sizeof(vector));
            send(socket_tcp,vector,strlen(vector),0);
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

            memset(buffer, 0, BUFFERSIZE);
            n=recv(socket_tcp,buffer,BUFFERSIZE,0);

            if(n<0)
            {
                fin=1;
            }
            
            if(strncmp(buffer,"KA",2)==0)
            {
//            printf("[SERVER]: Recibo KA!\n");
            alarm(5);   
            }
            else
            {   
            printf("[SERVER]: AKN erroneo\n");
            fin=1;
            kill(pid,SIGALRM);
            }
        }
        printf("[SERVER]: No recibi mas KA!\n");
        kill(pid,SIGALRM);
        printf("[SERVER]: Cierro conexion con el cliente %s, puerto %d\n",inet_ntoa(addr.sin_addr),addr.sin_port);
    }
    wait(NULL);
    close(socket_udp);
    close(socket_tcp);
    return 0;    
}

/**
 * @brief Proceso que rechaza a los clientes
 * 
 * @param socket 
 * @param addr 
 * @return int 
 */
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