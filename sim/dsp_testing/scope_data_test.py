import numpy as np
import matplotlib.pyplot as plt
import padasip as pa

from scipy.signal import filtfilt, lfilter, windows, medfilt, cont2discrete, butter

force = np.loadtxt("../../meas/touching_10ksmp_2V_5s_61kohm/force_152849.txt")

fs = 10e3
Ts = 1/fs

# time shift back
offset = 4
force = force[:-offset]

# calculate offset and subtract it
offset_force = np.mean(force[0:99])
force = force - offset_force

t = np.linspace(0, len(force)*Ts, len(force))

b, a = butter(2, (2*120/fs), 'low')
force = filtfilt(b, a, force)


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

sigs, avgF, stdF, fdata = zero_score_detection(kalman_est, 200, 6, 0.008)





#normalize
force = force/np.max(np.abs(force))

plt.figure(0)
plt.plot(t, force, label="scope signal")
#plt.plot(t_scope, scope_filtered, label="filtered signal")
plt.legend(fontsize=16)
plt.grid(True)

plt.show()
