#!/usr/bin/python
# -*- coding: utf-8 -*-

import pyvisa

import logging as log
import numpy as np
import matplotlib.pyplot as plot

from time import sleep

log.basicConfig(format='%(asctime)s %(levelname)s: %(message)s', 
        datefmt='%m/%d/%Y %I:%M:%S %p',level=log.INFO)

if __name__ == '__main__':
    rm = pyvisa.ResourceManager()
    inst = rm.open_resource(rm.list_resources()[0])

    inst.write_termination = '\n'
    inst.read_termination = '\n'
    # inst.timeout = 5000

    print(inst.query("*IDN?"))

    inst.write("*RST")

    inst.write("AUT")
    inst.write("RUN")

    # inst.write("ACQ:MDEP 2400000")
    inst.write("TIM:MAIN:SCAL 0.001")

    inst.write("WAV:MODE RAW")
    inst.write("WAV:FORM BYTE")
    inst.write("WAV:SOUR CHAN1")

    inst.write("WAV:DATA?")

    data = inst.read_raw()

    header_length = int(data[1:2])
    num_bytes = int(data[2:2+header_length])
    waveform_data = data[2+header_length:2+header_length+num_bytes]

    waveform_array = np.frombuffer(waveform_data, dtype=np.uint8)

    # inst.write("WAV:STAR 2")
    # inst.write("WAV:STOP 15625")

    print(2e6*500e-6)
    print(header_length)
    print(num_bytes)
    print(waveform_data)

    plot.plot(waveform_array)
    plot.title("Channel samples [-]")
    plot.ylabel("Amplitude [-]")
    plot.show()
