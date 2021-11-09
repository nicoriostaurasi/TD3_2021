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


//    socket_udp=socket(AF_INET, SOCK_DGRAM, 0);
    
//    if(socket_udp<0)
//    {
//        printf("[SERVER]: No se puede crear socket UDP");
//        printf("[SERVER]: Cliente desconectado\n");
//        close(socket_udp);
//        close(socket_tcp);
//        return 0;
//    }

//    memset(&server_udp,0,sizeof(server_udp));  /*limpio la direccion del socket del servidor*/
    /* (2) vinculo la direccion IP y puerto local al socket creado anteriormente */   
//    server_udp.sin_family=AF_INET;   
  //  server_udp.sin_addr.s_addr=INADDR_ANY;   
  //  srand(time(NULL));
  //  do
   // {
   // puerto_udp=rand()%1000+5000;
   // server_udp.sin_port=htons(puerto_udp);
   // }
//    while(bind(socket_udp,(struct sockaddr*)&server_udp,sizeof(server_udp))<0);
//    printf("[SERVER]: Puerto %d UDP bindeado con exito\n",(int) ntohs(server_udp.sin_port));

//    if(send(socket_tcp,&puerto_udp,sizeof(int),0)==-1)
//    {
//        printf("[SERVER]: No se pudo enviar información cliente %s, puerto %d\n",inet_ntoa(addr.sin_addr),addr.sin_port); 
//        printf("[SERVER]: Cliente desconectado\n");
//        close(socket_udp);
//        close(socket_tcp);
//        return 0;       
//    }

//    memset(buffer, 0, BUFFERSIZE);
//    if(recv(socket_tcp,buffer,BUFFERSIZE,0)==0)
//    {
//        printf("[SERVER]: Cliente desconectado\n");
//        close(socket_udp);
//        close(socket_tcp);
///        return 0;
 //   }

//    if(strncmp(buffer,"puerto_ok!",10)==0)
//    {
//        printf("[SERVER]: El cliente recibio el Puerto UDP con exito\n");
//    }
//    else
//    {
//        printf("[SERVER]: Cliente desconectado\n");
//        close(socket_udp);
//        close(socket_tcp);
//        return 0;
//    }
    
//    close(socket_tcp);
    //--------------------------------------------------------
//    memset(buffer, 0, BUFFERSIZE);
//    alarm(2);
//    n=recvfrom(socket_udp,buffer,BUFFERSIZE,0,(struct sockaddr *)&from,&fromlen);
//    printf("[SERVER]: Puerto UDP Cliente %d\n",(int) ntohs(from.sin_port));
//    alarm(0);
//    if (n<0) 
//    {
//      printf("[SERVER]: Error de recepcion, el cliente nunca envió nada\n");
//    }
//    if(strncmp(buffer,"ACK!",10)==0)
//    {
      printf("[SERVER]: Comienzo del streaming de datos\n");        
//    }
//    else
//    {
//        printf("[SERVER]: Cliente desconectado\n");
//        close(socket_udp);
//        close(socket_tcp);
//        return 0;
//    }         
    //n=sendto(socket_udp,"Recibi tu mensaje\n",18,0,(struct sockaddr *)&from,fromlen);    
    
    //--------------------------------------------------------
    char vector[238];
    float raw_accel_xout, raw_accel_yout, raw_accel_zout, raw_gyro_xout, raw_gyro_yout, raw_gyro_zout, raw_temp_out;
    float mva_accel_xout, mva_accel_yout, mva_accel_zout, mva_gyro_xout, mva_gyro_yout, mva_gyro_zout, mva_temp_out;

    
    pid=fork();
    if(pid==0)
    {
        while(!fin)
        {
            if(flag_lectura==0)
            {
            flag_lectura=1;
//            muestra=*shm_addr;
            memcpy(&buff_medido,shm_addr,sizeof(mediciones));

            raw_accel_xout=buff_medido.raw_ac_x; 
            raw_accel_yout=buff_medido.raw_ac_y; 
            raw_accel_zout=buff_medido.raw_ac_z; 
            raw_gyro_xout =buff_medido.raw_gy_x; 
            raw_gyro_yout =buff_medido.raw_gy_y; 
            raw_gyro_zout =buff_medido.raw_gy_z; 
            raw_temp_out  =buff_medido.raw_temp;

            mva_accel_xout=buff_medido.mva_ac_x; 
            mva_accel_yout=buff_medido.mva_ac_y; 
            mva_accel_zout=buff_medido.mva_ac_z; 
            mva_gyro_xout =buff_medido.mva_gy_x; 
            mva_gyro_yout =buff_medido.mva_gy_y; 
            mva_gyro_zout =buff_medido.mva_gy_z; 
            mva_temp_out  =buff_medido.mva_temp;
            
            sprintf(vector,"%.5f\n%.5f\n%.5f\n%.5f\n%.5f\n%.5f\n%.5f\n%.5f\n%.5f\n%.5f\n%.5f\n%.5f\n%.5f\n%.5f\n",
            raw_accel_xout, raw_accel_yout, raw_accel_zout, raw_gyro_xout, raw_gyro_yout, raw_gyro_zout, raw_temp_out,
            mva_accel_xout, mva_accel_yout, mva_accel_zout, mva_gyro_xout, mva_gyro_yout, mva_gyro_zout, mva_temp_out);

//            sendto(socket_udp,&muestra,sizeof(int),0,(struct sockaddr *)&from,fromlen);
//            send(socket_tcp,vector,238*sizeof(char),0);
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