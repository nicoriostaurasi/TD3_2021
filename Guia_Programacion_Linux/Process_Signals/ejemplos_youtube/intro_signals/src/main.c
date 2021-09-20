/**
 * @file main.c
 * @author Nicolas Rios Taurasi (nicoriostaurasi@frba.utn.edu.ar)
 * @brief Ejemplo de Signal y process, el padre crea un proceso hijo lo deja correr 2 segundos y luego de ese
 * tiempo lo mata.
 * @version 0.1
 * @date 03-09-2021
 * 
 * @copyright Copyright (c) 2021
 * 
 */

#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <time.h>
#include <sys/wait.h>
#include <signal.h>

int main(int argc,char* argv[])
{   
    int pid = fork();
    if(pid==-1)
    {
        return -1;
    }

    if(pid==0)
    {
        while(1)
        {
            printf("Some text goes here\n");
            usleep(500000);
        }
    }
    else
    {
        printf("Espero 2 coriendo a mi hijo\n");
        sleep(1);
        printf("Esperé 2 segundos y lo maté\n");
        kill(pid,SIGKILL);
        wait(NULL);   
    }

    return 0;
}