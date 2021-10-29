//#include "../inc/NRT_td3_i2c_dev.h"

static int td3_i2c_open(struct inode *inode, struct file *filp)
{
    static uint32_t aux;    
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
    uint8_t reg[2];
    reg[0]=0x75;
    I2C_WriteByte(reg,1);  
    pr_info("[Who I Am] 0x%x\n",I2C_ReadByte());

    MPU6050_init();

    MState=AC_X;

    pr_info("[OPEN] LOG: TD3_I2C Open OK!\n");

    return 0;

}

static void MPU6050_init(void)
{
    uint8_t c=0;
    uint8_t buffer[2];

    buffer[0]=MPU6050_RA_PWR_MGMT_1; // Clear sleep mode bit (6), enable all sensors 
    buffer[1]=0x00;
    I2C_WriteByte(buffer,2);

    msleep(100); // Delay 100 ms for PLL to get established on x-axis gyro; should check for PLL ready interrupt  

    buffer[0]=MPU6050_RA_PWR_MGMT_1; // Set clock source to be PLL with x-axis gyroscope reference, bits 2:0 = 001 
    buffer[1]=0x01;
    I2C_WriteByte(buffer,2);

    // Configure Gyro and Accelerometer
    // Disable FSYNC and set accelerometer and gyro bandwidth to 44 and 42 Hz, respectively; 
    // DLPF_CFG = bits 2:0 = 010; this sets the sample rate at 1 kHz for both
    buffer[0]=MPU6050_RA_CONFIG;
    buffer[1]=0x03;
    I2C_WriteByte(buffer,2);

    // Set sample rate = gyroscope output rate/(1 + SMPLRT_DIV)
    buffer[0]=MPU6050_RA_SMPLRT_DIV;    // Use a 200 Hz sample rate
    buffer[1]=0x04;
    I2C_WriteByte(buffer,2);

    // Set gyroscope full scale range
    // Range selects FS_SEL and AFS_SEL are 0 - 3, so 2-bit values are left-shifted into positions 4:3
    buffer[0]=MPU6050_RA_GYRO_CONFIG; 
    I2C_WriteByte(buffer,1);

    c =  I2C_ReadByte();
    buffer[0]=MPU6050_RA_GYRO_CONFIG; // Clear self-test bits [7:5]
    buffer[1]=(c & ~0xE0);
    I2C_WriteByte(buffer,2);

    buffer[0]=MPU6050_RA_GYRO_CONFIG; // Clear AFS bits [4:3]
    buffer[1]=(c & ~0x18);
    I2C_WriteByte(buffer,2);

    buffer[0]=MPU6050_RA_GYRO_CONFIG; // Clear AFS bits [4:3]
    buffer[1]=(c | Gscale << 3);    // Set full scale range for the gyro
    I2C_WriteByte(buffer,2);

   // Set accelerometer configuration
    buffer[0]=MPU6050_RA_ACCEL_CONFIG;
    I2C_WriteByte(buffer,1);

    c=I2C_ReadByte();

    buffer[0]=MPU6050_RA_ACCEL_CONFIG;
    buffer[1]=(c & ~0xE0);  // Clear self-test bits [7:5] 
    I2C_WriteByte(buffer,2);

    buffer[0]=MPU6050_RA_ACCEL_CONFIG;
    buffer[1]=(c & ~0x18);     // Clear AFS bits [4:3]
    I2C_WriteByte(buffer,2);

    buffer[0]=MPU6050_RA_ACCEL_CONFIG;
    buffer[1]=(c | Ascale << 3);// Set full scale range for the accelerometer 
    I2C_WriteByte(buffer,2);

   // Configure Interrupts and Bypass Enable
   // Set interrupt pin active high, push-pull, and clear on read of INT_STATUS, enable I2C_BYPASS_EN so additional chips 
   // can join the I2C bus and all can be controlled by the Arduino as master
    buffer[0]=MPU6050_RA_INT_PIN_CFG;
    buffer[1]=0x02;
    I2C_WriteByte(buffer,2);

    buffer[0]=MPU6050_RA_INT_ENABLE; // Enable data ready (bit 0) interrupt
    buffer[1]=0x01;
    I2C_WriteByte(buffer,2);
}

