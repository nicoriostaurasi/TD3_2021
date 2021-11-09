/**
 * @file NRT_file_operations.c
 * @author Nicolas Rios Taurasi (nicoriostaurasi@frba.utn.edu.ar)
 * @brief Archivo que contiene las funciones de open,close,read, write y ioctl.
 * @version 0.1
 * @date 03-11-2021
 * 
 * @copyright Copyright (c) 2021
 * 
 */


/**
 * @brief Funcion de Open configura el modulo y el bus de I2C
 * 
 * @param inode 
 * @param filp 
 * @return int 
 */
static int td3_i2c_open(struct inode *inode, struct file *filp)
{
    static uint32_t aux;    
    uint8_t reg[2];

    pr_info("[OPEN] LOG: TD3_I2C Open Device...\n");

    //Configuro registros como dice el manual

    //Apago el modulo
    aux=0x00;
    iowrite32(aux, I2C2_Base + I2C_CON);

    //Pre Escaler para 12MHz de clock
    aux=0x01;       //  >>1
    iowrite32(aux, I2C2_Base + I2C_PSC);

    //I2C clock para 100Kbps 
    //(1/12)*(SCLL+7) = 5uS
    aux=53;
    iowrite32(aux, I2C2_Base + I2C_SCLL);

    //(1/12)*(SCLH+5) = 5uS
    aux=55;
    iowrite32(aux, I2C2_Base + I2C_SCLH);

    //Direccion propia (OWN ADDRESS)
    aux=0xAA; //direccion cualquiera
    iowrite32(aux, I2C2_Base + I2C_OA);

    //Configurar Direccion del Esclavo y Contadores de DATA
    iowrite32(MPU6050_ADDRESS, I2C2_Base + I2C_SA);

    //Sacarlo del reset y Configurar I2C mode reg
    aux=0x8400; //bit 15 1h => I2C_EN |  bit 10 1h => Master Mode
    iowrite32(aux,I2C2_Base + I2C_CON);

    //Configuro el MPU6050

    // Initialize MPU6050 device
    reg[0]=0x75;
    I2C_Write_n_Bytes(reg,1);  
    
    I2C_Read_n_Bytes(reg,1);
    pr_info("[OPEN] LOG: TD3_I2C Who I Am 0x%x\n",reg[0]);

    MPU6050_init();

    pr_info("[OPEN] LOG: TD3_I2C Open OK!\n");

    return 0;

}

/**
 * @brief Funcion de close, limpia los registros
 * 
 * @param inode 
 * @param filp 
 * @return int 
 */
static int td3_i2c_close(struct inode *inode, struct file *filp)
{

    pr_info("[CLOSE] LOG: TD3_I2C Cerrando el dispositivo...\n");
    iowrite32(0x0000, I2C2_Base + I2C_CON);
    iowrite32(0x00, I2C2_Base + I2C_PSC);
    iowrite32(0x00, I2C2_Base + I2C_SCLL);
    iowrite32(0x00, I2C2_Base + I2C_SCLH);
    iowrite32(0x00, I2C2_Base + I2C_OA);
    pr_info("[CLOSE] LOG: TD3_I2C Close OK!\n");

    return 0;
}

/**
 * @brief Funcion de lectura, lee los registros de data
 * 
 * @param filep 
 * @param buffer 
 * @param len 
 * @param offset 
 * @return ssize_t 
 */
