import numpy as np
import matplotlib.pyplot as plt
from scipy.signal import lfilter, filtfilt, butter

#data = np.loadtxt("../../meas/table_setup/channels_simple_vibration_fzx.csv", delimiter=',', skiprows=1)
#data = np.loadtxt("../../meas/table_setup/channels_simple_offset_fzx.csv", delimiter=',', skiprows=1)
#data = np.loadtxt("../../meas/table_setup/channels_offset_vibration_steep_fzx.csv", delimiter=',', skiprows=1)
#data = np.loadtxt("../../meas/table_setup/channels_offset_vibration_fzx.csv", delimiter=',', skiprows=1)
data = np.loadtxt("../../meas/table_setup/channels_simple_offset_drift_fzx.csv", delimiter=',', skiprows=2)

Ts = 500e-6 # [s]
fs = 1/Ts # [Hz]
Q = 15
Q_ONE = 32767

ALPHA = 328
alpha = 0.01
THRES = np.int32(4 << Q)
noise = 983
head = 0

LAG = 32
DIV = 5
EXTEND = 2

def to_fxp(x, q):
    if x == 1:
        return 2**q - 1
    return int(round(x*(2**q)))

def list_to_fxp(x, q):
    return np.array([to_fxp(i, q) for i in x])

def to_float(x, q):
    return x / (2**q)

def fmul(a, b):
    tmp = a*b
    return (tmp + np.int32(1 << (Q-1))) >> Q

def sqrt_q(x):
    if x > 255:
        print("LUT SQRT OVERFLOW")
        return to_fxp(np.sqrt(255 / (2**(Q + 2*EXTEND + DIV))), Q)
    return to_fxp(np.sqrt(x / (2**(Q + 2*EXTEND + DIV))), Q)

b, a = butter(2, (2*120/fs), 'low')

b_fxp = list_to_fxp(b, Q)
a_fxp = list_to_fxp(a, Q)
print(b_fxp, a_fxp)

# measured data from each channel traformed to Q1.15 format
measured0 = np.zeros(len(data))
measured1 = np.zeros(len(data))
for i in range(len(data)):
    measured0[i] = (int(data[i, 0] - 512) << (Q - 10))
    measured1[i] = (int(data[i, 1] - 512) << (Q - 10))

# signal conditioning
OFFSET_N = 4
offset0 = np.mean(measured0[:OFFSET_N])
offset1 = np.mean(measured1[:OFFSET_N])

DLY = 3
K = 0.62
K_FXP = to_fxp(K, Q)
scaled0 = np.concatenate((np.zeros(DLY), measured0[OFFSET_N:-DLY] - offset0))
scaled1 = K_FXP*(measured1[OFFSET_N:] - offset1) / (2**Q)
t = np.linspace(0, len(scaled1)*Ts, len(scaled1))
print(scaled1)

# filter data
filtered0 = lfilter(b_fxp, a_fxp, scaled0)
filtered1 = lfilter(b_fxp, a_fxp, scaled1)
sub = np.int32(filtered0 - filtered1)

# simulate reading
N = len(filtered0)
wSum = np.zeros(N, dtype=np.int32)
varSum = np.zeros(N, dtype=np.int32)
stddev = np.zeros(N, dtype=np.int32)
limit = np.zeros(N, dtype=np.int32)
input = np.zeros(N, dtype=np.int32)
events = np.zeros(N, dtype=np.int32)
filtered = np.zeros(N, dtype=np.int32)
circ_buf = np.zeros(LAG, dtype=np.int32)

real_var = np.zeros(N)
real_mu = np.zeros(N)
real_std = np.zeros(N)
filtered_float = np.zeros(N)

fdata = sub / (2 ** Q)

for i in range(1, N):
    limit[i] = fmul(THRES, sqrt_q(varSum[i-1]))
    input[i] = np.abs(sub[i] - (wSum[i-1] >> DIV))

    if ((input[i] > limit[i]) and (limit[i] > 0)):
        events[i] = 0
        ema_a = fmul(ALPHA, sub[i])
        ema_b = fmul(Q_ONE - ALPHA, filtered[i - 1])
        filtered[i] = ema_a + ema_b
        filtered_float[i] = (alpha*fdata[i]) + (1 - alpha)*filtered_float[i-1]

        if (sub[i] > (wSum[i - 1] >> DIV)) and (sub[i] > noise):
            events[i] = 1
    else:
        filtered[i] = sub[i]
        filtered_float[i] = fdata[i]
        events[i] = 0

    # update variance and average (we keep the average as sum,
    # and we do the division as part of other math operations)
    aa = filtered[i] - circ_buf[head]
    wSum[i] = wSum[i-1] + aa
    bb = filtered[i] - ((wSum[i] + wSum[i-1]) >> DIV) + circ_buf[head]

    print(f"aa: {aa}, bb: {bb}, extended aa: {aa << EXTEND}, extended bb: {bb << EXTEND}")
    # NOTE don't forget that the varSum[i]
    # has to be devided by number of LAG
    varSum[i] = varSum[i-1] + (fmul(aa << EXTEND, bb << EXTEND))

    # important to limit the values to 0,
    # since there might be miss matches
    # in the calculations caused by the
    # finite precision of fxp numbers
    if varSum[i] < 0:
        varSum[i] = 0;

    stddev[i] = sqrt_q(varSum[i])

    if(i < LAG):
        tmp = np.concatenate((np.zeros(LAG-(i+1)), filtered_float[:i+1]))
        real_mu[i] = np.mean(tmp)
        real_var[i] = np.var(tmp)
        real_std[i] = np.std(tmp)
    else:
        tmp = filtered_float[(i+1)-LAG:(i+1)]
        real_mu[i] = np.mean(tmp)
        real_var[i] = np.var(tmp)
        real_std[i] = np.std(tmp)

    print(f"avg: {wSum[i] >> DIV}, {real_mu[i]} -> {to_fxp(real_mu[i], Q)}")
    print(f"var: {varSum[i]}, -> {varSum[i]/(2**(Q + 2*EXTEND + DIV))},  {real_var[i]} -> {to_fxp(real_var[i], Q)}")
    print("")

    circ_buf[head] = filtered[i]
    head = (head + 1) & (LAG - 1)

plt.figure(0)
plt.plot(t, filtered0, label='force')
plt.plot(t, filtered1, label='acceleration')
plt.plot(t, sub, label='subtraction')
plt.legend(fontsize=16)
plt.grid(True)

plt.figure(1)
plt.plot(t, to_float(sub, Q), label='subtraction')

plt.plot(t, real_mu, label='real average')
# the wSum is just sum but needs to be devided by Window
plt.plot(t, to_float(wSum, Q+DIV), label="q average")

plt.plot(t, to_float(limit, Q), label='limit', linestyle="--")
plt.plot(t, to_float(input, Q), label='input', linewidth=2)

plt.plot(t, np.sqrt((varSum/(2**(Q + 2*EXTEND + DIV)))), label="q std")
plt.plot(t, to_float(stddev, Q), label="q std LUT")
plt.plot(t, real_std, label='real std')

plt.plot(t, to_float(filtered, Q), label='filtered')
plt.plot(t, events, label='events')
plt.legend(fontsize=16)
plt.grid(True)

plt.show()