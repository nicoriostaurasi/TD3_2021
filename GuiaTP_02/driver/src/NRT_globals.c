/**
 * @file NRT_globals.c
 * @author Nicolas Rios Taurasi (nicoriostaurasi@frba.utn.edu.ar)
 * @brief Variables globales de utilidad
 * @version 0.1
 * @date 03-11-2021
 * 
 * @copyright Copyright (c) 2021
 * 
 */

static struct
{
  dev_t TD3_I2C_DEV;
  struct cdev *TD3_I2C_CHAR_DEV;
  struct device *TD3_I2C_DEVICE;
  struct class *TD3_I2C_DEV_CLASS;
} state;

static struct file_operations TD3_FOPS =
    {
        .owner = THIS_MODULE,
        .open = td3_i2c_open,
        .release = td3_i2c_close,
        .read = td3_i2c_read,
        .write = td3_i2c_write,
        .unlocked_ioctl = td3_i2c_ioctl};

static struct of_device_id i2c_of_device_ids[] =
    {
        {
            .compatible = NAME,
        },
        {}};

MODULE_DEVICE_TABLE(of, i2c_of_device_ids);

static struct platform_driver TD3_PLAT_DRIVER =
    {
        .probe = td3_i2c_probe,
        .remove = td3_i2c_remove,
        .driver =
            {
                .name = NAME,
                .of_match_table = of_match_ptr(i2c_of_device_ids),
            },
};
