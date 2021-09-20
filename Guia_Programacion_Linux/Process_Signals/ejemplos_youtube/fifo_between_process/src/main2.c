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
#include <sys/stat.h>
#include <sys/types.h>
#include <signal.h>
#include <errno.h>
#include <fcntl.h>

int main(int argc,char* argv[])
{
    int arr[5];
    int i=0;
    int sum=0;
    int fd = open("sum",O_RDONLY);
    if(fd==-1)
    {
        return 1;
    }
    
    if(read(fd,arr,5*sizeof(int))==-1)
    {
        return 2;
    }

    for(i=0;i<5;i++)
    {
        sum=sum+arr[i];
        printf("Received %d\n",arr[i]);
    }
    close(fd);
    printf("Sum tot: %d\n",sum);
    
    fd = open("sum",O_WRONLY);
    if(fd==-1)
    {
        return 3;
    }

    if(write(fd,&sum,sizeof(int))==-1)
    {
        return 4;
    }
  
    close(fd);   
    
    
    return 0;
} 