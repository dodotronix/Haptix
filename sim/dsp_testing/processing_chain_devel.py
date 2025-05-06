import numpy as np
import matplotlib.pyplot as plt
import padasip as pa

from scipy.signal import lfilter, filtfilt, butter

#data = np.loadtxt("../../meas/table_setup/channels_simple_vibration_fzx.csv", delimiter=',', skiprows=1)
#data = np.loadtxt("../../meas/table_setup/channels_simple_offset_fzx.csv", delimiter=',', skiprows=1)
#data = np.loadtxt("../../meas/table_setup/channels_offset_vibration_steep_fzx.csv", delimiter=',', skiprows=1)
#data = np.loadtxt("../../meas/table_setup/channels_offset_vibration_fzx.csv", delimiter=',', skiprows=1)
#data = np.loadtxt("../../meas/table_setup/channels_simple_offset_drift_fzx.csv", delimiter=',', skiprows=1)

Ts = 150e-6
fs = 1/Ts
v = 0.7 #cm/s, peak lasts for (5.2ms -> 0.36um)

force = data[:,0]
accel_z = 0.6*data[:,1]
accel_x = data[:,2]

# time shift back
offset = 3
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

t = np.linspace(0, len(force)*Ts*1e3, len(force))

#normalize
accel_x = accel_x/np.max(abs(force))
accel_z = accel_z/np.max(abs(force))
force = force/np.max(abs(force))

# signal conditioning
b, a = butter(1, (2*150/fs), 'low')
print(b, a)
accel_z = filtfilt(b, a, accel_z)
force = filtfilt(b, a, force)

#DEBUG
#force = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
#accel_z = [1, 5, 4, 4, 10, 8, 7, 12, 9, 10]

alpha = 0.01
beta = 0.1
ema_force = np.zeros(len(force))
ema2_force = np.zeros(len(force))
var_force = np.zeros(len(force))

ema_accel = np.zeros(len(force))
ema2_accel = np.zeros(len(force))
var_accel = np.zeros(len(force))

mu = 1e-1
L = 3
w = np.zeros((L, len(force)))
w_prev = np.array([0, 0, 0])
y = np.zeros(len(force))
e = np.zeros(len(force))
e_prev = 0

kalman_est = np.zeros(len(force))
P = 0
r = 10
q = 1
x_est = 0

df = np.zeros(len(force))
da = np.zeros(len(force))
direct_prev = 0

direct_sub = np.zeros(len(force))

for n,f in enumerate(force):

    # derivative
    if n == 1:
        da[n] = (accel_z[n+1] - accel_z[n])
        df[n] = (force[n+1] - force[n])
    elif (n > 0) and (n < len(force)-1):
        da[n] = accel_z[n+1] - accel_z[n-1]
        df[n] = force[n+1] - force[n-1]
    else:
        da[n] = (accel_z[n-1] - accel_z[n])
        df[n] = (force[n-1] - force[n])

    try:
        ema_force[n] = alpha*f + (1-alpha)*ema_force[n-1]
        ema2_force[n] = alpha*(f**2) + (1-alpha)*ema2_force[n-1]
        ema_accel[n] = alpha*accel_z[n] + (1-alpha)*ema_accel[n-1]
        ema2_accel[n] = alpha*(accel_z[n]**2) + (1-alpha)*ema2_accel[n-1]
    except:
        ema_force[n] = alpha*f
        ema2_force[n] = alpha*(f**2)
        ema_accel[n] = alpha*accel_z[n]
        ema2_accel[n] = alpha*(accel_z[n]**2)

    var_force[n] = ema2_force[n] - ema_force[n]**2
    var_accel[n] = ema2_accel[n] - ema_accel[n]**2

    #LMS algorithm
    if (n > len(force)-L):
        #x = np.concatenate((accel_z[n:n + L-1], np.ones(1), np.zeros(L-1 - (len(force)-n))))
        x = np.concatenate((accel_z[n:n+L], np.zeros(L - (len(force)-n))))
        #force_tmp = np.concatenate((force[n:n+L], np.zeros(L - (len(force)-n))))
        #accel_z_tmp = np.concatenate((accel_z[n:n+L], np.zeros(L - (len(accel_z)-n))))
        #x = force_tmp - accel_z_tmp
    else:
        # DIFFERENT FEEDBACKS
        #x = force[n:n+L] - accel_z[n:n+L]
        x = accel_z[n:n+L]
        #x = np.concatenate((accel_z[n:n+L-1], accel_x[n:n+L-1]))
        #x = np.concatenate((accel_z[n:n+L-1], np.ones(1)))
        #x = np.concatenate((accel_z[n:n+L-1], [dyn*(f - accel_z[n])]))
        #x = np.concatenate((accel_z[n:n+L-1], [(var_force[n]-var_accel[n])**2]))
        #x = np.concatenate((accel_z[n:n+L-1], [(var_force[n]-var_accel[n])]))

    # setup the boundary, where we can simply zero the samples in force data
    # TODO this is not going to work for the vibrations when there is a offset
    #tmp = 0 if ((ema2_force[n] - ema2_accel[n]) < 0.008) and ((np.abs(da[n]) > 0.01) or (var_accel[n] > 0.05)) else f - accel_z[n]
    tmp = 1 if ((ema2_force[n] - ema2_accel[n]) < 0.008) and ((np.abs(da[n]) > 0.01) or (var_accel[n] > 0.05)) else f - accel_z[n]
    direct_sub[n] = beta*tmp + (1-beta)*direct_prev
    direct_prev = direct_sub[n]

    # 1D kalman filter
    x_pred = x_est

    P_pred = P + q
    K = P_pred/(P_pred + r)
    x_est = x_pred + K*(direct_sub[n] - x_pred)
    P = (1 - K)*P_pred
    kalman_est[n] = x_est

    # LMS
    y[n] = np.dot(w_prev, x)
    e[n] = (direct_sub[n] - y[n])
    e_prev = f - accel_z[n]
    w[:, n] = w_prev + 2 * mu * e[n] * x
    w_prev = w[:, n]

    #zscore[n] = (force[n] - ema_force[n])/var_force[n]

