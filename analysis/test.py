#!/usr/bin/python
# -*- coding:utf-8 -*-

# Script controling LTC2440 ADC via SPI

# data map | 3 - bits | 24 - bits | 5 - bits   |
# from adc |----------|-----------|------------|
#          |sign, stat| data,     | additional |
#          |          | MSB first | bits,      |

import sys
import time
import spidev

def read_raw(data):
    """
    read data in raw format
    """
    sign = (data[0]>>5) & 0x01
    result = data[0]<<24 | data[1]<<16 | data[2]<<8 | data[3] 
    result >>= 5 # cut down 5 bits
    result = result & 0xffffff 
    if(not(sign)):
        return result-2**24
    return result

def read_raw_cont(spi, delay):
    """
    read continously raw values from adc
    """
    try:
        while(1):
            print(read_raw(spi.readbytes(4)))
            time.sleep(delay)
    except KeyboardInterrupt:
        spi.close()

def read_voltage(data, ref):
    """
    interpret data as voltage
    """
    adc = read_raw(data)
    return adc/(2**24)*ref # ref -> reference voltage

def read_voltage_cont(spi, ref, delay):
    """
    read continously voltage values from adc
    """
    try:
        while(1):
            print(read_voltage(spi.readbytes(4), ref))
            time.sleep(delay)
    except KeyboardInterrupt:
        spi.close()

def read_filtred():
    pass

def touch_detect(threshold):
    pass

def measure_data(path, spi, delay):
    """
    measure and save data from spi device into path
    """
    values = ''
    try:
        while(1):
            v = str(read_raw(spi.readbytes(4)))
            values += '{0}\n'.format(v)
            time.sleep(delay)

    except KeyboardInterrupt:
        spi.close()
        with open(path, 'w') as out:
            out.write(values)


if __name__ == '__main__':
    delay = 0.5 # s
    spi = spidev.SpiDev()
    spi.open(0, 0)
    spi.max_speed_hz = 5000

    read_raw_cont(spi, delay)
    # read_voltage_cont(spi, 5, delay)
    # measure_data("raw_data.txt", spi, delay)
    # print(read_voltage(test0, 5))