static ssize_t td3_i2c_read(struct file *filep, char *buffer, size_t len, loff_t *offset)
{
    uint32_t data_count_aux=0;
    uint8_t intento=0;
    uint8_t* data_buffer;
    uint8_t* data_aux;
    uint8_t cantidad_contenedores;
    int k=0;
    uint16_t* vector_muestras;
    int32_t copy2user;
    data_aux=kmalloc(2*sizeof(uint8_t),GFP_KERNEL);

    if(data_aux == NULL)
    {
        pr_err("[READ] Error: No se puede asignar memoria dinamica para el buffer\n");
        return -1;
    }

    if((len%14) != 0)
    {
        pr_err("[READ] Error: El usuario pidio un tamaño invalido, sobran %d bytes\n",(int)len%14);
        return -1;
    }

    cantidad_contenedores=(uint8_t)(len/1022);

    if(len%1022 != 0)
    {   
        cantidad_contenedores++;
    }   

    vector_muestras = kmalloc(cantidad_contenedores*sizeof(uint16_t),GFP_KERNEL);

    if(vector_muestras==NULL)
    {
        return -1;
    }

    vector_muestras[0]=len;
    
    if(cantidad_contenedores>1)
    {
        vector_muestras[0]=1022;
    }
    for(k=1;k<(cantidad_contenedores-1);k++)
    {
        vector_muestras[k]=1022;
    }
    if(len%1022 != 0)
    {
        vector_muestras[cantidad_contenedores-1]=(int)len%1022;
    }
    else 
    {
        vector_muestras[cantidad_contenedores-1]=1022;
    }

    data_buffer=kmalloc(len*sizeof(uint8_t),GFP_KERNEL);

    if(data_buffer == NULL)
    {
        pr_err("[READ] Error: No se puede asignar memoria dinamica para el buffer\n");
        return -1;
    }


/*    for(k=0;k<cantidad_contenedores;k++)
    {

    pr_info("%d\t",vector_muestras[k]);
    }*/

    data_aux[0]=MPU6050_RA_USER_CTRL;   
    data_aux[1]=0x44;                 
    I2C_Write_n_Bytes(data_aux,2);

    for(k=0;k<cantidad_contenedores;k++)
    {
        do
        {   
            intento++;
            pr_info("[READ] LOG: Intento de Leer FIFO N:%d\n",intento);
            data_count_aux=(uint32_t)MPU6050_Read_Data_Count_Fifo();
            pr_info("[READ] LOG: Tam FIFO %d Tam Lectura %d\n",2*data_count_aux,vector_muestras[k]);
        }
        while(data_count_aux<(vector_muestras[k]/2));
        
        intento=0;

        *data_aux=MPU6050_RA_FIFO_R_W;
        I2C_Write_n_Bytes(data_aux,1);
        I2C_Read_n_Bytes(&data_buffer[1022*k],vector_muestras[k]);

        pr_info("Lectura TEM 0x%x\n",data_buffer[0]<<8 | data_buffer[1]);
        pr_info("Lectura G_X 0x%x\n",data_buffer[2]<<8 | data_buffer[3]);
        pr_info("Lectura G_Y 0x%x\n",data_buffer[4]<<8 | data_buffer[5]);
        pr_info("Lectura G_Z 0x%x\n",data_buffer[6]<<8 | data_buffer[7]);
        pr_info("Lectura ACX 0x%x\n",data_buffer[8]<<8 | data_buffer[9]);
        pr_info("Lectura ACY 0x%x\n",data_buffer[10]<<8 | data_buffer[11]);
        pr_info("Lectura ACZ 0x%x\n",data_buffer[12]<<8 | data_buffer[13]);

    }
    
    copy2user=copy_to_user(buffer, data_buffer, len*sizeof(uint8_t));

    if(copy2user<0)
    {
        return -1;
    }

    kfree(vector_muestras);
    kfree(data_aux);
    kfree(data_buffer);

    return len;
}

/**
 * @brief Funcion de write, no utilizada
 * 
 * @param filep 
 * @param buffer 
 * @param len 
 * @param offset 
 * @return ssize_t 
 */
static ssize_t td3_i2c_write(struct file *filep, const char *buffer, size_t len, loff_t *offset)
{
    return 0;
}

/**
 * @brief Funcion de ioctl, no utilizada
 * 
 * @param filp 
 * @param cmd 
 * @param arg 
 * @return long 
 */
