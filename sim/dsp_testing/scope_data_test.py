import numpy as np
import matplotlib.pyplot as plt
import padasip as pa

from scipy.signal import filtfilt, lfilter, windows, medfilt, cont2discrete, butter

force = np.loadtxt("../../meas/touching_10ksmp_2V_5s_61kohm/force_152849.txt")
#force = np.loadtxt("../../meas/defined_weight_1.6846_1V_0.5s_21kohm/force_154237.txt")
force = force[:-300000]
print(force.shape)

fs_orig = 10e3
fs = 2.5e3
Ts = 1/fs
v = 0.7 # cm/s (12 smps -> 4.8ms -> 336um)

# time shift back
offset = 4
force = force[:-offset]
force = force[::4]

# calculate offset and subtract it
offset_force = np.mean(force[0:99])
force = force - offset_force

t = np.linspace(0, len(force)*Ts, len(force))

#normalize
force = force/(2**7)

b, a = butter(2, (2*120/fs), 'low')
force = filtfilt(b, a, force)

kalman_est = np.zeros(len(force))
P = 0
r = 100
q = 0.05
x_est = 0

#for n,f in enumerate(force):
#    # 1D kalman filter
#    x_pred = x_est
#
#    P_pred = P + q
#    K = P_pred/(P_pred + r)
#    x_est = x_pred + K*(f - x_pred)
#    P = (1 - K)*P_pred
#    kalman_est[n] = x_est

def zero_score_detection(data, lag=1, threshold=0, alpha=0.1):
    signals = np.zeros(len(data))
    filtered_data = np.array(data)
    avgFilter = np.zeros(len(data))
    stdFilter = np.zeros(len(data))
    avgFilter[lag-1] = np.mean(data[0:lag])
    stdFilter[lag-1] = np.std(data[0:lag])

    for i in range(lag, len(data)):
        if abs(data[i] - avgFilter[i-1]) > threshold * stdFilter[i-1]:
            print(data[i], avgFilter[i-1], threshold, stdFilter[i-1])
            if data[i] > avgFilter[i-1]:
                signals[i] = 1
            filtered_data[i] = alpha * data[i] + (1 - alpha) * filtered_data[i-1]
        else:
            signals[i] = 0
            filtered_data[i] = data[i]

        avgFilter[i] = np.mean(filtered_data[i - lag + 1:i + 1])
        stdFilter[i] = np.std(filtered_data[i - lag + 1:i + 1])

    return signals, avgFilter, stdFilter, filtered_data

sigs, avgF, stdF, fdata = zero_score_detection(force, 64, 4, 0.008)

plt.figure(0)
plt.plot(t, force, "-o", label="scope signal")
plt.plot(t, fdata, label="filtered")
plt.plot(t, avgF, label="avg")
plt.plot(t, stdF, label="std")
plt.plot(t, sigs-1, label="events")
plt.plot(t, kalman_est, label="kalman")
plt.legend(fontsize=16)
plt.grid(True)

plt.show()
