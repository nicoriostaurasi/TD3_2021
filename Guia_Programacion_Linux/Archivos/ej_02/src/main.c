#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[])
{
    char aux;
    FILE* codigo_fuente;

    printf("Ejercicio que lee a otro recibiendo el parametro por argumento y lo imprime en consola\n");

    if(argc!=2) 
    {
        printf("Ha olvidado introducir el archivo a leer por argumento :)\n");
        return -1;
    }

    codigo_fuente=fopen(argv[1],"r");

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