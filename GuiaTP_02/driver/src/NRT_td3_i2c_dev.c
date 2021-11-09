/**
 * @file NRT_td3_i2c_dev.c
 * @author Nicolas Rios Taurasi (nicoriostaurasi@frba.utn.edu.ar)
 * @brief Archivo principal del modulo, contiene el init y el exit
 * @version 0.1
 * @date 03-11-2021
 * 
 * @copyright Copyright (c) 2021
 * 
 */

#include "../inc/NRT_td3_i2c_dev.h"
#include "../inc/BBB_I2C_reg.h"
#include "../inc/MPU6050_reg.h"

#include "NRT_file_operations.c"
#include "NRT_globals.c"
#include "NRT_platform_device.c"
#include "NRT_mpu_6050.c"
#include "NRT_i2c_rw.c"

MODULE_LICENSE("Dual BSD/GPL");
MODULE_AUTHOR("Nicolas Rios Taurasi");
MODULE_VERSION("1.0");
MODULE_DESCRIPTION("Driver i2c");

/**
 * @brief Funcion de inicializacion
 * 
 * @return int 
 */
static int __init i2c_init(void)
{
    int estado=0;

    pr_info("[INIT] LOG: TD3_I2C Inicializando modulo...\n");
    
    //-------------------------------------------------------------------------------------
    //cdev_alloc
    state.TD3_I2C_CHAR_DEV=cdev_alloc();

    if(state.TD3_I2C_CHAR_DEV == NULL)
    {
        pr_err("[INIT] ERR: TD3_I2C fallo cdev_alloc() (%s %d)\n",__FUNCTION__,__LINE__);
        return -1;
    }
    
    pr_info("[INIT] LOG: TD3_I2C cdev_alloc() OK!\n");
    //-------------------------------------------------------------------------------------

    //alloc_chrdev_region    
    estado=alloc_chrdev_region(&state.TD3_I2C_DEV,BASEMINOR,COUNT,NAME);

    if(estado<0)
    {
        pr_err("[INIT] ERR: TD3_I2C fallo alloc_chrdev_region() %d (%s %d)\n",estado,__FUNCTION__,__LINE__);
        return estado;
    }

    pr_info("[INIT] LOG: TD3_I2C numero mayor asignado: %d 0x%x\n",MAJOR(state.TD3_I2C_DEV),MAJOR(state.TD3_I2C_DEV));
    pr_info("[INIT] LOG: TD3_I2C alloc_chrdev_region() OK!\n");
    //-------------------------------------------------------------------------------------

    //cdev_init - no arroja codigo de error es NULL
    cdev_init(state.TD3_I2C_CHAR_DEV,&TD3_FOPS);
    pr_info("[INIT] LOG: TD3_I2C cdev_init() OK!\n");
    //-------------------------------------------------------------------------------------

    //cdev_add
    estado=cdev_add(state.TD3_I2C_CHAR_DEV,state.TD3_I2C_DEV,COUNT);

    if(estado<0)
    {
        unregister_chrdev_region(state.TD3_I2C_DEV,COUNT);
        pr_err("[INIT] ERR: TD3_I2C fallo cdev_add() %d (%s %d)\n",estado,__FUNCTION__,__LINE__);
        return estado;
    }

    pr_info("[INIT] LOG: TD3_I2C cdev_add() OK!\n");
    //-------------------------------------------------------------------------------------

    //class_create
    state.TD3_I2C_DEV_CLASS=class_create(THIS_MODULE,CLASS);

    if(state.TD3_I2C_DEV_CLASS==NULL)
    {        
        cdev_del(state.TD3_I2C_CHAR_DEV);
        unregister_chrdev_region(state.TD3_I2C_DEV,COUNT);
        pr_err("[INIT] ERR: TD3_I2C fallo class_create() (%s %d)\n",__FUNCTION__,__LINE__);
        return -1;
    }

    pr_info("[INIT] LOG: TD3_I2C class_create() OK!\n");
    //-------------------------------------------------------------------------------------

    state.TD3_I2C_DEV_CLASS->dev_uevent = change_permission_cdev;

    //device_create
    if( (device_create(state.TD3_I2C_DEV_CLASS,DEVICE_PARENT,state.TD3_I2C_DEV,DRVDATA,NAME))==NULL)
    {
        cdev_del(state.TD3_I2C_CHAR_DEV);
        unregister_chrdev_region(state.TD3_I2C_DEV,COUNT);
        device_destroy(state.TD3_I2C_DEV_CLASS,state.TD3_I2C_DEV);
        pr_err("[INIT] ERR: TD3_I2C fallo device_create() (%s %d)\n",__FUNCTION__,__LINE__);
        return -1;
    }

    pr_info("[INIT] LOG: TD3_I2C device_create() OK!\n");
    //-------------------------------------------------------------------------------------

    //platform_driver_register
    estado=platform_driver_register(&TD3_PLAT_DRIVER);

    if(estado<0)
    {   
        cdev_del(state.TD3_I2C_CHAR_DEV);
        unregister_chrdev_region(state.TD3_I2C_DEV,COUNT);
        device_destroy(state.TD3_I2C_DEV_CLASS,state.TD3_I2C_DEV);
        class_destroy(state.TD3_I2C_DEV_CLASS);
        pr_err("[INIT] ERR: TD3_I2C fallo platform_driver_register() %d (%s %d)\n",estado,__FUNCTION__,__LINE__);
        return estado;
    }
    pr_info("[INIT] LOG: TD3_I2C platform_driver_register() OK!\n");
    //-------------------------------------------------------------------------------------


    pr_info("[INIT] LOG: TD3_I2C iniciado correctamente \\o/\n");
    return 0;
}

static int change_permission_cdev(struct device *dev,struct kobj_uevent_env *env)
{
    add_uevent_var(env,"DEVMODE=%#o",0666);
    return 0; 
}


/**
 * @brief Funcion de exit
 * 
 */
static void __exit i2c_exit(void)
{
    pr_info("[EXIT] LOG: TD3_I2C Removiendo modulo...\n");
    cdev_del(state.TD3_I2C_CHAR_DEV);
    pr_info("[EXIT] LOG: TD3_I2C cdev_del() OK!\n");

    unregister_chrdev_region(state.TD3_I2C_DEV,COUNT);
    pr_info("[EXIT] LOG: TD3_I2C unregister_chrdev_region() OK!\n");

    device_destroy(state.TD3_I2C_DEV_CLASS,state.TD3_I2C_DEV);
    pr_info("[EXIT] LOG: TD3_I2C device_destroy() OK!\n");

    class_destroy(state.TD3_I2C_DEV_CLASS);
    pr_info("[EXIT] LOG: TD3_I2C class_destroy() OK!\n");

    platform_driver_unregister(&TD3_PLAT_DRIVER);
    pr_info("[EXIT] LOG: TD3_I2C platform_driver_unregister() OK!\n");

    pr_info("[EXIT] LOG: TD3_I2C Modulo removido exitosamente =)\n");
}

module_init(i2c_init);
module_exit(i2c_exit);