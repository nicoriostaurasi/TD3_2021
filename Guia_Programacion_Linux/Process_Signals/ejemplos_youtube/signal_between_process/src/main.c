/**
 * @file main.c
 * @author Nicolas Rios Taurasi (nicoriostaurasi@frba.utn.edu.ar)
 * @brief Se utilizan handlers para las señales de sigcont y sigtstp entre procesos
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

int x=0;

void handle_sigusr1(int sig)
{ 
    if(x==0)
    {
    printf("HINT: Remember multiplication is repetitive addition!\n");
    }
}


int main(int argc,char* argv[])
{   
    int pid=fork();
    if(pid==-1)
    {
        return 1;
    }

    if(pid==0)
    {
        //Child
        sleep(5);
        kill(getppid(),SIGUSR1);
    }
    else
    {
        //Parent
        struct sigaction sa={0};
        sa.sa_flags=SA_RESTART;
        sa.sa_handler=&handle_sigusr1;
        sigaction(SIGUSR1,&sa,NULL);

        printf("Whats is the result of 3x5: ");
        scanf("%d",&x);
        if(x==15)
        {
            printf("Right!\n");
        }
        else
        {
            printf("Wrong =(\n");
        }
        wait(NULL);
    }

    return 0;
} 
