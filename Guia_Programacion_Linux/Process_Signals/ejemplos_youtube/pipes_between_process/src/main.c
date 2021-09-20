/**
 * @file main.c
 * @author Nicolas Rios Taurasi (nicoriostaurasi@frba.utn.edu.ar)
 * @brief Un padre envia un numero aleatorio a su hijo para que este lo multuplique x4, se utilizan 2 pipes
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
    int p1[2]; // C => P
    int p2[2]; // P => C
    // p1[0] - read
    // p1[1] - write

    if(pipe(p1)==-1){return 1;}
    if(pipe(p2)==-1){return 1;}

    int pid=fork();
    if(pid==-1) {return 2;}

    if(pid==0)
    {
        close(p1[0]);
        close(p2[1]);
        //Child Process
        int x;
        if(read(p2[0],&x,sizeof(x))==-1){return 3;}
        printf("Received %d\n",x);
        x*=4;
        if(write(p1[1],&x,sizeof(x))==-1){return 4;}
        printf("Wrote %d\n",x);
        close(p1[1]);
        close(p2[0]);
        
    }
    else
    {
        close(p2[0]);
        close(p1[1]);
        //Parent Process
        srand(time(NULL));
        int y=rand()%10;
        if(write(p2[1],&y,sizeof(y))==-1){return 4;}
        if(read(p1[0],&y,sizeof(y))==-1){return 5;}
        printf("Result: %d\n",y);
        wait(NULL);
        close(p2[1]);
        close(p1[0]);

    }

    return 0; 
} 