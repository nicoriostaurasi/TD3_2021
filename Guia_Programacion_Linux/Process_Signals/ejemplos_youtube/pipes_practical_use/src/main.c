/**
 * @file main.c
 * @author Nicolas Rios Taurasi (nicoriostaurasi@frba.utn.edu.ar)
 * @brief Un padre crea un hijo para paralelizar el proceso de suma
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
    int Arr[]={1,2,5,3,5,6};
    int sizeArr=sizeof(Arr)/sizeof(int);
    int fd[2];
    int start,end;
    int i;
    int sumPartial=0;
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
    start=0;
    end=sizeArr/2;
    }
    else
    {
    start=sizeArr/2;
    end=sizeArr;
    }

    for(i=start;i<end;i++)
    {
        sumPartial=sumPartial+Arr[i];
    }

    printf("La suma parcial es: %d\n",sumPartial);

    if(id==0)
    {
        close(fd[0]);
        if(write(fd[1],&sumPartial, sizeof(int))==-1)
        {
            printf("An error ocurred with writing to the pipe\n");
            return 2;
        }
        close(fd[1]);   
    }
    else
    {
        int sumAux;
        close(fd[1]);
        if(read(fd[0],&sumAux,sizeof(int))==-1)
        {
            printf("An error ocurred with reading to the pipe\n");
            return 3;
        }
        close(fd[0]); 
        wait(NULL);
        printf("La suma total es: %d\n",sumPartial+sumAux);
    }

    return 0;
} 