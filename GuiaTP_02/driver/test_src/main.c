#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <fcntl.h>      
#include <unistd.h>     
#include <stdint.h>     
#include <sys/ioctl.h>

#define ARES_2G                     2.0f/32768.0f

typedef enum MeasureState{AC_X,AC_Y,AC_Z,TEMP,GY_X,GY_Y,GY_Z};
typedef enum MeasureState MeasureState;
MeasureState MState;


int main()
{
    printf("Hola, soy el test de fops\n");

    int fp;
    uint16_t* buff;

    buff=malloc(sizeof(uint16_t));

    uint8_t* buff_escritura;

    buff_escritura=malloc(sizeof(uint8_t));


    printf("fp %d\n",fp);

    fp=open("/dev/NRT_td3_i2c_dev",O_RDWR);
    printf("fp %d\n",fp);

    int j=0;

    for(j=0;j<50;j++)
    {
        *buff_escritura=AC_X;
        write(fp,buff_escritura,1);
        read(fp,buff,1);
        printf("acx %f\t",(float)((float)*buff * ARES_2G));

        *buff_escritura=AC_Y;
        write(fp,buff_escritura,1);
        read(fp,buff,1);
        printf("acy %f\t",(float)((float)*buff * ARES_2G));

        *buff_escritura=AC_Z;
        write(fp,buff_escritura,1);
        read(fp,buff,1);
        printf("acz %f\t",(float)((float)*buff * ARES_2G));

        *buff_escritura=TEMP;
        write(fp,buff_escritura,1);
        read(fp,buff,1);
        printf("temp %f\t",(float)((float)*buff/340+36.53));
   
        *buff_escritura=GY_X;
        write(fp,buff_escritura,1);
        read(fp,buff,1);
        printf("gir x %f\t",250/( (float)*buff *32768));

        *buff_escritura=GY_Y;
        write(fp,buff_escritura,1);
        read(fp,buff,1);
        printf("gir y %f\t",250/( (float)*buff *32768));

        *buff_escritura=GY_Z;
        write(fp,buff_escritura,1);
        read(fp,buff,1);
        printf("gir z %.20f\n",250/( (float)*buff *32768 ));

        usleep(500000);   
    }
    close(fp);
    return 0;
}

