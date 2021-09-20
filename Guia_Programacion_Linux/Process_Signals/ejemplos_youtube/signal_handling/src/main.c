/**
 * @file main.c
 * @author Nicolas Rios Taurasi (nicoriostaurasi@frba.utn.edu.ar)
 * @brief Se utilizan handlers para las señales de sigcont y sigtstp
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

void handle_sigcont(int sig)
{
    printf("Input number: ");
    fflush(stdout);
}

void handle_sigtstp(int sig)
{
    printf(" Stop NOT ALLOWED ");
}


int main(int argc,char* argv[])
{   
    struct sigaction sa;
    sa.sa_handler=&handle_sigcont;
    sa.sa_flags=SA_RESTART;
    sigaction(SIGCONT,&sa,NULL);

    struct sigaction sa2;
    sa2.sa_handler=&handle_sigtstp;
    sa2.sa_flags=SA_RESTART;
    sigaction(SIGTSTP,&sa2,NULL);

    int x;
    printf("Input number: ");
    scanf("%d",&x);
    printf("The result of 5*%d is:%d \n",x,5*x);
    return 0;
} 