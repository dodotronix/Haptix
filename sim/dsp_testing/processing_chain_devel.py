import numpy as np
import matplotlib.pyplot as plt
from scipy.signal import lfilter, filtfilt, butter

#data = np.loadtxt("../../meas/table_setup/channels_470us_double_vibration_fz.csv", delimiter=',', skiprows=2)
#data = np.loadtxt("../../meas/table_setup/channels_470us_offset_vibration_fz.csv", delimiter=',', skiprows=1)
#data = np.loadtxt("../../meas/table_setup/channels_470us_grinder_simul_fz.csv", delimiter=',', skiprows=1)
data = np.loadtxt("../../meas/table_setup/channels_470us_simple_offset_fz.csv", delimiter=',', skiprows=1)

Ts = 470e-6 # [s]
fs = 1/Ts # [Hz]

def to_fxp(x, q):
    if x == 1:
        return 2**q - 1
    return int(round(x*(2**q)))

Q = 15
Q_ONE = 32767
ADC_RESOLUTION = 9

OFFSET_N = 4
LIMIT_OFFSET = 200
NOISE = 2620 # 0.02
alpha = 0.08
ALPHA = to_fxp(alpha, Q)
THRES = np.int32(2 << Q)
PRECISION = 6
head = 0

LAG = 64
DIV = 6
EXTEND = 2

DLY = 3
K = 0.62
K_FXP = to_fxp(K, Q)

def list_to_fxp(x, q):
    return np.array([to_fxp(i, q) for i in x])

def to_float(x, q):
    return x / (2**q)

def fmul(a, b):
    tmp = (a*b)
    # symmetrical rounding
    tmp += np.where(tmp >= 0, (1 << (Q - 1)), -(1 << (Q - 1)))
    print(a, b, tmp)

    # when the number is negative and it
    # it can reach 0 using bit shift
    # we have to force it with this
    # condition
    if (tmp < 0) and not (abs(tmp) >> Q):
        tmp = 0

    tmp = tmp >> Q

    print(f"result: {tmp}")

    # saturation
    if tmp > Q_ONE:
        return Q_ONE
    elif tmp < -(Q_ONE + 1):
        return -(Q_ONE + 1)

    return tmp

lut_sqrt = np.array([np.sqrt(x/(2**(Q + 2*EXTEND + DIV - PRECISION))) for x in range(256)])
lut = np.array([to_fxp(x, Q) for x in lut_sqrt])

def sqrt_q(x):
    # bit shift defines the precision
    # of the values in the table
    index = x >> PRECISION

    if index > 255:
        print("LUT SQRT OVERFLOW")
        index = 255

    return lut[index]

b, a = butter(2, (2*120/fs), 'low')

b_fxp = list_to_fxp(b, Q)
a_fxp = list_to_fxp(a, Q)

# measured data from each channel traformed to Q1.15 format
measured0 = np.zeros(len(data))
measured1 = np.zeros(len(data))
for i in range(len(data)):
    measured0[i] = (int(data[i, 0] - 512) << (Q - ADC_RESOLUTION))
    measured1[i] = (int(data[i, 1] - 512) << (Q - ADC_RESOLUTION))

# signal conditioning
offset0 = np.mean(measured0[:OFFSET_N])
offset1 = np.mean(measured1[:OFFSET_N])

scaled0 = np.concatenate((np.zeros(DLY, dtype=np.int32), measured0[OFFSET_N:-DLY] - offset0))
scaled1 = np.zeros(len(measured1[OFFSET_N:]), dtype=np.int32)
for i in range(OFFSET_N, len(scaled1)):
    tmp = np.int32(measured1[i] - offset1)
    scaled1[i] = fmul(K_FXP, tmp)

t = np.linspace(0, len(scaled1)*Ts, len(scaled1))

