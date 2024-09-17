#!/usr/bin/python

import os
os.environ['BLINKA_FT232H'] = "1"

import board
import digitalio
import logging as log

from busio import I2C
from adafruit_bus_device import i2c_device 

from pyftdi.ftdi import Ftdi
from time import sleep

"""Si5338 loader"""
# If you run this and it seems to hang, try manually unlocking
# your I2C bus from the REPL with
#  >>> import board
#  >>> board.I2C().unlock()

log.basicConfig(format='%(asctime)s %(levelname)s: %(message)s', 
        datefmt='%m/%d/%Y %I:%M:%S %p',level=log.INFO)

class ft232h_i2c_api:

    def __init__(self, i2c: I2C, address: int) -> None:
        self._BUFFER = bytearray(2)
        self._device = i2c_device.I2CDevice(i2c, address)
        
    def read_byte_data(self, reg: int) -> int:
        with self._device as i2c:
            self._BUFFER[0] = reg & 0xFF
            i2c.write_then_readinto(self._BUFFER, self._BUFFER, out_end=1, in_end=1)
        return self._BUFFER[0]

    def write_byte_data(self, reg: int, val: int) -> None:
        with self._device as i2c:
            self._BUFFER[0] = reg & 0xFF
            self._BUFFER[1] = val & 0xFF
            i2c.write(self._BUFFER, end=2)

if __name__ == '__main__':

    # 7 bit address
    DEVICE_ADDRESS = 0x70 

    i2c = board.I2C() # uses board.SCL and board.SDA
    bus = ft232h_i2c_api(i2c, DEVICE_ADDRESS)


# Blink test
# led = digitalio.DigitalInOut(board.C0)
# led.direction = digitalio.Direction.OUTPUT


# while True:
#     led.value = True
#     sleep(0.5)
#     led.value = False
#     sleep(0.5)
