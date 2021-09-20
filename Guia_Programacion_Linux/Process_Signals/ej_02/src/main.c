#include <stdio.h>
#include <sys/types.h>
#include <unistd.h>

int main()
{   
pid_t pids[10];
int i;
int n = 10;
int status;

    /*Creando los Hijos*/
    for (i=0;i<n;i++) {
      if ((pids[i] = fork()) < 0) 
      {
        perror("fork");
        abort();
      } 
      else if (pids[i] == 0) 
      {
        sleep(5);
        exit(0);
      }
    }
    
    sleep(10);

    pid_t pid;
    for(i=0;i<n;i++)
    {
      pid = wait(&status);
      printf("Hijo con PID %ld termino con el siguiente estado 0x%x.\n", (long)pid, status);  
    }

    return 0;
}