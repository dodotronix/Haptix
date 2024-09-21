#!/usr/bin/python

import os
os.environ['BLINKA_FT232H'] = "1"

import board
import digitalio
import logging as log
import busio

from time import sleep
# from adafruit_bno08x.i2c import BNO08X_I2C
from adafruit_bno08x import BNO_REPORT_ACCELEROMETER


log.basicConfig(format='%(asctime)s %(levelname)s: %(message)s', 
        datefmt='%m/%d/%Y %I:%M:%S %p',level=log.INFO)

if __name__ == '__main__':

    # i2c = busio.I2C(board.SCL, board.SDA, frequency=100_000)
    # bno = BNO08X_I2C(i2c, address=0x4b, debug=True)
    bno.enable_feature(BNO_REPORT_ACCELEROMETER)

# Blink test
# led = digitalio.DigitalInOut(board.C0)
# led.direction = digitalio.Direction.OUTPUT


# while True:
#     led.value = True
#     sleep(0.5)
#     led.value = False
#     sleep(0.5)
