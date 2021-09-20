/**
 * @file main.c
 * @author Nicolas Rios Taurasi (nicoriostaurasi@frba.utn.edu.ar)
 * @brief 2 Procesos, el hijo genera una cantidad aleatoria de numeros aleatorios y se los envia al padre. 
 * Luego el padre suma todo y lo imprime
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
    if(pipe(fd)==-1)
    {
        return 2;
    }
    int pid=fork();
    if(pid==-1)
    {
        return 1;
    }

    if(pid==0)
    {
        close(fd[0]);
        int n,i;
        int arr[10];
        srand(time(NULL));
        n=rand()%10+1;
        printf("n: %d\n",n);
        printf("Generated: ");
        for(i=0;i<n;i++)
        {
            arr[i]=rand()%11;
            printf(" %d",arr[i]);
        }
        
        if(write(fd[1],&n,sizeof(int))<0)
        {
            return 4;
        }

        if(write(fd[1],arr,sizeof(int)*n)<0)
        {
            return 3;
        }
        close(fd[1]);
    }
    else
    {
        close(fd[1]);
        int arr[10];
        int n;
        int i;
        int sum=0;
        if(read( fd[0],&n,sizeof(int) )<0)
        {
            return 5;
        }
        if(read(fd[0],arr,n*sizeof(int) )<0)
        {
            return 6;
        }
        close(fd[0]);
        for(i=0;i<n;i++)
        {
            sum=sum+arr[i];
        }
        printf("\n sum: %d\n",sum);
        wait(NULL);
    }

    return 0;
} 