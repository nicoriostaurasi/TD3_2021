/**
 * @file main.c
 * @author Nicolas Rios Taurasi (nicoriostaurasi@frba.utn.edu.ar)
 * @brief Ejemplo de Signal Wait y process, el padre crea un proceso hijo que cuenta del 1 al 5
 * y el continua la cuenta hasta 10 
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
    int n=0;
    int i=0;

    if(pid==-1)
    {
        return -1;
    }

    if(pid==0)
    {
        n=1;
    }
    else
    {
        n=6;
    }

    if(pid!=0) /*se podría preguntar o no por e PID, el padre espera al
     hijo el hijo no espera a nadie ya que no hay un proceso dependiente de él*/
    {
        wait(NULL);
    }
    for(i=0;i<5;i++)
    {
        printf("%d ",n);
        fflush(stdout);
        n++;
    }
    if(pid!=0)
    {
        printf("\n");
    }


    return 0;
} 