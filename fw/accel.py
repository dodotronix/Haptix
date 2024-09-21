#!/usr/bin/python

import os
os.environ['BLINKA_FT232H'] = "1"

import board
import digitalio
import logging as log
import busio

from time import sleep
import adafruit_mpu6050

log.basicConfig(format='%(asctime)s %(levelname)s: %(message)s', 
        datefmt='%m/%d/%Y %I:%M:%S %p',level=log.INFO)

if __name__ == '__main__':
    mpu = adafruit_mpu6050.MPU6050(i2c)

    while True:
        print("Acceleration: X:%.2f, Y: %.2f, Z: %.2f m/s^2"%(mpu.acceleration))
        print("Gyro X:%.2f, Y: %.2f, Z: %.2f degrees/s"%(mpu.gyro))
        print("Temperature: %.2f C"%mpu.temperature)
        print("")
        sleep(1)
