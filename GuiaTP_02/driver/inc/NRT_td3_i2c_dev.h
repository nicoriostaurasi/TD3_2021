#include <asm-generic/errno.h>
#include <asm-generic/errno-base.h>
#include <linux/cdev.h>              
#include <linux/fs.h>               
#include <linux/module.h>           
#include <linux/uaccess.h>          
#include <linux/of_address.h>       
#include <linux/platform_device.h>  
#include <linux/of.h>               
#include <linux/io.h>               
#include <linux/interrupt.h>        
#include <linux/delay.h>            
#include <linux/types.h>            
#include <linux/init.h>             
#include <linux/kdev_t.h>
#include <linux/device.h>
#include <linux/version.h>
#include <linux/kernel.h>
#include <linux/of_platform.h>
#include <linux/wait.h>
#include <linux/slab.h>

#define BASEMINOR       0
#define COUNT           1
#define CLASS           "NRT_td3_i2c_class"
#define DEVICE_PARENT   NULL
#define DRVDATA         NULL
#define NAME            "NRT_td3_i2c_dev"

//Init y Exit
static int __init i2c_init(void);
static void __exit i2c_exit(void);
static int change_permission_cdev(struct device *dev,struct kobj_uevent_env *env);


//Platform device
static int td3_i2c_probe(struct platform_device* i2c_pd);
static int td3_i2c_remove(struct platform_device* i2c_pd);
irqreturn_t I2C_IRQ_Handler(int IRQ, void *ID, struct pt_regs *REG);

//File operations
static int td3_i2c_open(struct inode *inode, struct file *filp);
static int td3_i2c_close(struct inode *inode, struct file *filp);
static ssize_t td3_i2c_read(struct file *filep, char *buffer, size_t len, loff_t *offset);
static ssize_t td3_i2c_write(struct file *filep, const char *buffer, size_t len, loff_t *offset);
static long td3_i2c_ioctl(struct file *filp, unsigned int cmd, unsigned long arg);
static void I2C_Write_n_Bytes(uint8_t* data,uint8_t data_size);
static uint8_t I2C_Read_n_Bytes(uint8_t* data,uint32_t data_size);
static void MPU6050_init(void);
static uint16_t MPU6050_Read_Data_Count_Fifo(void);



//Pdevices
static void __iomem *I2C2_Base, *CM_PER_Base, *CTRL_MODULE_Base;
int virq;
uint8_t* I2C_data_tx;
uint8_t* I2C_data_rx;
uint8_t I2C_data_rx_length=0;
uint8_t I2C_data_tx_length=0;
uint8_t data_tx_now=0;
uint8_t data_rx_now=0;

//Fops
int Gscale = 0;
int Ascale = 0;
int Aaxis = 1;
enum MeasureState{AC_X,AC_Y,AC_Z,TEMP,GY_X,GY_Y,GY_Z};
typedef enum MeasureState MeasureState;
MeasureState MState;
enum ioctl_state{AC_2G,AC_4G,AC_8G,AC_16G,GY_250,GY_500,GY_1000,GY_2000};
typedef enum ioctl_state ioctl_state;
ioctl_state IOCState;

volatile int I2C_WK_Cond = 0;
wait_queue_head_t I2C_WK = __WAIT_QUEUE_HEAD_INITIALIZER(I2C_WK);


