/**
 * @file main.c
 * @author Nicolas Rios Taurasi (nicoriostaurasi@frba.utn.edu.ar)
 * @brief En este ejemplo un padre crea un hijo en el que pide ingresar un número por consola
 * Este numero se envía mediante el pipe al padre
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

int main(int argc,char* argv[])
{   
    int fd[2];
    // fd[0] - read
    // fd[1] - write
    if(pipe(fd)==-1)
    {   
        printf("An error ocurred with opening the pipe\n");
        return 1;
    }
    int id = fork();
    if(id==0)
    {
        close(fd[0]);
        int x;
        printf("Input a number: ");
        scanf("%d",&x);
        if(write(fd[1],&x, sizeof(int))==-1)
        {
            printf("An error ocurred with writing to the pipe\n");
            return 2;
        }
        
        close(fd[1]);
    }
    else
    {
        close(fd[1]);
        int y;
        if(read(fd[0],&y,sizeof(int))==-1)
        {
            printf("An error ocurred with reading to the pipe\n");
            return 3;
        }
        close(fd[0]); 
        printf("Got from child process %d\n",y);
    }

    return 0;
} 