static void I2C_WriteByte(uint8_t* data,uint8_t data_length)
{
    uint32_t i = 0;
    uint32_t reg_value = 0;
    uint32_t status = 0;

    pr_info("[WRITE_B] LOG: TD3_I2C Enviado Byte\n");

    // ---> byte transmission
    // Pooleo el bit de busy
    reg_value = ioread32(I2C2_Base + I2C_IRQSTATUS_RAW);

    while((reg_value >> 12) & 1)
    {
        msleep(100);
        pr_err("[WRITE_B] ERR: Bus ocupado\n");
        i++;
        if(i == 4)
        {
            pr_err("[WRITE_B] ERR: Bus ocupado, imposible enviar\n");
            return;
        }
    }

    // Cargo data
    I2C_data_tx=data;

    // Cargo data length
    I2C_data_tx_length=data_length;

    // Largo del dato N bytes
    iowrite32(I2C_data_tx_length, I2C2_Base + I2C_CNT);

    // Configuro como Master TX
    reg_value = ioread32(I2C2_Base + I2C_CON);
    reg_value |= 0x600;
    iowrite32(reg_value, I2C2_Base + I2C_CON);

    // Habilito Interrupcion por Tx
    iowrite32(XRDY_IE, I2C2_Base + I2C_IRQENABLE_SET);

    // START Bus Activity 0x01
    reg_value = ioread32(I2C2_Base + I2C_CON);
    reg_value |= I2C_CON_START;
    iowrite32(reg_value, I2C2_Base + I2C_CON);

    // Espero a que termine la transmision
    if((status = wait_event_interruptible(I2C_WK, I2C_WK_Cond > 0)) < 0)
    {
        I2C_WK_Cond=0;
        pr_err("[WRITE_B] ERR: TD3_I2C Error durmiendo por Interrupcion\n");
        return;
    }
    
    I2C_WK_Cond=0;

    pr_info("[WRITE_B] LOG: TD3_I2C TX OK!\n");
    

    // STOP Bus Activity 0x02
    reg_value = ioread32(I2C2_Base + I2C_CON);
    reg_value &= 0xFFFFFFFE;
    reg_value |= I2C_CON_STOP;
    iowrite32(reg_value, I2C2_Base + I2C_CON);
    
    msleep(1);

    pr_info("[WRITE_B] LOG: TD3_I2C Transmitido byte con Exito!\n");
}

static uint8_t I2C_ReadByte(void)
{
    uint32_t i = 0;
    uint32_t reg_value = 0;
    uint32_t status = 0;
    uint8_t newdata;

    pr_info("[WRITE_B] LOG: TD3_I2C Recibiendo Byte\n");

    // ---> byte transmission
    // Pooleo el bit de busy
    reg_value = ioread32(I2C2_Base + I2C_IRQSTATUS_RAW);
    
    while((reg_value >> 12) & 1)
    {
        msleep(100);
        pr_err("[WRITE_B] ERR: Bus ocupado\n");
        i++;
        if(i == 4)
        {
            pr_err("[WRITE_B] ERR: Bus ocupado, imposible recibir\n");
            return -1;
        }
    }



    // data lenght = 1 byte
    iowrite32(1, I2C2_Base + I2C_CNT);

    // Configuro como Master RX
    reg_value = ioread32(I2C2_Base + I2C_CON);
    reg_value = 0x8400; //bit 15 1h => I2C_EN |  bit 10 1h => Master Mode
    iowrite32(reg_value, I2C2_Base + I2C_CON);

    // Habilito Interrupcion por Rx
    iowrite32(RRDY_IE, I2C2_Base + I2C_IRQENABLE_SET);

    // START Bus Activity 0x01
    reg_value = ioread32(I2C2_Base + I2C_CON);
    reg_value &= 0xFFFFFFFC;
    reg_value |= I2C_CON_START;
    iowrite32(reg_value, I2C2_Base + I2C_CON);

    // Espero a que termine la recepcion
    if((status = wait_event_interruptible(I2C_WK, I2C_WK_Cond > 0)) < 0)
    {
        I2C_WK_Cond=0;
        pr_err("[READ_B] ERR: TD3_I2C Error durmiendo por Interrupcion\n");
        return status;
    }

    I2C_WK_Cond=0;

    pr_info("[WRITE_B] LOG: TD3_I2C RX OK!\n");

    // STOP Bus Activity 0x02
    reg_value = ioread32(I2C2_Base + I2C_CON);
    reg_value &= 0xFFFFFFFE;
    reg_value |= I2C_CON_STOP;
    iowrite32(reg_value, I2C2_Base + I2C_CON);

    newdata = I2C_data_rx;

    pr_info("[WRITE_B] LOG: TD3_I2C Recibido byte con Exito!\n");

    return newdata;
}


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

