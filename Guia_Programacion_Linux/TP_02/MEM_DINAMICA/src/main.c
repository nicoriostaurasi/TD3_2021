#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <signal.h>


void realocacion(int* vector,int elementos);

int main(void)
{
    int* a;
    int i;
//    a=(int*)calloc(5,sizeof(int));
    a=(int*)malloc(5*sizeof(int));

    for(i=0;i<5;i++)
    {
        a[i]=i;
    }

    for(i=0;i<5;i++)
    {
        printf("Contenido:%d \n",*a);
        a++;
    }
    a=a-5;

    printf("dir1: %p\n",a);
    realocacion(a,10);
    printf("dir2: %p\n",a);

    printf("Realocado\n");
    
    a[5]=23;
    a[6]=31;

    for(i=0;i<7;i++)
    {
        printf("Contenido:%d \n",*a);
        a++;
    }

    return 0;
}


void realocacion(int* vector,int elementos)
{
    vector=(int*)realloc(vector,elementos*sizeof(int));
}
