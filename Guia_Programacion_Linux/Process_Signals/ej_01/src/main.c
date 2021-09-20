#include <stdio.h>
#include <sys/types.h>
#include <unistd.h>

int main()
{   
    pid_t proceso;
    int j=15;
    printf("Ej01: Padre e Hijo\n");


    proceso=fork();
    if(proceso == 0)
    {
        printf("Hola gente soy el hijo\n");
        j=24;
        printf("Hijo dice j vale ahora: %d\n",j);
    }
    else
    {
        printf("Hola chicos soy el padre\n");
        printf("Padre dice j vale ahora: %d\n",j);
 
    }


    return 0;
}