#!/usr/bin/python

import os
os.environ['BLINKA_FT232H'] = "1"

import board
import busio
import digitalio
import logging as log
import numpy as np

import adafruit_mpu6050
from time import sleep
from math import ceil, floor
from datetime import datetime

log.basicConfig(format='%(asctime)s %(levelname)s: %(message)s', 
        datefmt='%m/%d/%Y %I:%M:%S %p',level=log.INFO)

def init_accelerometer():
    # accelerometer ranges
    cycle_rates = {"5": adafruit_mpu6050.Rate.CYCLE_5_HZ, 
             "20": adafruit_mpu6050.Rate.CYCLE_20_HZ,
             "40": adafruit_mpu6050.Rate.CYCLE_40_HZ,
             "125": adafruit_mpu6050.Rate.CYCLE_1_25_HZ}

    i2c = busio.I2C(board.SCL, board.SDA, frequency=100000)
    mpu = adafruit_mpu6050.MPU6050(i2c)
    mpu.cycle_Rate = cycle_rates["125"]
    return mpu

if __name__ == '__main__':
    measured_acceleration = np.array([[0, 0, 0]])
    mpu = init_accelerometer()

    # digital = digitalio.DigitalInOut(board.C0)
    # digital.direction = digitalio.Direction.OUTPUT
    # digital.value = False

    mpu.sleep = False
    mpu.cycle = True 

    print("Start")
    for count in range(0, 10):
        print(mpu.acceleration)
        sleep(0.010)   
        # measured_acceleration = np.append(measured_acceleration, [[mpu.acceleration[0], mpu.acceleration[1], mpu.acceleration[2]]], axis=0)
        # print("Acceleration: X:%.2f, Y: %.2f, Z: %.2f m/s^2"%(mpu.acceleration))
        # print("Acceleration: X:%.2f, Y: %.2f, Z: %.2f m/s^2"%(mpu.acceleration))
        # print("Gyro X:%.2f, Y: %.2f, Z: %.2f degrees/s"%(mpu.gyro))
        # print("Temperature: %.2f C"%mpu.temperature)
        # sleep(timestep)
        # digital.value = True if not digital.value else False 

    print("acquisition finished")

    c_rate = 125
    a = f"accel_{datetime.now().strftime('%H%M%S')}_{c_rate}hz"
    np.savetxt(f'{a}.txt', measured_acceleration, fmt='%.5f')