def butter_q(b, a, signal):
    tmp = np.zeros(len(signal), dtype=np.int32)

    def butter_q_smp(b, a, input, output):
        result = 0
        for n in range(3):
            result += fmul(b[2-n], input[n])
        for n in range(1, 3):
            result -= fmul(a[3-n], output[n])
        return result

    for i in range(len(signal)):
        if(i < 3):
            input = np.concatenate((np.zeros(2-i), signal[:i+1]))
            output = np.concatenate((np.zeros(3-i), tmp[:i]))
        else:
            input = signal[i-2: i+1]
            output = tmp[i-3: i]

        input = input.astype(np.int32)
        output = output.astype(np.int32)
        tmp[i] = butter_q_smp(b, a, input, output)
    return tmp

filtered0 = butter_q(b_fxp, a_fxp, scaled0)
filtered1 = butter_q(b_fxp, a_fxp, scaled1)

sub = filtered0 - filtered1

# DEBUGGING
#sub = sub[800:810]
#print(sub)

# simulate reading
N = len(sub)
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
    print(f"value: {sub[i-1]}")
    limit[i] = fmul(THRES, sqrt_q(varSum[i-1])) + LIMIT_OFFSET
    input[i] = np.abs(sub[i-1] - (wSum[i-1] >> DIV))
    print(f"limit: {limit[i]}, input: {input[i]}")

    # We don't have to do this on MCU, because
    # we don't visualize the charts there
    events[i] = events[i-1]

    if (input[i] > limit[i]):
        delta = sub[i-1] - filtered[i - 1]
        filtered[i] = filtered[i-1] + fmul(ALPHA, delta)
        filtered_float[i] = (alpha*fdata[i]) + (1 - alpha)*filtered_float[i-1]

        # TODO we need second parameter to check, if the
        #  signal is above noise floor to be certain, the
        # detection is correct
        if (sub[i - 1] > (wSum[i - 1] >> DIV)) and (input[i] > NOISE) and not events[i]:
            events[i] = 1

    else:
        filtered[i] = sub[i-1]
        filtered_float[i] = fdata[i]

        # NOTE we use the static threshold to reset event signal,
        # in the application has to be used relative threshold to
        # the actual magnitude of the signal
        if(sub[i-1] < 1000) and events[i]:
            events[i] = 0

    # update variance and average (we keep the average as sum,
    # and we do the division as part of other math operations)
    aa = filtered[i] - circ_buf[head]
    wSum[i] = wSum[i-1] + aa
    bb = filtered[i] - ((wSum[i] + wSum[i-1]) >> DIV) + circ_buf[head]

    print(f"aa: {aa}, bb: {bb}, extended aa: {aa << EXTEND}, extended bb: {bb << EXTEND}")

    # NOTE don't forget that the varSum[i]
    # has to be devided by number of LAG
    print(f"fmul var: {(fmul(aa << EXTEND, bb << EXTEND))}")
    varSum[i] = varSum[i-1] + (fmul(aa << EXTEND, bb << EXTEND))

    # important to limit the values to  smallest
    # value for givven resolution Q, since there
    # might be miss matches # in the calculations
    # caused by the # finite precision of fxp
    # numbers
    if varSum[i] <= 10:
        varSum[i] = 10;

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

    print(f"filtered: {filtered[i]}")
    print(f"avg: {wSum[i] >> DIV}, {real_mu[i]} -> {to_fxp(real_mu[i], Q)}")
    print(f"var: {varSum[i]}, -> {varSum[i]/(2**(Q + 2*EXTEND + DIV))},  {real_var[i]} -> {to_fxp(real_var[i], Q)}")
    print(f"stddev: {sqrt_q(varSum[i])}, {real_std[i]} -> {to_fxp(real_std[i], Q)}")
    print("")

    circ_buf[head] = filtered[i]
    head = (head + 1) & (LAG - 1)

print(f"LUT: {lut}")
print(f"DELAY force: {DLY}")
print(f"K acceleration: {K_FXP}")
print(f"ALPHA: {ALPHA}")
print(f"b: {b_fxp}, a: {a_fxp}")

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
plt.plot(t, to_float(NOISE*np.ones(len(filtered)), Q), label='noise floor', linestyle='-.')
plt.legend(fontsize=16)
plt.grid(True)

plt.show()