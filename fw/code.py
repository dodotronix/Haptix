import board
import neopixel
import digitalio
import adafruit_mpu6050
from time import sleep

time_interval = 10 # seconds
time_step = 1
time_range = range(0, int(time_interval / time_step)) 

i2c = board.I2C()
mpu = adafruit_mpu6050.MPU6050(i2c)
mpu.cycle_Rate = adafruit_mpu6050.Rate.CYCLE_1_25_HZ
# mpu.sleep = False
# mpu.cycle = True 

syncpin = digitalio.DigitalInOut(board.D3)
syncpin.direction = digitalio.Direction.OUTPUT
syncpin.value = False

pixel = neopixel.NeoPixel(board.NEOPIXEL, 1)

try:
    with open("/acceleration.txt", "a") as fp:
        pixel.fill((0, 0, 255))
        syncpin.value = not syncpin.value
        for _ in time_range:
            accel = mpu.acceleration
            fp.write(f'{accel[0]:.2f}, {accel[1]:.2f}, {accel[2]:.2f}\n')
            fp.flush()
            sleep(time_step)
        pixel.fill((255, 255, 0))
        syncpin.value = not syncpin.value
    while True:
        pass

except OSError:
    while True:
        accel = mpu.acceleration
        gyro = mpu.gyro
        pixel.fill((255, 0, 255))
        print(f"Acceleration: X: {accel[0]:.2f}, Y: {accel[1]:.2f}, Z: {accel[2]:.2f} m/s^2")
        print(f"Gyro: X: {gyro[0]:.2f}, Y: {gyro[1]:.2f}, Z: {gyro[2]:.2f} degrees/s")
        print(f"Temperature: {mpu.temperature:.2f} C")
        pixel.fill((0, 0, 0))
        syncpin.value = not syncpin.value
        sleep(1)
