#!/usr/bin/python
# -*- coding:utf-8 -*-

# Script communicate via SPI with LTC2440 ADC

import sys
import time
import spidev

def get_voltage(data):
    # data map | 3 - bits | 24 - bits | 5 - bits   |
    #          |----------|-----------|------------|
    #          |sign, stat| data,     | additional |
    #          |          | MSB first | bits,      |

    pass

if __name__ == '__main__':
    spi = spidev.SpiDev()
    spi.open(0, 0)
    spi.max_speed_hz = 5000
    # to_send = [0x01, 0x02, 0x03, 0x04]
    # spi.writebytes(to_send)

    while(1):
        data = spi.readbytes(3)
        print(data)
        time.sleep(0.01) # 10 [ms]


