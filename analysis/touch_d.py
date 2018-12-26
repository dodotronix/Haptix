#!/usr/bin/python
# -*- coding:utf-8 -*-

# Script controling LTC2440 ADC via SPI

# data map | 3 - bits | 24 - bits | 5 - bits   |
# from adc |----------|-----------|------------|
#          |sign, stat| data,     | additional |
#          |          | MSB first | bits,      |

import sys
import time
# import spidev

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

def read_raw_cont(spi):
    """
    read continously raw values from adc
    """
    try:
        while(1):
            print(read_raw(spi.readbytes(4)))
    except KeyboardInterrupt:
        spi.close()

def read_voltage(data, ref):
    """
    interpret data as voltage
    """
    adc = read_raw(data)
    return adc/(2**24)*ref # ref -> reference voltage

def read_voltage_cont(spi, ref):
    """
    read continously voltage values from adc
    """
    try:
        while(1):
            print(read_voltage(spi.readbytes(4), ref))
    except KeyboardInterrupt:
        spi.close()


def measure_data_raw(path, spi):
    """
    measure and save raw data from spi device into path
    """
    values = ''
    try:
        while(1):
            # v = str(read_raw(spi.readbytes(4)))
            v = str(read_raw(spi))
            values += '{0}\n'.format(v)
            time.sleep(1)

    except KeyboardInterrupt:
        # spi.close()
        with open(path, 'w') as out:
            out.write(values)

def measure_data_voltage(path, ref, spi):
    """
    measure and save voltage data from spi device into path
    """
    values = ''
    try:
        while(1):
            v = str(read_voltage(spi, ref))
            values += '{0}\n'.format(v)
            time.sleep(1)

    except KeyboardInterrupt:
        with open(path, 'w') as out:
            out.write(values)

def touch_detect(spi, ref, f_length, threshold, delay):
    window = []

    # initialize filter
    for x in range(0,f_length):
        window.append(spi.read_voltage(spi, ref))

    try:
        while(1):
            window = [read_voltage(spi, ref)] + window
            window.pop()
            avg = sum(window)/f_length
            if(avg >= threshold):
                print("touch detected")
                break
            time.sleep(delay)

    except KeyboardInterrupt:
        pass


if __name__ == '__main__':
    # spi = spidev.SpiDev()
    # spi.open(0, 0)
    # spi.max_speed_hz = 5000

    test0 = [47, 200, 4, 189] 
    test1 = [16, 26, 235, 189]


