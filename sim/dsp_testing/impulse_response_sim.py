import numpy as np
import matplotlib.pyplot as plt
import padasip as pa
from pykalman import KalmanFilter
from scipy.signal import firwin, lfilter, correlate, medfilt, butter, filtfilt

#data = np.loadtxt("../../meas/table_setup/channels_simple_vibration_fzx.csv", delimiter=',', skiprows=1)
data = np.loadtxt("../../meas/table_setup/channels_offset_vibration_fzx.csv", delimiter=',', skiprows=1)
scope = np.loadtxt("../../meas/touching_10ksmp_2V_5s_61kohm/force_152849.txt")

Ts = 150e-6
fs = 1/Ts
v = 0.7 #cm/s, peak lasts for (5.2ms -> 0.36um)

force = data[:,0]
accel_z = data[:,1]
accel_x = data[:,2]

# time shift back
offset = 4
force = force[:-offset]
accel_z = accel_z[offset:]
accel_x = accel_x[:-offset]

# calculate offset and subtract it
offset_force = np.mean(force[0:99])
offset_accel_z = np.mean(accel_z[0:99])
offset_accel_x = np.mean(accel_x[0:99])

force = force - offset_force
accel_z = accel_z - offset_accel_z
accel_x = accel_x - offset_accel_x

#normalize
accel_x = accel_x/np.max(accel_z)
accel_z = accel_z/np.max(accel_z)
force = force/np.max(force)

# time shift
#accel_x = accel_x[1476:3000]
#accel_z = accel_z[1476:3000]
#force = force[1476:3000]

t = np.linspace(0, len(force)*Ts, len(force))
t_scope = np.linspace(0, len(scope)/10e3, len(scope))

N = 300
avg_trend = np.convolve(force, np.ones(N)/N, mode='full')
avg_trend = avg_trend[:len(force)]

WS = 599
med_trend = medfilt(force, kernel_size=WS)

# exponential moving average
alpha = 0.005
ema_trend = np.zeros_like(force, dtype=float)

for i in range(1, len(force)):
        ema_trend[i] = alpha * force[i] + (1 - alpha) * ema_trend[i - 1]

def cusum(data, target, k):
    n = len(data)
    C = np.zeros(n)
    for i in range(1, n):
        C[i] = max(0, C[i-1] + data[i] - target - k)
    return C

cusum_force = cusum(force, 0, 0.001)
cusum_accel_z = cusum(accel_z, 0, 0.001)
cusum_accel_x = cusum(accel_x, 0, 0.001)
cusum_scope = cusum(scope, 33.5, 0.1)

cusum_accel_z = cusum_accel_z/max(cusum_force)
cusum_accel_x = cusum_accel_x/max(cusum_force)
cusum_force = cusum_force/max(cusum_force)
cusum_scope = 50*cusum_scope/max(cusum_scope)

b_fit = [0.05693857, 0.11387715, 0.05693857]
a_fit =  [ 1, -1.34165906, 0.66757568]
hoho_fit = filtfilt(b_fit, a_fit, accel_z)

#dc = 0.11*np.ones(len(force))
dc = avg_trend
#dc = avg_trend**2
#dc = ema_trend
#dc = ema_trend**2
#dc = med_trend
#x = np.column_stack((accel_z, accel_x))
x = np.column_stack((accel_z, accel_x, dc))
#x = force.reshape(-1, 1)

#f = pa.filters.FilterLMF(n=2, mu=5)
#f = pa.filters.FilterLMS(n=3, mu=0.8)
f = pa.filters.FilterNLMS(n=3, mu=0.01)
#f = pa.filters.FilterRLS(n=3, mu=0.9)
y, e, w = f.run(force, x)

# Test kalman filter
#true_values = np.array([50.005, 49.994, 49.993, 50.001, 50.006, 49.998, 50.021, 50.005, 50, 49.997])
#meas_values = np.array([49.986, 49.963, 50.097, 50.001, 50.018, 50.05, 49.938, 49.858, 49.965, 50.114])

#kf = KalmanFilter(transition_matrices = [1], observation_matrices = [1],
#                  transition_covariance=[[0.0001]], observation_covariance=[[0.01]],
#                  initial_state_mean=60, initial_state_covariance=100)

#(filtered_state_means, filtered_state_covariances) = kf.filter(meas_values)

#print(filtered_state_means)
#print(filtered_state_covariances)

plt.figure(0)
#plt.plot(accel_z, accel_x, '.' )
plt.plot(accel_z, force, 'o' )
plt.grid(True)

plt.figure(1)
plt.plot(t, force)
plt.plot(t, accel_z)
plt.plot(t, accel_x)
plt.plot(t, hoho_fit)
plt.grid(True)

plt.figure(2)
plt.subplot(3, 1, 1)
plt.plot(t, e)
plt.plot(t, avg_trend)
plt.plot(t, ema_trend)
plt.plot(t, med_trend)
plt.plot(t, dc)
plt.grid(True)
plt.subplot(3, 1, 2)
plt.plot(t, force)
plt.plot(t, x)
plt.plot(t, y)
plt.grid(True)
plt.subplot(3, 1, 3)
plt.plot(t, w)
plt.grid(True)

plt.figure(4)
plt.plot(t, accel_z)
plt.plot(t, force)
plt.plot(t, cusum_accel_z)
plt.plot(t, cusum_accel_x)
plt.plot(t, cusum_force)
plt.grid(True)

#b, a = butter(1, (2*100/10e3), 'low')
#scope_filtered = filtfilt(b, a, scope)
#scope_med = medfilt(scope, kernel_size=99)

#plt.figure(5)
#plt.plot(t_scope, scope)
#plt.plot(t_scope, scope_filtered)
#plt.plot(t_scope, scope_med)
#plt.grid(True)


b, a = butter(5, (2*100/fs), 'low')
az = filtfilt(b, a, accel_z)
#az = accel_z
ax = filtfilt(b, a, accel_z)
#ax = accel_x
fc = filtfilt(b, a, force)
#fc = force

x = np.column_stack((az, ax))
flms = pa.filters.FilterLMS(n=2, mu=0.1)
y, e, w = flms.run(fc, x)

#med_test = medfilt(y, kernel_size=WS)

#az = medfilt(accel_z, kernel_size=3)
#fc = medfilt(force, kernel_size=3)
xcorr = correlate(accel_z, force)
lags = np.arange(-len(force) + 1, len(accel_z))

plt.figure(5)
plt.subplot(2, 1, 1)
plt.plot(t, 1.3*fc)
plt.plot(t, az)
plt.plot(t, 1.3*fc - az)
plt.plot(t, med_trend)
plt.plot(t, e)
#plt.plot(t, medfilt(e, kernel_size=11))
plt.grid(True)
plt.subplot(2, 1, 2)
plt.stem(lags, xcorr)
plt.grid(True)

plt.show()