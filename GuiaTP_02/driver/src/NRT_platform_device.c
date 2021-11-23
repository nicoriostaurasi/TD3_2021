/**
 * @file NRT_platform_device.c
 * @author Nicolas Rios Taurasi (nicoriostaurasi@frba.utn.edu.ar)
 * @brief Contiene el probe, el remove y el handler de interrupcion de I2C
 * @version 0.1
 * @date 03-11-2021
 * 
 * @copyright Copyright (c) 2021
 * 
 */

/**
 * @brief Configura el pdevice
 * 
 * @param i2c_pd 
 * @return int 
 */
static int td3_i2c_probe(struct platform_device *i2c_pd)
{
    uint32_t reg_value_aux;

    pr_info("[PROBE] LOG: TD3_I2C Entrando al probe...\n");

    //-------------------------------------------------------------------------------------
    //Mapeo I2C2
    I2C2_Base = ioremap(I2C2_REG, I2C2_REG_LEN);
    if (I2C2_Base == NULL)
    {
        pr_err("[PROBE] ERR: TD3_I2C No pudo mapearse I2C2\n");
        return 1;
    }
    pr_info("[PROBE] LOG: TD3_I2C I2C2_BASE = 0x%x\n", (uint32_t)I2C2_Base);
    //-------------------------------------------------------------------------------------
    //Mapeo CM_PER
    CM_PER_Base = ioremap(CM_PER_REG, CM_PER_REG_LEN);
    if (CM_PER_Base == NULL)
    {
        pr_err("[PROBE] ERR: TD3_I2C No pudo mapearse CM_PER\n");
        iounmap(I2C2_Base);
        return 1;
    }
    pr_info("[PROBE] LOG: TD3_I2C CM_PER = 0x%x\n", (uint32_t)CM_PER_Base);
    //-------------------------------------------------------------------------------------
    //Mapeo CTRL_MODULE
    CTRL_MODULE_Base = ioremap(CTRL_MODULE_REG, CTRL_MODULE_REG_LEN);
    if (CTRL_MODULE_Base == NULL)
    {
        pr_err("[PROBE] ERR: TD3_I2C No pudo mapearse CTRL_MODULE\n");
        iounmap(I2C2_Base);
        iounmap(CM_PER_Base);
        return 1;
    }
    pr_info("[PROBE] LOG: TD3_I2C CTRL_MODULE = 0x%x\n", (uint32_t)CTRL_MODULE_Base);

    //-------------------------------------------------------------------------------------
    //Habilito Clock
    //Pagina 1270
    reg_value_aux = ioread32(CM_PER_Base + CM_PER_I2C2_CLKCTRL);
    reg_value_aux |= 0x02;
    iowrite32(reg_value_aux, CM_PER_Base + CM_PER_I2C2_CLKCTRL);
    msleep(100);

    reg_value_aux = 0x0;
    reg_value_aux = ioread32(CM_PER_Base + CM_PER_I2C2_CLKCTRL);
    if ((reg_value_aux & 0x03) != 0x02)
    {
        pr_err("[PROBE] ERR: TD3_I2C No pudo habilitarse el clock del periferico\n");
        iounmap(I2C2_Base);
        iounmap(CM_PER_Base);
        iounmap(CTRL_MODULE_Base);
        return 1;
    }

    //-------------------------------------------------------------------------------------
    //Habilito Pines SDA y SCL
    //Pagina 1515
    //PIN 20 : UART1_Ctsn - I2C2_SDA
    reg_value_aux = ioread32(CTRL_MODULE_Base + CONF_UART1_CSTN);
    //Reserved | Fast | Receiver Enable | PullDown Selected | PullUp/Pulldown Enable | I2C2_SCL
    //    0       0             1               0                         0            011
    //0x23
    reg_value_aux = PIN_I2C_CFG;
    iowrite32(reg_value_aux, CTRL_MODULE_Base + CONF_UART1_CSTN);

    //PIN 19 : UART1_rtsn - I2C2_SCL
    reg_value_aux = ioread32(CTRL_MODULE_Base + CONF_UART1_RSTN);
    reg_value_aux = PIN_I2C_CFG;
    iowrite32(reg_value_aux, CTRL_MODULE_Base + CONF_UART1_RSTN);
    pr_info("[PROBE] LOG: TD3_I2C Configurado Clock y Pines SDA, SCL\n");

    //-------------------------------------------------------------------------------------
    virq = platform_get_irq(i2c_pd, 0);
    if (virq < 0)
    {
        pr_err("[PROBE] ERR: TD3_I2C No pudo obtener la virtual interrupt request\n");
        iounmap(I2C2_Base);
        iounmap(CM_PER_Base);
        iounmap(CTRL_MODULE_Base);
        return 1;
    }

    if (request_irq(virq, (irq_handler_t)I2C_IRQ_Handler, IRQF_TRIGGER_RISING, NAME, NULL))
    {
        pr_err("[PROBE] ERR: TD3_I2C No pudo asignar la virtual interrupt request\n");
        iounmap(I2C2_Base);
        iounmap(CM_PER_Base);
        iounmap(CTRL_MODULE_Base);
        return 1;
    }
    pr_info("[PROBE] LOG: TD3_I2C Configurada VIRQ con exito!\n");
    //-------------------------------------------------------------------------------------

    pr_info("[PROBE] LOG: TD3_I2C Finalizado el probe =)\n");

    return 0;
}

