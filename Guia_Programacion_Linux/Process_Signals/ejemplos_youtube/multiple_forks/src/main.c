/**
 * @file main.c
 * @author Nicolas Rios Taurasi (nicoriostaurasi@frba.utn.edu.ar)
 * @brief Se hacen 2 forks y se ve como es el arbol genialogico entre ambos, luego se hace un wait para esperar
 * la señal de exit de todos los hijos
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

/**
 * Padre-------
 *   |(1)      |(2)
 * Pro X     Pro Z
 *   |(2)
 * Pro Y 
 */

/**
 * Padre: Id1=X Id2=Z
 * 
 * Pro X: Id1=0 Id2=Y
 * 
 * Pro Y: Id1=0 Id2=0
 * 
 * Pro Z: Id1=X Id2=0
 * 
 */

int main(int argc,char* argv[])
{   
    int id1 = fork();
    int id2 = fork();

    if (id1==0)
    {
        if(id2==0)
        {
            printf("We are process y: Id1=%d Id2=%d\n",id1,id2);
        }
        else
        {
            printf("We are process x: Id1=%d Id2=%d\n",id1,id2);
        }
    }
    else
    {
        if(id2==0)
        {
            printf("We are process z: Id1=%d Id2=%d\n",id1,id2);
        }
        else
        {
            printf("We are The parent Process: Id1=%d Id2=%d\n",id1,id2);
        }
    }
    while(wait(NULL)!=-1 || errno != ECHILD)
    {
        printf("Waited for a child to finish\n");
    }


    return 0;
} 