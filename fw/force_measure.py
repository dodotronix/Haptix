#!/usr/bin/python
# -*- coding: utf-8 -*-

import os
os.environ['BLINKA_FT232H'] = "1"

import board
import digitalio
import pyvisa

import logging as log
import numpy as np
import matplotlib.pyplot as plot

from time import sleep
from datetime import datetime
from math import ceil, floor

log.basicConfig(format='%(asctime)s %(levelname)s: %(message)s', 
        datefmt='%m/%d/%Y %I:%M:%S %p',level=log.INFO)

def __wait_until_complete():
    inst.write("*WAI")

def __start_acquisition():
    inst.write(f"RUN")
    __wait_until_complete()
    sleep(1)

def __acquisition_complet(inst):
    print("waiting for the acquisition")
    while inst.query("TRIG:STAT?") != "STOP":
        pass

    return get_wave_data(inst)

def get_wave_data(inst):
    number_of_data = int(inst.query("ACQ:MDEP?"))
    sampling_rate = inst.query("ACQ:SRAT?")
    time_offset = inst.query("TIM:MAIN:OFFS?")
    xorigin = inst.query("WAVeform:XOR?")

    points_per_packet = 15e4
    packets = ceil(number_of_data / points_per_packet)
    print(f"packets: {packets}")

    print(f"Time offset: {time_offset}")
    print(f"X origin: {xorigin}")
    print(f"Memory size: {number_of_data}")
    print(f"Sampling rate: {sampling_rate}")

    inst.write("WAV:MODE RAW")
    inst.write("WAV:FORM BYTE")
    inst.write("WAV:SOUR CHAN1")
    __wait_until_complete()

    start = 1
    d = b''
    test = np.array([])
    for i in range(packets):
        end = int(start + points_per_packet-1)
        if end > number_of_data:
            end = number_of_data
        print(f"start: {start}, end: {end}")
        inst.write(f"WAV:STAR {start}")
        inst.write(f"WAV:STOP {end}")
        inst.write(f"WAV:DATA?")
        start = end + 1
        d = inst.read_raw()
        while inst.query("*OPC?") != "1":
            pass
        header_length = int(d[1:2])
        num_bytes = int(d[2:2+header_length])
        waveform_data = d[2+header_length:2+header_length+num_bytes]
        waveform_array = np.frombuffer(waveform_data, dtype=np.uint8)
        test = np.append(test, waveform_array)

    data = test
    return data

def setup(inst, amp, timescale, memsize, trig):

    inst.write("*RST")
    __wait_until_complete()
    inst.write_termination = '\n'
    inst.read_termination = '\n'

    inst.write("CHAN1:DISP ON")
    __wait_until_complete()
    inst.write("CHAN4:DISP ON")
    __wait_until_complete()

    inst.write("CHAN1:PROB 1")
    __wait_until_complete()
    inst.write("CHAN4:PROB 1")
    __wait_until_complete()

    inst.write(f"CHAN1:SCAL {amp/8}") # vertical - 10 grid parts
    __wait_until_complete()
    inst.write(f"CHAN4:SCAL {amp/8}") # vertical - 10 grid parts
    __wait_until_complete()

    inst.write(f"TIM:MAIN:SCAL {timescale}") # time in ms
    __wait_until_complete()
    inst.write(f"TIM:MAIN:OFFS {6*timescale}") # shift zero point left
    __wait_until_complete()

    inst.write(f"ACQ:MDEP {memsize}")
    __wait_until_complete()

    # # set trigger
    inst.write(f"TRIG:EDG:SOUR CHAN4") # trigger source
    inst.write(f"TRIG:EDG:LEV {trig}") # trigger level
    inst.write(f"TRIG:EDG:SLOP POS") # rising edge
    inst.write(f"TRIG:SWE SING")
    __wait_until_complete()


def close(inst):
    inst.close()

if __name__ == '__main__':
    # memory size is defined by the rigol datasheet
    memdepths = [6000, 60000, 600000, 6000000, 12000000]

    rm = pyvisa.ResourceManager()
    inst = rm.open_resource(rm.list_resources()[0])
    print(f"Connected to: {inst.query("*IDN?")}")

    # start measurement
    digital = digitalio.DigitalInOut(board.C0)
    digital.direction = digitalio.Direction.OUTPUT
    digital.value = False

    # 12 V amplitude 
    # 0.2 s/timescale
    # memory size
    # 1.5 V trigger 
    setup(inst, 16, 0.2, memdepths[2], 1.5)
    __start_acquisition()

    print(f"{inst.query('TRIG:STAT?')}")

    # start measurement
    digital.value = True
    sleep(0.5)
    digital.value = False

    force = __acquisition_complet(inst)
    print(f"data length: {len(force)}")
    print("Done")

    close(inst)
    print("Closed")

    # save to files
    a = f"force_{datetime.now().strftime('%H%M%S')}"
    np.savetxt(f'{a}.txt', force, fmt='%.5f')

    plot.plot(force)
    plot.title("Channel samples [-]")
    plot.ylabel("Amplitude [-]")
    plot.grid()
    plot.show()
