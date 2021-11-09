#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <fcntl.h>      
#include <unistd.h>     
#include <stdint.h>     
#include <sys/ioctl.h>

#define muestras    (1)
#define ARES_2G                     2.0f/32768.0f
#define GYR_250                     250.0f/32768.0f

typedef enum MeasureState{AC_X,AC_Y,AC_Z,TEMP,GY_X,GY_Y,GY_Z};
typedef enum MeasureState MeasureState;
MeasureState MState;


int main()
{
    printf("Hola, soy el test de fops\n");

    int fp;
    uint8_t* buff;
    FILE* fp_log;
    FILE* fp_log_x;
//    buff=malloc(sizeof(uint16_t));

    uint8_t* buff_escritura;

    buff_escritura=malloc(sizeof(uint8_t));


    printf("fp %d\n",fp);

    fp=open("/dev/NRT_td3_i2c_dev",O_RDWR);
    printf("fp %d\n",fp);

    fp_log=fopen("fifo_log.txt","w");
    fp_log_x=fopen("fifo_log_d.txt","w");

    int j=0;

    buff=malloc(14*muestras*sizeof(uint8_t));
    int16_t acx,acy,acz,girx,giry,girz;
    int16_t temp;
    int i;
 
    for(i=0;i<150;i++)
    {
        read(fp,buff,14*muestras);
        acx=(0xFF&buff[0])<<8  | (0xFF&buff[1]);
        acy=(0xFF&buff[2])<<8 | (0xFF&buff[3]);
        acz=(0xFF&buff[4])<<8 | (0xFF&buff[5]);
        temp=(0xFF&buff[6])<<8 | (0xFF&buff[7]);
        girx=(0xFF&buff[8])<<8 | (0xFF&buff[9]);
        giry=(0xFF&buff[10])<<8 | (0xFF&buff[11]);
        girz=(0xFF&buff[12])<<8 | (0xFF&buff[13]);

        printf("acx %.3f\t",(float)acx * ARES_2G);
        printf("acy %.3f\t",(float)acy * ARES_2G);
        printf("acz %.3f\n",(float)acz * ARES_2G);
        printf("temp %.2f\t",((float)temp)/340+36.53);  
        printf("gir x %.3f\t",(float)girx * GYR_250);
        printf("gir y %.3f\t",(float)giry * GYR_250);
        printf("gir z %.3f\t",(float)girz * GYR_250);
//        fprintf(fp_log,"temp 0x%x \tgir_x 0x%x \tgir_y 0x%x \tgir_z 0x%x \tacx 0x%x \tacy 0x%x \tacz 0x%x \n",temp,girx,giry,girz,acx,acy,acz);
 //       fprintf(fp_log_x,"temp %d \tgir_x %d \tgir_y %d \tgir_z %d \tacx %d \tacy %d \tacz %d \n",temp,girx,giry,girz,acx,acy,acz);

/*
        for(j=0;j<muestras;j++)
        {

        temp=(0xFF&buff[0+14*j])<<8 | (0xFF&buff[1+14*j]);
        girx=(0xFF&buff[2+14*j])<<8 | (0xFF&buff[3+14*j]);
        giry=(0xFF&buff[4+14*j])<<8 | (0xFF&buff[5+14*j]);
        girz=(0xFF&buff[6+14*j])<<8 | (0xFF&buff[7+14*j]);
        acx=(0xFF&buff[8+14*j])<<8  | (0xFF&buff[9+14*j]);
        acy=(0xFF&buff[10+14*j])<<8 | (0xFF&buff[11+14*j]);
        acz=(0xFF&buff[12+14*j])<<8 | (0xFF&buff[13+14*j]);


        fprintf(fp_log,"temp %.2f\t",((float)temp)/340+36.53);  
        fprintf(fp_log,"gir x %.10f\t",(250/( (float)girx *32768)) );
        fprintf(fp_log,"gir y %.10f\t",(250/( (float)giry *32768)) );
        fprintf(fp_log,"gir z %.10f\t",(250/( (float)girz*32768)) );
        fprintf(fp_log,"acx %.2f\t",(float)acx * ARES_2G);
        fprintf(fp_log,"acy %.2f\t",(float)acy * ARES_2G);
        fprintf(fp_log,"acz %.2f\n",(float)acz * ARES_2G);
        fprintf(fp_log_x,"temp %x\t gir_x %x\t gir_y %x\t gir_z %x\t acx %x\t acy %x\t acz %x\n",temp,girx,giry,girz,acx,acy,acz);
        }
        */
        //rewind(fp_log_x);
        //rewind(fp_log);

    }

    fclose(fp_log);
    fclose(fp_log_x);
    close(fp);
    return 0;
}

