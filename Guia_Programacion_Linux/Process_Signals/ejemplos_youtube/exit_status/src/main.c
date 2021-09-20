/**
 * @file main.c
 * @author Nicolas Rios Taurasi (nicoriostaurasi@frba.utn.edu.ar)
 * @brief Comandos por consola con error y recepcion de errores entre padre e hijo
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
#include <errno.h>
#include <fcntl.h>

int main(int argc,char* argv[])
{   
    int pid=fork();
    if(pid==-1)
    {
        return 1;
    }
    if(pid==0)
    {
        //Child Process
        int file=open("PingResults.txt",O_WRONLY|O_CREAT,0777);
        if(file==-1)
        {
            return 2;
        }
        printf("The fd to pingResults: %d\n",file);
        dup2(file,STDOUT_FILENO);
        close(file);

        int err=execlp("ping","ping","-c","1","google.com",NULL);
        if(err==-1)
        {
            printf("Could not find program to execute!\n");
            return 2;
        }
    }

    else
    {
        int wstatus;
        //Parent process
        wait(&wstatus);
        if(WIFEXITED(wstatus))
        {
            int statusCode=WEXITSTATUS(wstatus);
            if(statusCode==0)
            {
                printf("Success!\n");
            }
            else
            {   
                printf("Failure with code %d\n",statusCode);
            }
        }
    }
    return 0;
} 