#ifndef ADXL345_H
#define ADXL345_H

#define I2C_DEVICE_0 "/dev/i2c-0"
#define I2C_DEVICE_1 "/dev/i2c-1"
#define I2C_DEVICE_2 "/dev/i2c-2"

#define ADXL345_ADDR_LOW 0x53
#define ADXL345_ADDR_HIGH 0x1d

/* Used with register 0x2C (ADXL345_REG_BW_RATE) to set bandwidth */
typedef enum
{
  ADXL345_DATARATE_3200_HZ = 0xf, // 1600Hz Bandwidth 140µA IDD
  ADXL345_DATARATE_1600_HZ = 0xe, // 800Hz Bandwidth 90µA IDD
  ADXL345_DATARATE_800_HZ  = 0xd, // 400Hz Bandwidth 140µA IDD
  ADXL345_DATARATE_400_HZ  = 0xc, // 200Hz Bandwidth 140µA IDD
  ADXL345_DATARATE_200_HZ  = 0xb, // 100Hz Bandwidth 140µA IDD
  ADXL345_DATARATE_100_HZ  = 0xa, // 50Hz Bandwidth 140µA IDD
  ADXL345_DATARATE_50_HZ   = 0x9, // 25Hz Bandwidth 90µA IDD
  ADXL345_DATARATE_25_HZ   = 0x8, // 12.5Hz Bandwidth 60µA IDD
  ADXL345_DATARATE_12_5_HZ = 0x7, // 6.25Hz Bandwidth 50µA IDD
  ADXL345_DATARATE_6_25HZ  = 0x6, // 3.13Hz Bandwidth 45µA IDD
  ADXL345_DATARATE_3_13_HZ = 0x5, // 1.56Hz Bandwidth 40µA IDD
  ADXL345_DATARATE_1_56_HZ = 0x4, // 0.78Hz Bandwidth 34µA IDD
  ADXL345_DATARATE_0_78_HZ = 0x3, // 0.39Hz Bandwidth 23µA IDD
  ADXL345_DATARATE_0_39_HZ = 0x2, // 0.20Hz Bandwidth 23µA IDD
  ADXL345_DATARATE_0_20_HZ = 0x1, // 0.10Hz Bandwidth 23µA IDD
  ADXL345_DATARATE_0_10_HZ = 0x0  // 0.05Hz Bandwidth 23µA IDD (default value)
} adxl345_datarate;

typedef struct {
  int x;
  int y;
  int z;
} three_d_space;

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

void adxl345_init(char *device, char sdo, adxl345_datarate rate);
void adxl345_default_init(void);
three_d_space* adxl345_get_acceleration(void);
void adxl345_finish(void);

#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif // ADXL345_H





//-----------------------------------



#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <linux/i2c-dev.h>


#define BW_RATE     0x2c
#define POWER_CTL   0x2d
#define INT_SOURCE  0x30
#define DATA_FORMAT 0x31
#define DATAX0      0x32

#define DATA_READY 0x80

static int fd;

static int adxl345_open(char *device, char sdo)
{
  if ((fd = open(device, O_RDWR)) < 0) {
    printf("Faild to open i2c port\n");
    exit(1);
  }

  if (ioctl(fd, I2C_SLAVE, sdo) < 0) {
    printf("Unable to get bus access to talk to slave\n");
    exit(1);
  }

  return fd;
}

static void adxl345_write(unsigned char addr, unsigned char data)
{
  unsigned char buf[2];

  buf[0] = addr;
  buf[1] = data;

  if (write(fd, buf, 2) != 2) {
    fprintf(stderr, "Error writing to i2c slave\n");
    exit(1);
  }
}

static void adxl345_read(unsigned char addr, int num_byte, unsigned char *data)
{
  int i;

  for (i = 0; i < num_byte; ++i, ++addr) {
    /* write address */
    if (write(fd, &addr, 1) != 1) {
      fprintf(stderr, "Error writing to i2c slave\n");
      exit(1);
    }

    /* read data */
    if (read(fd, &data[i], 1) != 1) {
      fprintf(stderr, "Error reading from i2c slave\n");
      exit(1);
    }
  }
}

void adxl345_init(char *device, char sdo, adxl345_datarate rate)
{
  adxl345_open(device, sdo);
  adxl345_write(POWER_CTL, 0x08); // ?????
  adxl345_write(DATA_FORMAT, 0x03); // 16g
  adxl345_write(BW_RATE, rate); 
}

void adxl345_default_init(void)
{
  adxl345_init(I2C_DEVICE_0, ADXL345_ADDR_LOW, ADXL345_DATARATE_12_5_HZ);
}

three_d_space* adxl345_get_acceleration(void)
{
  static three_d_space acceleration;
  unsigned char values[6];

  for (values[0] = 0; !(values[0] & DATA_READY); ) {
    adxl345_read(INT_SOURCE, 1, values);
  }

  adxl345_read(DATAX0, 6, values);

  acceleration.x  = ((int) values[1] << 8) | (int) values[0];
  acceleration.y  = ((int) values[3] << 8) | (int) values[2];
  acceleration.z  = ((int) values[5] << 8) | (int) values[4];

  return &acceleration;
}

void adxl345_finish(void)
{
  close(fd);
}