static ssize_t td3_i2c_read(struct file *filep, char *buffer, size_t len, loff_t *offset)
{
    uint32_t status = 0;
    uint8_t data_send_H[1] = {0};
    uint8_t data_send_L[1] = {0};
    uint16_t data_receive[2] = {0};
    int16_t data = 0;

    pr_info("[READ] LOG: TD3_I2C Leyendo el modulo \n");
    

    switch(MState)
    {
        case AC_X:
        {
            data_send_H[0]=MPU6050_RA_ACCEL_XOUT_H;
            data_send_L[0]=MPU6050_RA_ACCEL_XOUT_L;
            break;
        }
        case AC_Y:
        {
            data_send_H[0]=MPU6050_RA_ACCEL_YOUT_H;
            data_send_L[0]=MPU6050_RA_ACCEL_YOUT_L;
            break;
        }
        case AC_Z:
        {
            data_send_H[0]=MPU6050_RA_ACCEL_ZOUT_H;
            data_send_L[0]=MPU6050_RA_ACCEL_ZOUT_L;
            break;
        }
        case TEMP:
        {

            data_send_H[0]=MPU6050_RA_TEMP_OUT_H;
            data_send_L[0]=MPU6050_RA_TEMP_OUT_L;
            break;
        }
        case GY_X:
        {
            data_send_H[0]=MPU6050_RA_GYRO_XOUT_H;
            data_send_L[0]=MPU6050_RA_GYRO_XOUT_L;
            break;
        }
        case GY_Y:
        {
            data_send_H[0]=MPU6050_RA_GYRO_YOUT_H;
            data_send_L[0]=MPU6050_RA_GYRO_YOUT_L;
            break;
        }
        case GY_Z:
        {
            data_send_H[0]=MPU6050_RA_GYRO_ZOUT_H;
            data_send_L[0]=MPU6050_RA_GYRO_ZOUT_L;            
            break;
        }

    }


   // read the MSB of the accelerometer register 
   I2C_WriteByte(data_send_H,1);
   data_receive[0] = I2C_ReadByte();

   // read the LSB of the accelerometer register 
   I2C_WriteByte(data_send_L,1);
   data_receive[1] = I2C_ReadByte();

   // 16 bits data
   data = (uint16_t)(data_receive[0] << 8 | data_receive[1]);

   pr_info("[READ] Data recibida 0x%x\n",data);
//   pr_info("[READ] Data recibida %d\n",(data/340+36));
    

   status = copy_to_user(buffer, (const void *) &data, sizeof(data));

///   if(status != 0)
//   {

//      return -1;
  // }


   pr_info("[READ] LOG: TD3_I2C Read OK\n");



   return 2;
}

static ssize_t td3_i2c_write(struct file *filep, const char *buffer, size_t len, loff_t *offset)
{
    uint32_t status = 0;
    uint8_t data_usr;
    status = copy_from_user((void *) &data_usr, (const void *) buffer, sizeof(uint8_t));

//    pr_info("[WRITE] Usuario dijo: %d\n",data_usr);

    switch(data_usr)
    {
        case AC_X:
        {
            MState=AC_X;
            break;
        }
        case AC_Y:
        {
            MState=AC_Y;
            break;
        }
        case AC_Z:
        {
            MState=AC_Z;
            break;
        }
        case TEMP:
        {
            MState=TEMP;
            break;
        }
        case GY_X:
        {   
            MState=GY_X;
            break;
        }
        case GY_Y:
        {
            MState=GY_Y;
            break;
        }
        case GY_Z:
        {
            MState=GY_Z;
            break;
        }
        default:
        {   
            MState=MState;
            break;
        }

    }

}

static long td3_i2c_ioctl(struct file *filp, unsigned int cmd, unsigned long arg)
{

}