static long td3_i2c_ioctl(struct file *filp, unsigned int cmd, unsigned long arg)
{
    uint8_t vector_comandos[2];
    uint8_t aux;

    switch(cmd)
    {
        case AC_2G:
        {
            vector_comandos[0]=MPU6050_RA_ACCEL_CONFIG; 
            I2C_Write_n_Bytes(vector_comandos,1);
            I2C_Read_n_Bytes(vector_comandos,1);
            aux=vector_comandos[0];
            vector_comandos[0]=MPU6050_RA_ACCEL_CONFIG;
            vector_comandos[1]=(aux | 0x00 << 3); 
            I2C_Write_n_Bytes(vector_comandos,2);
            break;
        }
        case AC_4G:
        {
            vector_comandos[0]=MPU6050_RA_ACCEL_CONFIG; 
            I2C_Write_n_Bytes(vector_comandos,1);
            I2C_Read_n_Bytes(vector_comandos,1);
            aux=vector_comandos[0];
            vector_comandos[0]=MPU6050_RA_ACCEL_CONFIG;
            vector_comandos[1]=(aux | 0x01 << 3); 
            I2C_Write_n_Bytes(vector_comandos,2);
            break;
        }
        case AC_8G:
        {
            vector_comandos[0]=MPU6050_RA_ACCEL_CONFIG; 
            I2C_Write_n_Bytes(vector_comandos,1);
            I2C_Read_n_Bytes(vector_comandos,1);
            aux=vector_comandos[0];
            vector_comandos[0]=MPU6050_RA_ACCEL_CONFIG;
            vector_comandos[1]=(aux | 0x02 << 3); 
            I2C_Write_n_Bytes(vector_comandos,2);
            break;
        }
        case AC_16G:
        {
            vector_comandos[0]=MPU6050_RA_ACCEL_CONFIG; 
            I2C_Write_n_Bytes(vector_comandos,1);
            I2C_Read_n_Bytes(vector_comandos,1);
            aux=vector_comandos[0];
            vector_comandos[0]=MPU6050_RA_ACCEL_CONFIG;
            vector_comandos[1]=(aux | 0x03 << 3); 
            I2C_Write_n_Bytes(vector_comandos,2);
            break;
        }
        case GY_250:
        {
            vector_comandos[0]=MPU6050_RA_GYRO_CONFIG; 
            I2C_Write_n_Bytes(vector_comandos,1);
            I2C_Read_n_Bytes(vector_comandos,1);
            aux=vector_comandos[0];
            vector_comandos[0]=MPU6050_RA_GYRO_CONFIG;
            vector_comandos[1]=(aux | 0x00 << 3); 
            I2C_Write_n_Bytes(vector_comandos,2);
            break;
        }
        case GY_500:
        {
            vector_comandos[0]=MPU6050_RA_GYRO_CONFIG; 
            I2C_Write_n_Bytes(vector_comandos,1);
            I2C_Read_n_Bytes(vector_comandos,1);
            aux=vector_comandos[0];
            vector_comandos[0]=MPU6050_RA_GYRO_CONFIG;
            vector_comandos[1]=(aux | 0x01 << 3); 
            I2C_Write_n_Bytes(vector_comandos,2);
            break;
        }
        case GY_1000:
        {
            vector_comandos[0]=MPU6050_RA_GYRO_CONFIG; 
            I2C_Write_n_Bytes(vector_comandos,1);
            I2C_Read_n_Bytes(vector_comandos,1);
            aux=vector_comandos[0];
            vector_comandos[0]=MPU6050_RA_GYRO_CONFIG;
            vector_comandos[1]=(aux | 0x02 << 3); 
            I2C_Write_n_Bytes(vector_comandos,2);            
            break;
        }
        case GY_2000:
        {
            vector_comandos[0]=MPU6050_RA_GYRO_CONFIG; 
            I2C_Write_n_Bytes(vector_comandos,1);
            I2C_Read_n_Bytes(vector_comandos,1);
            aux=vector_comandos[0];
            vector_comandos[0]=MPU6050_RA_GYRO_CONFIG;
            vector_comandos[1]=(aux | 0x03 << 3); 
            I2C_Write_n_Bytes(vector_comandos,2);
            break;
        }
    }        
    return 0;
}
