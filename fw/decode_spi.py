#!/usr/bin/python

# -*- coding: utf-8 -*-
#
# Copyright (C) 2022 Dododtronix
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
from dwfconstants import *

hdwf = c_int()
sts = c_byte()

dwf.FDwfDeviceOpen(c_int(-1), byref(hdwf))
if hdwf.value == 0:
    print("Failed to open device")
    exit()

# SET Voltage
# set up analog IO channel V+
dwf.FDwfAnalogIOChannelNodeSet(hdwf, c_int(0), c_int(0), c_double(1)) 
# set voltage to 5 V
dwf.FDwfAnalogIOChannelNodeSet(hdwf, c_int(0), c_int(1), c_double(5.0)) 
# enable voltage
dwf.FDwfAnalogIOEnableSet(hdwf, c_int(1))

sleep(1)

channel = c_int(0)
dwf.FDwfAnalogOutNodeEnableSet(hdwf, channel,    AnalogOutNodeCarrier, c_int(1))
dwf.FDwfAnalogOutNodeFunctionSet(hdwf, channel,  AnalogOutNodeCarrier, funcSine)
dwf.FDwfAnalogOutNodeFrequencySet(hdwf, channel, AnalogOutNodeCarrier, c_double(500))
dwf.FDwfAnalogOutNodeAmplitudeSet(hdwf, channel, AnalogOutNodeCarrier, c_double(1.41))
dwf.FDwfAnalogOutNodeOffsetSet(hdwf, channel,    AnalogOutNodeCarrier, c_double(1.41))

print("Generating sine wave...")
dwf.FDwfAnalogOutConfigure(hdwf, channel, c_int(1))

nSamples = 100000 # 100MiB, ~12Mi of 8bit SPI
rgbSamples = (c_uint8*nSamples)()
nWords = 200

idxClk = 0 # DIO-0
idxMiso = 1 # DIO-1
idxMosi = 2 # DIO-2
idxCS = 3 # DIO-3
nBits = 8 # 8-bit words

# record mode
dwf.FDwfDigitalInAcquisitionModeSet(hdwf, acqmodeRecord)
# for sync mode set divider to -1 
dwf.FDwfDigitalInDividerSet(hdwf, c_int(-1))
# 8bit per sample format, DIO 0-7
dwf.FDwfDigitalInSampleFormatSet(hdwf, c_int(8))

# continuous measurement
dwf.FDwfDigitalInTriggerPositionSet(hdwf, c_int(-1))
dwf.FDwfDigitalInTriggerSet(hdwf, c_int(0), c_int(0), c_int((1<<idxClk)|(1<<idxCS)), c_int(0))
dwf.FDwfDigitalInConfigure(hdwf, c_int(0), c_int(1))

cAvailable = c_int()
cLost = c_int()
cCorrupted = c_int()

fsMosi = 0
fsMiso = 0
cBit = 0
rgMosi = []
rgMiso = []

channels = [[], [], []]

def info(decoded_data):
    if decoded_data:
        tmp = [f"0x{n:02x}" for n in decoded_data] 
        return ', '.join(tmp)

# wait for acquisition
while True:
    dwf.FDwfDigitalInStatus(hdwf, c_int(1), byref(sts))
    dwf.FDwfDigitalInStatusRecord(hdwf, byref(cAvailable), byref(cLost), byref(cCorrupted))
    dwf.FDwfDigitalInStatusData(hdwf, rgbSamples, c_int(cAvailable.value))

    if cAvailable.value or cLost.value or cCorrupted.value:
        print(f"available: {cAvailable.value}, lost: {cLost.value}, corrupted: {cCorrupted.value}")

    for i in range(cAvailable.value):
        v = rgbSamples[i]
        if (v>>idxCS)&1: # CS high
            print(f"MOSI: {info(rgMosi)} | MISO: {info(rgMiso)}")
            if cBit != 0: # log leftover bits, frame not multiple of nBits
                print("leftover bits %d : h%02X | h%02X" % (cBit, fsMosi, fsMiso))

            try:
                if(rgMosi[1] ==  0x80):
                    channels[0].append(((rgMiso[1] & 0x07) << 8) | rgMiso[2])
                if(rgMosi[1] ==  0x90):
                    channels[1].append(((rgMiso[1] & 0x07) << 8) | rgMiso[2])
                if(rgMosi[1] ==  0xa0):
                    channels[2].append(((rgMiso[1] & 0x07) << 8) | rgMiso[2])
            except:
                pass

            if((len(channels[0]) == nWords) and \
               (len(channels[1]) == nWords) and \
                   (len(channels[2]) == nWords)):
               break 

            cBit, fsMosi, fsMiso = 0, 0, 0
            rgMosi.clear()
            rgMiso.clear()
        else:
            cBit+=1
            fsMosi <<= 1 # MSB first
            fsMiso <<= 1 # MSB first
            if (v>>idxMosi)&1 :
                fsMosi |= 1
            if (v>>idxMiso)&1 :
                fsMiso |= 1
            if cBit >= nBits: # got nBits of bits
                rgMosi.append(fsMosi)
                rgMiso.append(fsMiso)
                cBit = 0
                fsMosi = 0
                fsMiso = 0

    if((len(channels[0]) == nWords) and \
       (len(channels[1]) == nWords) and \
           (len(channels[2]) == nWords)):
       break 

channels = np.array(channels).T

plt.plot(channels, marker='o')
plt.title("Visualization of SPI received data")
plt.xlabel("Sample Index [-]")
plt.ylabel("ADC value [-]")
plt.grid(True)
plt.show()

dwf.FDwfDeviceClose(hdwf)
