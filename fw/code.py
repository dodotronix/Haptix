import board
import busio
import neopixel
import digitalio
import adafruit_mpu6050
import gc

from time import sleep, monotonic
from adafruit_datetime import datetime, timedelta
from adafruit_register.i2c_bit import RWBit
from adafruit_bus_device.i2c_device import I2CDevice
from adafruit_debouncer import Debouncer

class DeviceControl:
    def __init__(self, i2c):
        self.i2c_device = I2CDevice(i2c, 0x68) 

    int_ready = RWBit(0x38, 0)
    master_int = RWBit(0x38, 3)
    fifo_over = RWBit(0x38, 4)

initial_time = datetime(2024, 10, 16, 9, 58, 0)  # (YYYY, MM, DD, HH, MM, SS)
start_monotonic = monotonic()

i2c = busio.I2C(board.SCL, board.SDA, frequency=400000)
interrupt = DeviceControl(i2c)
mpu = adafruit_mpu6050.MPU6050(i2c)

# mpu.sample_rate_divisor = 15
mpu.sample_rate_divisor = 31
mpu.filter_bandwidth = adafruit_mpu6050.Bandwidth.BAND_260_HZ
# mpu.filter_bandwidth = adafruit_mpu6050.Bandwidth.BAND_184_HZ

interrupt.int_ready = True
interrupt.master_int = False
interrupt.fifo_over = False

syncpin = digitalio.DigitalInOut(board.D3)
syncpin.direction = digitalio.Direction.OUTPUT
syncpin.value = False

pin = digitalio.DigitalInOut(board.D1)
pin.direction = digitalio.Direction.INPUT
switch = Debouncer(pin)

t = digitalio.DigitalInOut(board.D0)
t.direction = digitalio.Direction.INPUT

pixel = neopixel.NeoPixel(board.NEOPIXEL, 1)


while True:
    elapsed_seconds = monotonic() - start_monotonic
    elapsed_timedelta = timedelta(seconds=elapsed_seconds)
    now = initial_time + elapsed_timedelta
    timestamp = f"{now.year:04d}{now.month:02d}{now.day:02d}_{now.hour:02d}{now.minute:02d}{now.second:02d}"

    accel_data = []

    print("waiting for switch press")
    pixel.fill((0, 0, 255))
    switch.update()
    while not switch.rose: 
        switch.update()

    pixel.fill((255, 255, 0))
    print("measuring data from mpu6050")

    gc.disable()
    syncpin.value = not syncpin.value
    for _ in range(0, 500):
        while not t.value:
            sleep(0.0001)
        accel = mpu.acceleration
        accel_data.append(accel)
    gc.collect()
    gc.enable()
    syncpin.value = not syncpin.value

    pixel.fill((0, 255, 255))
    print(f"writing acceleration data to {timestamp}.txt")
    try:
        with open(f"/accel_{timestamp}.txt", "w+") as fp:
            for i in accel_data:
                print(i)
                fp.write(f'{i[0]:.2f}, {i[1]:.2f}, {i[2]:.2f}\n')
                fp.flush()
        pixel.fill((0, 255, 0))

    except OSError:
        pixel.fill((255, 255, 255))
        sleep(1)
                
# print(f"Acceleration: X: {accel[0]:.2f}, Y: {accel[1]:.2f}, Z: {accel[2]:.2f} m/s^2")
# gyro = mpu.gyro
# print(f"Gyro: X: {gyro[0]:.2f}, Y: {gyro[1]:.2f}, Z: {gyro[2]:.2f} degrees/s")
# print(f"Temperature: {mpu.temperature:.2f} C")
