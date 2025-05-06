
import numpy as np
import matplotlib.pyplot as plt
from scipy.signal import lfilter, filtfilt, butter

#data = np.loadtxt("../../meas/table_setup/channels_500us_vibration_fz.csv", delimiter=',', skiprows=1)
data = np.loadtxt("../../meas/table_setup/channels_500us_offset_vibration_fz.csv", delimiter=',', skiprows=1)

Ts = 500e-6
fs = 1/Ts

b, a = butter(2, (2*150/fs), 'low')
print(a, b)

def to_fxp(x, q):
    if x == 1:
        return 2**q - 1
    return int(round(x*(2**q)))

b_fxp = [to_fxp(x, 16) for x in b]
a_fxp = [to_fxp(x, 16) for x in a]

force_raw = data[:, 0]
accel_raw = data[:, 1]

# this simulates just pure reading from the ADC
force = np.zeros(len(force_raw))
accel = np.zeros(len(accel_raw))
for i in range(len(force_raw)):
    force[i] = int(force_raw[i] - 512) << 6
    accel[i] = int(accel_raw[i] - 512) << 6

# find offset
force_offset = 0
accel_offset = 0
for i in range(16):
    force_offset += force[i]
    accel_offset += accel[i]
force_offset = int(force_offset) >> 4
accel_offset = int(accel_offset) >> 4

print(f"force offset: {force_offset}")
print(f"accel offset: {accel_offset}")

force_offset_exp = np.mean(force[:16])
accel_offset_exp = np.mean(accel[:16])

print(f"force offset expected: {force_offset_exp}")
print(f"accel offset expected: {accel_offset_exp}")

k = 0.56
k_fxp = to_fxp(k, 16)
print(f"factor: {k} -> {k_fxp} ")

force = (force - force_offset)
# !!! don't forget to shift the result after multiplication !!!
accel = k_fxp*(accel - accel_offset)/(2**16)

force = filtfilt(b_fxp, a_fxp, force)
accel = filtfilt(b_fxp, a_fxp, accel)

# delay force
dly = 3
force = np.concatenate((np.zeros(dly), force[:-dly]))

# from q1.16 to float
force = force/(2**16)
accel = accel/(2**16)

# simple subtraction
direct_sub = np.zeros(len(force))
gradient_accel = np.zeros(len(force))
for i in range(2, len(force)):
    direct_sub[i] = (force[i] - accel[i])
    gradient_accel[i] = accel[i] - accel[i-2]

# EMA
alpha = 0.01
ema_force = np.zeros(len(force))
ema_accel = np.zeros(len(accel))
for i in range(1, len(force)):
    ema_force[i] = alpha*force[i-1] + (1-alpha)*ema_force[i-1]
    ema_accel[i] = alpha*accel[i-1] + (1-alpha)*ema_accel[i-1]

t = np.linspace(0, (len(force))*Ts, (len(force)))

# zero-score detection for arduino
beta = 0.04
threshold = 6
lag = 32
circ_buf = np.zeros(lag)
head = 0

events = np.zeros(len(direct_sub))
avgFilt = np.zeros(len(direct_sub))
avgFilt_py = np.zeros(len(direct_sub))
stdFilt_py = np.zeros(len(direct_sub))
stdFilt = np.zeros(len(direct_sub))
filtered = np.zeros(len(direct_sub))

for i in range(1, len(direct_sub)-lag):

    if np.abs(direct_sub[i] - avgFilt[i-1]) > (threshold * stdFilt[i-1]):
        if direct_sub[i] > avgFilt[i - 1]:
            events[i] = 1
        filtered[i] = alpha*direct_sub[i] + (1 - alpha)*filtered[i-1]
    else:
        filtered[i] = direct_sub[i]
        events[i] = 0

    # circular buffer update
    old = circ_buf[head]
    avg_old = avgFilt[i-1]
    avgFilt[i] = avg_old + (filtered[i] - old)/lag
    stdFilt[i] = stdFilt[i-1] + (filtered[i] - old)*(filtered[i] - avgFilt[i] + old - avg_old)/lag
    circ_buf[head] = filtered[i]
    head = (head + 1) & (lag - 1)

    # cross check
    if(i < lag):
        tmp = np.concatenate((np.zeros(lag-i), filtered[1:i+1]))
        avgFilt_py[i] = np.mean(tmp)
        stdFilt_py[i] = np.std(tmp)
    else:
        avgFilt_py[i] = np.mean(filtered[i-lag+1:i+1])
        stdFilt_py[i] = np.std(filtered[i-lag+1:i+1])

    #print(avgFilt_py[i], avgFilt[i], stdFilt_py[i], np.sqrt(stdFilt[i]))

# for comparison
def zero_score_detection(data, lag=1, threshold=0, alpha=0.1):
    signals = np.zeros(len(data))
    filtered_data = np.array(data)
    avgFilter = np.zeros(len(data))
    stdFilter = np.zeros(len(data))
    avgFilter[lag-1] = np.mean(data[0:lag])
    stdFilter[lag-1] = np.std(data[0:lag])

    for i in range(lag, len(data)):
        if abs((data[i] - avgFilter[i-1])) > threshold * stdFilter[i-1]:
            #print(data[i], avgFilter[i-1], threshold, stdFilter[i-1])
            #print(data[i], avgFilter[i-1], threshold, stdFilter[i-1])
            if data[i] > avgFilter[i-1]:
                signals[i] = 1
            filtered_data[i] = alpha * data[i] + (1 - alpha) * filtered_data[i-1]
        else:
            signals[i] = 0
            filtered_data[i] = data[i]

        avgFilter[i] = np.mean(filtered_data[i - lag + 1:i + 1])
        stdFilter[i] = np.std(filtered_data[i - lag + 1:i + 1])

    return signals, avgFilter, stdFilter, filtered_data

sigs, avgF, stdF, fdata = zero_score_detection(direct_sub, lag, threshold, beta)

plt.figure(0)
plt.plot(t, force, label='force')
plt.plot(t, accel, label='acceleration')
plt.plot(t, direct_sub, label='direct subtraction')
plt.plot(t, gradient_accel, label='gradient')
plt.plot(t, ema_force, label='EMA force')
plt.plot(t, ema_accel, label='EMA acceleration')
plt.legend(fontsize=16)
plt.grid(True)

plt.figure(1)
plt.plot(t, force, label='force')
plt.plot(t, direct_sub, label='direct subtraction')
plt.plot(t, avgFilt, label='average')
plt.plot(t, np.sqrt(stdFilt), label='stddev')
plt.plot(t, filtered, label='filtered')
plt.plot(t, 0.2*events, label='events')
plt.legend(fontsize=16)
plt.grid(True)

plt.figure(2)
plt.plot(t, force, label='force')
plt.plot(t, direct_sub, label='direct subtraction')
plt.plot(t, avgF, label='average')
plt.plot(t, stdF, label='stddev')
plt.plot(t, fdata, label='filtered')
plt.plot(t, 0.2*sigs, label='events')
plt.legend(fontsize=16)
plt.grid(True)

plt.figure(3)
plt.plot(t, force_raw - 321, label='force')
plt.plot(t, 0.525*(accel_raw - 162), label='acceleration')
plt.legend(fontsize=16)
plt.grid(True)

plt.show()