# zero-score detection
def zero_score_detection(data, lag=1, threshold=0, alpha=0.1):
    signals = np.zeros(len(data))
    filtered_data = np.array(data)
    avgFilter = np.zeros(len(data))
    stdFilter = np.zeros(len(data))
    avgFilter[lag-1] = np.mean(data[0:lag])
    stdFilter[lag-1] = np.std(data[0:lag])

    for i in range(lag, len(data)):
        if abs(data[i] - avgFilter[i-1]) > threshold * stdFilter[i-1]:
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

sigs, avgF, stdF, fdata = zero_score_detection(kalman_est, 200, 6, 0.008)

plt.figure(0)
plt.plot(t, force, label='force')
plt.plot(t, accel_z, label='acceleration (z)')
plt.plot(t, ema_force, label='EMA load cell')
plt.plot(t, ema_accel, label='EMA acceleration')
plt.plot(t, kalman_est, label=f'kalman')
plt.plot(t, var_force, label='VAR force')
plt.plot(t, var_accel, label='VAR accel')
plt.legend(fontsize=16)
plt.grid(True)

plt.figure(1)
plt.subplot(2, 1, 1)
plt.plot(t, force, label='force [in]')
plt.plot(t, accel_z, label='acceleration [in]')
plt.plot(t, y, label=f'adapted [out]')
plt.plot(t, e, label=f'error')
plt.plot(t, force - accel_z, label='difference')
plt.plot(t, kalman_est, label=f'kalman')
plt.plot(t, sigs, label='events detected')
plt.legend(fontsize=16)
plt.grid(True)
plt.subplot(2, 1, 2)
for i in range(w.shape[0]):
    plt.plot(t, w[i, :], label=f'w{i+1}')
plt.legend(fontsize=16)
plt.grid(True)

plt.figure(2)
plt.subplot(2, 1, 1)
plt.plot(t, force, label=f'force')
plt.plot(t, accel_z, label='acceleration')
plt.plot(t, kalman_est, label=f'kalman')
plt.plot(t, ema2_force, label='EMA2 force')
plt.plot(t, ema2_accel, label='EMA2 accel')
plt.plot(t, var_force, label='VAR force')
plt.plot(t, var_accel, label='VAR accel')
plt.legend(fontsize=16)
plt.grid(True)
plt.subplot(2, 1, 2)
plt.plot(t, force, label=f'force')
plt.plot(t, kalman_est, label=f'kalman')
plt.plot(t, df, label="force derivative")
plt.plot(t, da, label="acceleration derivative")
plt.plot(t, direct_sub, label="direct subtraction")
plt.legend(fontsize=16)
plt.grid(True)

plt.figure(3)
plt.plot(t, force, label='force')
plt.plot(t, kalman_est, label=f'kalman')
plt.plot(t, fdata, label='filtered data')
plt.plot(t, stdF, label='standard deviation')
plt.plot(t, avgF, label='average')
plt.plot(t, sigs, label='events detected')
plt.legend(fontsize=16)
plt.grid(True)

plt.show()