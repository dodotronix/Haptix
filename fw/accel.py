#!/usr/bin/python

import os
os.environ['BLINKA_FT232H'] = "1"

import board
import digitalio
import logging as log
import numpy as np

from time import sleep
import adafruit_mpu6050

log.basicConfig(format='%(asctime)s %(levelname)s: %(message)s', 
        datefmt='%m/%d/%Y %I:%M:%S %p',level=log.INFO)

if __name__ == '__main__':
    i2c = board.I2C()
    mpu = adafruit_mpu6050.MPU6050(i2c)
    # mpu.cycle_Rate = adafruit_mpu6050.Rate.CYCLE_5_HZ
    # mpu.sleep = False
    # mpu.cycle = True

    measured_acceleration = np.array([[0, 0, 0]])

    try:
        while True:
            measured_acceleration = np.append(measured_acceleration, [[mpu.acceleration[0], mpu.acceleration[1], mpu.acceleration[2]]], axis=0)
            sleep(0.2)
            # print("Acceleration: X:%.2f, Y: %.2f, Z: %.2f m/s^2"%(mpu.acceleration))
            # print("Gyro X:%.2f, Y: %.2f, Z: %.2f degrees/s"%(mpu.gyro))
            # print("Temperature: %.2f C"%mpu.temperature)
            # print("")
    except KeyboardInterrupt:
        np.savetxt('measured_acceleration.txt', measured_acceleration, fmt='%.5f')
