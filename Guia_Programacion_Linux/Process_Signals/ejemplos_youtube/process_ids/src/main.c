/**
 * @file main.c
 * @author Nicolas Rios Taurasi (nicoriostaurasi@frba.utn.edu.ar)
 * @brief Se hace una instancia de hijo y se verifica los distintos ID, como el hijo duerme 1 segundo
 * se lo debe de esperar. Podemos ver que el wait arroja -1 si no tiene un hijo asociado
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
    if (pid==0)
    {
        sleep(1);
    }

    printf("Current ID: %d, parent ID: %d\n",getpid(),getppid());

    int res=wait(NULL);
    if(res==-1)
    {
        printf("No children to wait for\n");
    }
    else
    {
        printf("%d process finished execution\n",res);
    }

    return 0;
} 