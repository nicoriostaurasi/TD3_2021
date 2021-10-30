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
    uint8_t* buff;

//    buff=malloc(sizeof(uint16_t));

    uint8_t* buff_escritura;

    buff_escritura=malloc(sizeof(uint8_t));


    printf("fp %d\n",fp);

    fp=open("/dev/NRT_td3_i2c_dev",O_RDWR);
    printf("fp %d\n",fp);

    int j=0;
/*
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
        
        usleep(500);
    }
*/
        buff=malloc(14*sizeof(uint8_t));
        uint16_t acx,acy,acz,temp,girx,giry,girz;
        int i;
        for(i=0;i<1000;i++)
        {
        read(fp,buff,14);

        temp=(0xFF&buff[0])<<8 | (0xFF&buff[1]);
        girx=(0xFF&buff[2])<<8 | (0xFF&buff[3]);
        giry=(0xFF&buff[4])<<8 | (0xFF&buff[5]);
        girz=(0xFF&buff[6])<<8 | (0xFF&buff[7]);
        acx=(0xFF&buff[8])<<8  | (0xFF&buff[9]);
        acy=(0xFF&buff[10])<<8 | (0xFF&buff[11]);
        acz=(0xFF&buff[12])<<8 | (0xFF&buff[13]);
    

    
        printf("acx %.2f\t",(float)acx * ARES_2G);
        printf("acy %.2f\t",(float)acy * ARES_2G);
        printf("acz %.2f\t",(float)acz * ARES_2G);
        printf("temp %.2f\t",((float)temp)/340+36.53);
        printf("gir x %.10f\t",(250/( (float)girx *32768)) );
        printf("gir y %.10f\t",(250/( (float)giry *32768)) );
        printf("gir z %.10f\n",(250/( (float)girz*32768)) );

//        printf("acx %x acy %x acz %x temp %x gir_x %x gir_y %x gir_z %x\n",acx,acy,acz,temp,girx,giry,girz);
        }

    close(fp);
    return 0;
}

