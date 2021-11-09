/**
 * @file NRT_i2c_rw.c
 * @author Nicolas Rios Taurasi (nicoriostaurasi@frba.utn.edu.ar)
 * @brief Funciones de escritura y lectura hacia el sensor
 * @version 0.1
 * @date 03-11-2021
 * 
 * @copyright Copyright (c) 2021
 * 
 */


/**
 * @brief Funcion de escritura
 * 
 * @param data 
 * @param data_length 
 */
static void I2C_Write_n_Bytes(uint8_t* data,uint8_t data_length)
{
    uint32_t i = 0;
    uint32_t reg_value = 0;
    //uint32_t status = 0;

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
//    if((status = wait_event_interruptible(I2C_WK, I2C_WK_Cond > 0)) < 0)
//    {
//       I2C_WK_Cond=0;
//        pr_err("[WRITE_B] ERR: TD3_I2C Error durmiendo por Interrupcion\n");
//        return;
//    }
    wait_event(I2C_WK,I2C_WK_Cond>0);

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



/**
 * @brief Funcion de lectura
 * 
 * @param buffer_rx 
 * @param newdata_length 
 * @return uint8_t 
 */
static uint8_t I2C_Read_n_Bytes(uint8_t* buffer_rx,uint32_t newdata_length)
{
    uint32_t i = 0;
    uint32_t reg_value = 0;
    uint32_t status = 0;
//    uint8_t *newdata;

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

    I2C_data_rx_length=newdata_length;

    I2C_data_rx = kmalloc(I2C_data_rx_length*sizeof(uint8_t),GFP_KERNEL);

    if(I2C_data_tx == NULL)
    {
        pr_err("[WRITE_B] ERR: Imposible pedir memoria\n");
        return -1;
    }

    // data lenght = 1 byte
    iowrite32(I2C_data_rx_length, I2C2_Base + I2C_CNT);

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

    memcpy(buffer_rx,I2C_data_rx,I2C_data_rx_length);

    pr_info("[WRITE_B] LOG: TD3_I2C Recibido byte con Exito!\n");

    return I2C_data_rx_length;
}
