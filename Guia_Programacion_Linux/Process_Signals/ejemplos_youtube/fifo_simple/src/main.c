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
    if(mkfifo("myfifo1",0777)==-1)
    {
        if(errno!=EEXIST)
        {
            printf("Could no create fifo file \n");
            return 1;
        }
    }
    printf("Opening...\n");
    int fd = open("myfifo1",O_WRONLY);
    printf("Opened\n");
    int x='a';
    if(write(fd,&x,sizeof(x))==-1)
    {
        return 2;
    }
    printf("Written\n");
    close(fd);
    printf("Closed\n");
    return 0;
} 