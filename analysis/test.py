#!/usr/bin/python
# -*- coding:utf-8 -*-

# Script communicate via SPI with ADC

import sys
import time
import spidev

if __name__ == '__main__':
    spi = spidev.SpiDev()
    spi.open(0, 0)

    spi.max_speed_hz = 5000
    to_send = [0x01, 0x02, 0x03, 0x04]
    spi.writebytes(to_send)


