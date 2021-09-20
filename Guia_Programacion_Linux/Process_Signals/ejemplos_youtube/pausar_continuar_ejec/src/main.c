/**
 * @file main.c
 * @author Nicolas Rios Taurasi (nicoriostaurasi@frba.utn.edu.ar)
 * @brief 
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
        kill(pid,SIGSTOP);
        int t;
        do
        {
        printf("Time in seconds for execution:\n");
        scanf("%d",&t);
            if(t>0)
            {
            kill(pid,SIGCONT);
            sleep(t);
            kill(pid,SIGSTOP); 
            }
        }while(t>0);
        kill(pid,SIGKILL); 
        wait(NULL);   
    }

    return 0;
}