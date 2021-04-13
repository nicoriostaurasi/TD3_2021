#include <stdio.h>
#include "../inc/functions.h"

/*
-Código en C que coloca la función en un segmento de código específico
-Para observar ejecutar: make dump 
*/

int main(void)
{
    int a= performSum(3,4);
    printf("\nLa suma es %d\n",a);
}