#include <stdio.h>
#include <stdlib.h>

int main()
{
    char aux;
    printf("Ejercicio que se lee a si mismo y se imprime en consola\n");

    FILE* codigo_fuente;

    codigo_fuente=fopen("src/main.c","r");

    if(codigo_fuente == NULL)
    {
        printf("No se pudo abrir el file\n");
        return 1;
    }

    printf("-----------Lectura del archivo-----------\n");

    do
    {
        aux=fgetc(codigo_fuente);
        write(1, &aux ,1); 
    }
    while(!feof(codigo_fuente));
    printf("\n");


    printf("-----------------------------------------\n");

    fclose(codigo_fuente);
    return 0;
}