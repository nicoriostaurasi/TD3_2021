/**
 * @file main.c
 * @author Nicolas Rios Taurasi (nicoriostaurasi@frba.utn.edu.ar)
 * @brief Procesos que en paralelo generan numeros aleatorios y luego se comunican ambos numeros mediante una fifo
 * luego el receptor envia una suma de los numeros al transmisor
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
#include <sys/stat.h>
#include <sys/types.h>
#include <signal.h>
#include <errno.h>
#include <fcntl.h>

int main(int argc,char* argv[])
{
    int arr[5];
    srand(time(NULL));
    int i;
    int sum;
    for(i=0;i<5;i++)
    {
        arr[i]=rand()%100;
        printf("Generated: %d\n",arr[i]);
    }
    
    if(mkfifo("sum",0777)==-1)
    {
        if(errno!=EEXIST)
        {
            printf("Could no create fifo file \n");
            return 1;
        }
    }

    
    int fd = open("sum",O_WRONLY);
    if(fd==-1)
    {
        return 2;
    }

    if(write(fd,arr,5*sizeof(int))==-1)
    {
        return 3;
    }

    close(fd);
    fd = open("sum",O_RDONLY);
    if(fd==-1)
    {
        return 4;
    }
    
    if(read(fd,&sum,sizeof(int))==-1)
    {
        return 5;
    }

    printf("Sum tot: %d\n",sum);
    close(fd);
    return 0;

} 