#!/usr/bin/python
# -*- coding:utf-8 -*-

# Script controling LTC2440 ADC via SPI

# data map | 3 - bits | 24 - bits | 5 - bits   |
# from adc |----------|-----------|------------|
#          |sign, stat| data,     | additional |
#          |          | MSB first | bits,      |

# change speed
# |  OSR4  |  OSR3  |  OSR2  |  OSR1  |  OSR0  |
# | 31-bit | 30-bit | 29-bit | 28-bit | 27-bit |

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

def measure_data_raw(path, spi, delay):
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

def measure_data_voltage(path, spi, ref, delay):
    """
    measure and save voltage data from spi device into path
    """
    values = ''
    try:
        while(1):
            v = str(read_voltage(spi.readbytes(4), ref))
            values += '{0}\n'.format(v)
            time.sleep(delay)

    except KeyboardInterrupt:
        spi.close()
        with open(path, 'w') as out:
            out.write(values)

def touch_detect(spi, ref, f_length, threshold, delay):
    window = []

    # initialize filter
    for x in range(0,f_length+1):
        window.append(read_voltage(spi.readbytes(4), ref))
        time.sleep(delay)
    window.pop(0) # flush first value

    try:
        while(1):
            window = [read_voltage(spi.readbytes(4), ref)] + window
            window.pop()
            avg = sum(window)/f_length
            print(avg)

            # check threshold
            if(avg >= threshold):
                print("touch detected")
                break
            time.sleep(delay)

    except KeyboardInterrupt:
        spi.close()


if __name__ == '__main__':
    freq = 500 # reading frequency [Hz]
    delay = 1/freq # period [s]
    ref = 5 # reference voltage [V]
    filter_l = 20 # length of filter
    threshold = 0.2 # [V]

    spi = spidev.SpiDev()
    spi.open(0, 0)
    spi.max_speed_hz = 5000

    ## 3.52 kHz (datasheet)
    # spi.writebytes([0x1<<4, 0x00, 0x00, 0x00])

    # read_raw_cont(spi, delay)
    # read_voltage_cont(spi, ref, delay)
    # measure_data_raw("raw_data.txt", spi, delay)
    # measure_data_voltage("volt_data.txt", spi, ref, delay)
    touch_detect(spi, ref, filter_l, threshold, delay)

