/**
 * @file main.c
 * @author Nicolas Rios Taurasi (nicoriostaurasi@frba.utn.edu.ar)
 * @brief Un padre crea dos hijos para paralelizar el proceso de suma con 2 pipes
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
    int sumAux1,sumAux2;
    int Arr[]={1,2,5,3,5,6};
    int sizeArr=sizeof(Arr)/sizeof(int);
    int pids[2];
    int fd1[2];
    int fd2[2];
    int start,end;
    int i;
    int sumPartial=0;
    // fd[0] - read
    // fd[1] - write
    if(pipe(fd1)==-1)
    {   
        printf("An error ocurred with opening the pipe\n");
        return 1;
    }

    if(pipe(fd2)==-1)
    {   
        printf("An error ocurred with opening the pipe\n");
        return 1;
    }
   
    pids[0]=fork();

    if(pids[0]!=0)
    {
    pids[1]=fork();
    }
    
    if(pids[0]==0)
    {
    start=0;
    end=sizeArr/3;
    }
    else if(pids[1]==0)
    {
    start=sizeArr/3;
    end=2*(sizeArr/3);
    }
    else
    {
    start=2*(sizeArr/3);
    end=sizeArr;
    }

    for(i=start;i<end;i++)
    {
        sumPartial=sumPartial+Arr[i];
    }

    printf("La suma parcial es: %d\n",sumPartial);

    if(pids[0]==0)
    {
        close(fd2[0]);
        close(fd2[1]);
        close(fd1[0]);
        if(write(fd1[1],&sumPartial, sizeof(int))==-1)
        {
            printf("An error ocurred with writing to the pipe\n");
            return 2;
        }
        close(fd1[1]);   
    }
    else if((pids[1]!=0) && (pids[0]!=0) )
    {
        close(fd1[1]);
        if(read(fd1[0],&sumAux1,sizeof(int))==-1)
        {
            printf("An error ocurred with reading to the pipe\n");
            return 3;
        }
        close(fd1[0]); 
        wait(NULL);
        printf("P1 La suma parcial es: %d\n",sumPartial+sumAux1);
    }

    if(pids[1]==0)
    {
        close(fd1[0]);
        close(fd1[1]);

        close(fd2[0]);
        if(write(fd2[1],&sumPartial, sizeof(int))==-1)
        {
            printf("An error ocurred with writing to the pipe\n");
            return 2;
        }
        close(fd2[1]);   
    }
    else if((pids[1]!=0) && (pids[0]!=0))
    {
        close(fd2[1]);
        if(read(fd2[0],&sumAux2,sizeof(int))==-1)
        {
            printf("An error ocurred with reading to the pipe\n");
            return 3;
        }
        close(fd2[0]); 
        wait(NULL);
        printf("La suma total es: %d\n",sumPartial+sumAux1+sumAux2);
    }
    return 0;
} 