/**
 * @file NRT_mpu_6050.c
 * @author Nicolas Rios Taurasi (nicoriostaurasi@frba.utn.edu.ar)
 * @brief Funciones de utilidad para el sensor
 * @version 0.1
 * @date 03-11-2021
 * 
 * @copyright Copyright (c) 2021
 * 
 */

/**
 * @brief Funcion de Inicialización del modulo
 * 
 */
static void MPU6050_init(void)
{
    uint8_t aux=0;
    uint8_t buffer[2];

    buffer[0]=MPU6050_RA_PWR_MGMT_1;  //Salgo sleep mode y habilito los sensores 
    buffer[1]=0x00;
    I2C_Write_n_Bytes(buffer,2);

    msleep(100); 

    buffer[0]=MPU6050_RA_PWR_MGMT_1; // Seteo la fuente de clock com pll del giroscopo
    buffer[1]=0x01;
    I2C_Write_n_Bytes(buffer,2);

    // Configure Gyro and Accelerometer

    //Configuro gyro y acacelerometro 1khz
    buffer[0]=MPU6050_RA_CONFIG;
    buffer[1]=0x03;
    I2C_Write_n_Bytes(buffer,2);

    // Seteo el tiempo de muestra gyroscope output rate/(1 + SMPLRT_DIV)
    buffer[0]=MPU6050_RA_SMPLRT_DIV;    // 200Hz
    buffer[1]=0x04;
    I2C_Write_n_Bytes(buffer,2);

    // Seteo el gyroscopo a escala maxima
    buffer[0]=MPU6050_RA_GYRO_CONFIG; 
    I2C_Write_n_Bytes(buffer,1);

    I2C_Read_n_Bytes(buffer,1);
    aux=buffer[0];
    buffer[0]=MPU6050_RA_GYRO_CONFIG; // limpio self-test bits [7:5]
    buffer[1]=(aux & ~0xE0);
    I2C_Write_n_Bytes(buffer,2);

    buffer[0]=MPU6050_RA_GYRO_CONFIG; // limpio AFS bits [4:3]
    buffer[1]=(aux & ~0x18);
    I2C_Write_n_Bytes(buffer,2);

    buffer[0]=MPU6050_RA_GYRO_CONFIG; 
    buffer[1]=(aux | Gscale << 3);    // Seteo a maxima escala
    I2C_Write_n_Bytes(buffer,2);

   // Seteo el acelerometro
    buffer[0]=MPU6050_RA_ACCEL_CONFIG;
    I2C_Write_n_Bytes(buffer,1);

    I2C_Read_n_Bytes(buffer,1);
    aux=buffer[0];
    buffer[0]=MPU6050_RA_ACCEL_CONFIG;
    buffer[1]=(aux & ~0xE0);  // limpio self-test bits [7:5] 
    I2C_Write_n_Bytes(buffer,2);

    buffer[0]=MPU6050_RA_ACCEL_CONFIG;
    buffer[1]=(aux & ~0x18);     // limpio AFS bits [4:3]
    I2C_Write_n_Bytes(buffer,2);

    buffer[0]=MPU6050_RA_ACCEL_CONFIG;
    buffer[1]=(aux | Ascale << 3);// Seteo a maxima escala el acelerometro 
    I2C_Write_n_Bytes(buffer,2);

   // Interrupciones y bypass
    buffer[0]=MPU6050_RA_INT_PIN_CFG;
    buffer[1]=0x02;
    I2C_Write_n_Bytes(buffer,2);

    buffer[0]=MPU6050_RA_INT_ENABLE; 
    buffer[1]=0x01;
    I2C_Write_n_Bytes(buffer,2);

    // Habilito FIFO
    buffer[0]=MPU6050_RA_USER_CTRL;
    I2C_Write_n_Bytes(buffer,1);

    I2C_Read_n_Bytes(buffer,1);
    aux=buffer[0];
    buffer[0]=MPU6050_RA_USER_CTRL; 
    buffer[1]=(aux|0x44);
    I2C_Write_n_Bytes(buffer,2);

    buffer[0]=MPU6050_RA_USER_CTRL; 
    I2C_Write_n_Bytes(buffer,1);
    I2C_Read_n_Bytes(buffer,1);
    aux=buffer[0];

    pr_info("[LOG USER CONTROL]0x%x\n",aux);

    // Habilito los sensores hacia la FIFO
    buffer[0]=MPU6050_RA_FIFO_EN;   
    buffer[1]=0xF8;                 
    I2C_Write_n_Bytes(buffer,2);

    buffer[0]=MPU6050_RA_FIFO_EN; 
    I2C_Write_n_Bytes(buffer,1);
    I2C_Read_n_Bytes(buffer,1);
    aux=buffer[0];

    pr_info("[LOG RA FIFO EN]0x%x\n",aux);
}

/**
 * @brief Funcion de lectura de los registros de data de la fifo
 * 
 * @return uint16_t 
 */
static uint16_t MPU6050_Read_Data_Count_Fifo(void)
{
    uint16_t contador;
    uint8_t* buffer_tx;

    buffer_tx=kmalloc(sizeof(uint8_t),GFP_KERNEL);

    if(buffer_tx == NULL)
    {
        return -1;
    }

    *buffer_tx=MPU6050_RA_FIFO_COUNTH; 
    I2C_Write_n_Bytes(buffer_tx,1);
    I2C_Read_n_Bytes(buffer_tx,1);
    pr_info("[LOG Count H]0x%x\n",*buffer_tx);

    contador=*buffer_tx;


    *buffer_tx=MPU6050_RA_FIFO_COUNTL; 
    I2C_Write_n_Bytes(buffer_tx,1);
    I2C_Read_n_Bytes(buffer_tx,1);
    pr_info("[LOG Count L]0x%x\n",*buffer_tx);

    contador=contador<<8 | *buffer_tx;

    kfree(buffer_tx);

    return contador;

}