/**
 * @brief Libera los recursos
 * 
 * @param i2c_pd 
 * @return int 
 */
static int td3_i2c_remove(struct platform_device *i2c_pd)
{
    pr_info("[REMOVE] LOG: TD3_I2C Removiendo modulo...\n");

    free_irq(virq, NULL);
    pr_info("[REMOVE] LOG: TD3_I2C Removida IRQ\n");

    iounmap(I2C2_Base);
    pr_info("[REMOVE] LOG: TD3_I2C Liberada pagina de I2C\n");

    iounmap(CM_PER_Base);
    pr_info("[REMOVE] LOG: TD3_I2C Liberada pagina de CM_PER\n");

    iounmap(CTRL_MODULE_Base);
    pr_info("[REMOVE] LOG: TD3_I2C Liberada pagina de CTRL_MODULE\n");

    pr_info("[REMOVE] LOG: TD3_I2C Modulo removido con exito =)\n");
    return 0;
}

/**
 * @brief Handler de interrupción
 * 
 * @param IRQ 
 * @param ID 
 * @param REG 
 * @return irqreturn_t 
 */
irqreturn_t I2C_IRQ_Handler(int IRQ, void *ID, struct pt_regs *REG)
{
    static uint32_t status_aux, reg_aux;

    //    static uint32_t data_tx_now=0;

    //    pr_info("[I2C_IRQ] LOG: TD3_I2C Recibida Interrupcion\n");

    status_aux = ioread32(I2C2_Base + I2C_IRQSTATUS);

    if ((status_aux & RRDY_IE) == RRDY_IE) //Rx Interrupt
    {
        // pr_info("[I2C_IRQ] LOG: TD3_I2C Rx Interrupt\n");

        //Read Data
        I2C_data_rx[data_rx_now] = ioread8(I2C2_Base + I2C_DATA);
        data_rx_now++;

        if (data_rx_now == I2C_data_rx_length)
        {
            //Limpio Flags
            //GC-XRDY-RRDY-ARDY-NACK-AL
            //1 -  0 -  1 -  1 - 1  -0
            //0x2E
            reg_aux = ioread32(I2C2_Base + I2C_IRQSTATUS);
            reg_aux |= 0x2E;
            iowrite32(reg_aux, I2C2_Base + I2C_IRQSTATUS);

            //Limpio Interrupcion
            reg_aux = ioread32(I2C2_Base + I2C_IRQENABLE_CLR);
            reg_aux |= RRDY_IE;
            iowrite32(reg_aux, I2C2_Base + I2C_IRQENABLE_CLR);

            //       pr_info("[I2C_IRQ] LOG: TD3_I2C Rx Data 0x%x\n",I2C_data_rx);

            //Despierto proceso por RX
            I2C_WK_Cond = 1;
            wake_up_interruptible(&I2C_WK);
            data_rx_now = 0;
        }
    }

    if ((status_aux & XRDY_IE) == XRDY_IE) //Tx Interrupt
    {
        //      pr_info("[I2C_IRQ] LOG: TD3_I2C Tx Interrupt\n");

        //Write Data
        iowrite8(I2C_data_tx[data_tx_now], I2C2_Base + I2C_DATA);
        //    pr_info("[I2C_IRQ] LOG: TD3_I2C Tx Dato 0x%x\n",I2C_data_tx[data_tx_now]);

        data_tx_now++;

        if (data_tx_now == I2C_data_tx_length)
        {

            //Limpio Flags
            //GC-XRDY-RRDY-ARDY-NACK-AL
            //1 -  1 -  0 -  1 - 1  -0
            //0x36
            reg_aux = ioread32(I2C2_Base + I2C_IRQSTATUS);
            reg_aux |= 0x36;
            iowrite32(reg_aux, I2C2_Base + I2C_IRQSTATUS);

            //Limpio Interrupcion
            reg_aux = ioread32(I2C2_Base + I2C_IRQENABLE_CLR);
            reg_aux |= XRDY_IE;
            iowrite32(reg_aux, I2C2_Base + I2C_IRQENABLE_CLR);

            //Despierto proceso por TX
            I2C_WK_Cond = 1;
            //            wake_up_interruptible(&I2C_WK);
            wake_up(&I2C_WK);
            data_tx_now = 0;
        }
    }

    //Limpio el resto x las dudas
    status_aux = ioread32(I2C2_Base + I2C_IRQSTATUS);
    status_aux |= 0x6FFF;
    iowrite32(status_aux, I2C2_Base + I2C_IRQSTATUS);

    //    pr_info("[I2C_IRQ] LOG: TD3_I2C Handler Resuelto!\n");

    return IRQ_HANDLED;
}