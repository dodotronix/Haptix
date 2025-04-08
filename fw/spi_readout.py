#!/usr/bin/python

# -*- coding: utf-8 -*-
#
# Copyright (C) 2025 dododtronix
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street,
# Fifth Floor, Boston, MA  02110-1301, USA.
#
# You can dowload a copy of the GNU General Public License here:
# http://www.gnu.org/licenses/gpl.txt

import numpy as np
import matplotlib.pyplot as plt

from ctypes import *
from sys import platform, path
from os import sep
from time import sleep

dwf = cdll.LoadLibrary("libdwf.so")
constants_path = (f"{sep}usr{sep}share{sep}digilent"
                  f"{sep}waveforms{sep}samples{sep}py")

#import constants
path.append(constants_path)
import dwfconstants as constants

hdwf = c_int()
dwf.FDwfDeviceOpen(c_int(-1), byref(hdwf))
if hdwf.value == 0:
    print("Failed to open device")
    exit()

dwf.FDwfDeviceAutoConfigureSet(hdwf, c_int(0)) 

# SET Voltage
# set up analog IO channel V+
dwf.FDwfAnalogIOChannelNodeSet(hdwf, c_int(0), c_int(0), c_double(1)) 
# set voltage to 5 V
dwf.FDwfAnalogIOChannelNodeSet(hdwf, c_int(0), c_int(1), c_double(5.0)) 
# set current 0.5 A
# dwf.FDwfAnalogIOChannelNodeSet(hdwf, c_int(0), c_int(2), c_double(0.5)) 

# enable voltage
dwf.FDwfAnalogIOEnableSet(hdwf, c_int(1))

# start generator sine wave 1kHz
channel = c_int(0)

dwf.FDwfAnalogOutNodeEnableSet(hdwf, channel, constants.AnalogOutNodeCarrier, c_int(1))
dwf.FDwfAnalogOutNodeFunctionSet(hdwf, channel, constants.AnalogOutNodeCarrier, constants.funcSine)
dwf.FDwfAnalogOutNodeFrequencySet(hdwf, channel, constants.AnalogOutNodeCarrier, c_double(10))
dwf.FDwfAnalogOutNodeAmplitudeSet(hdwf, channel, constants.AnalogOutNodeCarrier, c_double(1.41))
dwf.FDwfAnalogOutNodeOffsetSet(hdwf, channel, constants.AnalogOutNodeCarrier, c_double(1.41))

print("Generating sine wave...")
dwf.FDwfAnalogOutConfigure(hdwf, channel, c_int(1))

print("Configuring SPI...")
dwf.FDwfDigitalSpiFrequencySet(hdwf, c_double(2e6))
dwf.FDwfDigitalSpiModeSet(hdwf, c_int(0)) # SPI mode 
dwf.FDwfDigitalSpiOrderSet(hdwf, c_int(1)) # 1 MSB first

dwf.FDwfDigitalSpiClockSet(hdwf, c_int(0)) # CLK (DIO-0)
dwf.FDwfDigitalSpiDataSet(hdwf, c_int(0), c_int(2)) # MOSI (DIO-2/DQ0)
dwf.FDwfDigitalSpiDataSet(hdwf, c_int(1), c_int(1)) # MISO (DIO-1/DQ1)
dwf.FDwfDigitalSpiSelectSet(hdwf, c_int(3), c_int(1)) # CS (DIO-3), idle high

sleep(1)

pattern = [0xc0, 0x00, 0x00] * 2
# write sequence and read out 4 data
# rgbTX = (c_uint8*len(pattern))(*pattern)
rgbTX = (c_uint8*6)(0xc0, 0x00, 0x00, 0x00, 0xc0, 0x00, 0x00)
rgwRX = (c_uint8*6)()


print("reading data")
dwf.FDwfDigitalSpiCmdWriteRead(hdwf, 
                               c_int(0), # bitcmd
                               c_int(0), # cmd
                               c_int(0), #cdummy 

                               c_int(1), # cdq line
                               c_int(8), # cbit per word

                               rgbTX, # buffer to write 8bit words
                               c_int(len(rgbTX)), # number of words
                               rgwRX, # buffer to read
                               c_int(len(rgwRX))) # number of words

print(list(rgwRX))

# tmp = ((rgwRX[0]<<9) | (rgwRX[1] << 1) | (rgwRX[2]>>7))*5/(2**10-1)
# measured.append(tmp)

# # plot results
# plt.figure()
# plt.plot(measured, label='haptix')
# plt.title("Basic Line Plot")
# plt.xlabel("Samples [-]")
# plt.ylabel("Voltage [V]")
#
# plt.grid(True)
# plt.legend()
# plt.tight_layout()
#
# plt.show()

dwf.FDwfDeviceCloseAll()
