/**
 * @file main.c
 * @author Nicolas Rios Taurasi (nicoriostaurasi@frba.utn.edu.ar)
 * @brief Con este codigo lo que se busca es tener un ejemplo de como leer un archivo de configuracion por pooling entre padre e hijo mediante pipes
 * @version 0.1
 * @date 20-09-2021
 * 
 * @copyright Copyright (c) 2021
 * 
 */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <signal.h>

#define CLIENTE_DEF 2
#define CONEC_DEF   2
#define CANTIDAD_BUFFER 2


int main(void)
{
    int PID;
    int fd_pipe[2]; 

    if(pipe(fd_pipe)==-1)
    {
        printf("Error al crear el PIPE\n");
        return 1;
    }


    PID=fork();

    if(PID==-1)
    {
        printf("Error al crear al hijo\n");
        return 1;
    }

    if(PID==0)
    {           
        //Proceso Hijo
        int flag_escritura=0;
        int cantidad_buff_hijo;
        FILE* fp_cfg;
        int buff_tx[CANTIDAD_BUFFER];
        int conexiones_ant,clientes_ant;
        int conexiones_now,clientes_now;
        conexiones_ant=CONEC_DEF;
        clientes_ant=CLIENTE_DEF;
        buff_tx[0]=conexiones_now;
        buff_tx[1]=clientes_now;
        cantidad_buff_hijo=CANTIDAD_BUFFER;

        while(1)
        {
            fp_cfg=fopen("cfg.txt","r");
            if(fp_cfg==NULL)
            {
                printf("No se puede abrir el archivo de configuración\n");
                return 1;
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
        

            if(flag_escritura==1)
            {
            printf("Cambio detectado, al pipe!\n");
            write(fd_pipe[1],&cantidad_buff_hijo,sizeof(int));
            write(fd_pipe[1],buff_tx,cantidad_buff_hijo*sizeof(int));
            flag_escritura=0;
            }        
            usleep(500000);
            fclose(fp_cfg);
        }
        printf("Me fui\n");
        return 0;
    }
    else
    {   
        //Proceso Padre
        int cantidad_pipe;
        int buff_rx[CANTIDAD_BUFFER];
        int err;
        fd_set rfds;        /* Conjunto de descriptores a vigilar */
        struct timeval tv;
    while(1)
    {    
        FD_ZERO(&rfds);
        FD_SET(fd_pipe[1], &rfds);
        FD_SET(fd_pipe[0], &rfds);
        tv.tv_sec = 0;
        tv.tv_usec = 0;    /* Tiempo de espera */
        err=select(fd_pipe[1]+1, &rfds, NULL, NULL, &tv);
        if(err!=-1)
        {
            if(FD_ISSET(fd_pipe[0],&rfds))
            {
            printf("Nueva info por el pipe!\n");
            read(fd_pipe[0],&cantidad_pipe,sizeof(int));
            read(fd_pipe[0],buff_rx,cantidad_pipe*sizeof(int));
            printf("Conexiones: %d Clientes: %d\n",buff_rx[0],buff_rx[1]);
            }
        }
    }    
    
    }
    return 0;
}
