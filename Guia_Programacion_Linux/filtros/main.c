#include <stdlib.h>
#include <stdio.h>
#include <netinet/in.h>

int filtro(int* buffer,int largo, int muestra);


int main()
{
    int16_t temperatura[]={0x2ca0,
0x2c88,
0x2cc0,
0x2c90,
0x7e0,
0x7dc,
0x7de,
0x7e5,
0x7db,
0x7e2,
0x7e2,
0x7e1,
0x7de,
0x7e2,
0x7dd,
0x7df,
0x7e8,
0x7dc,
0x7e2,
0x7e2,
0x7dd,
0x7e3,
0x7e8,
0x7da,
0x7ea,
0x7e3,
0x7e4,
0x7e3,
0x7e7,
0x7e5,
0x7db,
0x7e1,
0x7e4,
0x7e7,
0x7da,
0x7df,
0x7e7,
0x7e4,
0x7e1,
0x7e3,
0x7db,
0x7de,
0x7e8,
0x7de,
0x7e2,
0x7e4,
0x7de,
0x7e4,
0x7df,
0x7e2,
0x7e4,
0x7df,
0x7e4,
0x7e3,
0x7dc,
0x7e3,
0x7db,
0x7e4,
0x7e4,
0x7de,
0x7de,
0x7e2,
0x7e0,
0x7e2,
0x7e8,
0x7e2,
0x7e9,
0x7de,
0x7e6,
0x7e4,
0x7e4,
0x7e4,
0x7e4,
0x7e0,
0x7e3,
0x7e5,
0x7e7,
0x7e3,
0x7da,
0x7e3,
0x7e6,
0x7e1,
0x7de,
0x7e4,
0x7e3,
0x7e2,
0x7dd,
0x7e7,
0x7df,
0x7e8,
0x7e1,
0x7e9,
0x7e0,
0x7e5,
0x7e4,
0x7e4,
0x7e8,
0x7e1,
0x7e0,
0x7e8,
0x7e9,
0x7e2,
0x7e1,
0x7e7,
0x7e5,
0x7e2,
0x7e5,
0x7df,
0x7e1,
0x7e3,
0x7e6,
0x7e6,
0x7e3,
0x7ed,
0x7e7,
0x7ea,
0x7e7,
0x7de,
0x7df,
0x7ec,
0x7e5,
0x7e4,
0x7e1,
0x7e2,
0x7ea,
0x7ed,
0x7ea,
0x7e8,
0x7e4,
0x7e8,
0x7e1,
0x7e1,
0x7e5,
0x7e9,
0x7e2,
0x7ea,
0x7ee,
0x7e4,
0x7df,
0x7e8,
0x7e2,
0x7e8,
0x7e3,
0x7e7,
0x7e2,
0x7e2,
0x7ea,
0x7e4,
0x7e5,
0x7e6
};
    int ventana = 16;
    int cantidad_mediciones;
    int i;
    int32_t* buffer_temperatura;
    int16_t filtrada;
    int16_t cruda;
    float aux;
    buffer_temperatura = (int32_t*) malloc(ventana*sizeof(int32_t));
    cantidad_mediciones=(int) (sizeof(temperatura)/sizeof(uint16_t)); 

    printf("vector filtrado\n");

    for(i=0;i<cantidad_mediciones;i++)
    {
        filtrada=filtro(buffer_temperatura,ventana,temperatura[i]);
        aux=((float)filtrada/340) + 36.53;
        printf("%.5f \t",aux);
//        printf("%d\t",filtrada);
    
        if( (i%7) == 0 && i!=0)
        {
            printf("\n");
        }
    }
    printf("\n");

    printf("vector crudo\n");

    for(i=0;i<cantidad_mediciones;i++)
    {
        cruda = temperatura[i];
        aux=((float)cruda/340) + 36.53;



        printf("%.5f \t",aux);

  //      printf("%d\t",cruda);

        if( (i%7) == 0 && i!=0)
        {
            printf("\n");
        }

    }

        printf("\n");

    return 0;
}


int filtro(int* buffer,int largo, int muestra)
{
  int aux=0;
  int i;

  for(i=0;i<(largo-1);i++)
  {
  buffer[largo-(i+1)]=buffer[largo-(i+1)-1];
  }

  buffer[0]=muestra;

  for(i=0;i<largo;i++)
  {
    aux=aux+buffer[i];
  }
  aux=aux/largo;  
  return aux;
}