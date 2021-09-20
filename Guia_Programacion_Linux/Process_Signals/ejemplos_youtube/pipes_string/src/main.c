/**
 * @file main.c
 * @author Nicolas Rios Taurasi (nicoriostaurasi@frba.utn.edu.ar)
 * @brief 2 Procesos, el hijo lee un string desde consola y se lo envia mediante un pipe al padre
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
#include <string.h>

int main(int argc,char* argv[])
{   
    int fd[2];
    if(pipe(fd)==-1)
    {
        return 2;
    }
    int pid=fork();
    if(pid<0)
    {
        return 1;
    }

    if(pid==0)
    {
        int large_str;
        close(fd[0]);
        char str[200];
        printf("Input a string: ");
        fgets(str,200,stdin);
        str[strlen(str)-1]='\0';

        large_str=strlen(str)+1;
        if(write(fd[1],&large_str,sizeof(int))<0)
        {
            return 4;
        }

        if(write(fd[1],str,strlen(str)+1)<0)
        {
            return 3;
        }
        close(fd[1]);
    }
    else
    {
        close(fd[1]);
        char str[200];
        int large_str;
        if(read(fd[0],&large_str,sizeof(int)) <0 )
        {
            return 5;
        }        
        if(read(fd[0],str,large_str*sizeof(char))<0)
        {
            return 6;
        }
        printf("El string ingresado es: %s\n",str);
        close(fd[0]);
    }

    return 0;
} 