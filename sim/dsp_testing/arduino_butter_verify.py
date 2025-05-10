import numpy as np
from scipy.signal import lfilter, butter, filtfilt

Ts = 500e-6 # [s]
fs = 1/Ts # [Hz]
Q = 15
#b, a = butter(2, (2*120/fs), 'low')

# dummy coeffs
a = [1.0, 0.1, 0.01]
b = [0.5, 0.05, 0.005]

def to_fxp(x, q):
    if x == 1:
        return 2**q - 1
    return int(round(x*(2**q)))

b_fxp = [to_fxp(x, Q) for x in b]
a_fxp = [to_fxp(x, Q) for x in a]
print(f"butterworth coeffs: a={a}, b={b}")
print(f"fixed point butterworth coeffs: a={a_fxp}, b={b_fxp}")

input_raw = [512, 400, 580, 600, 800, 1000, 1020, 200, 300, 443, 700, 100, 300, 443, 700, 100]
input_raw_q = [int(i - 512) << (Q - 10) for i in input_raw]
print(input_raw_q)

# transfer input signal to float
input_signal = np.array(input_raw_q)/(2**Q)
print(input_signal)
print("")

# take 4 samples and calculate offset
offset = np.mean(input_signal[:4])
print(f"offset: {offset} {to_fxp(offset, Q)}")

input_signal = input_signal[4:] - offset
print(f"signal offsetted: {input_signal} ")
print(f"fxp signal offsetted: {[to_fxp(x, Q) for x in input_signal]}")

# delay signal
#dly = 3
#input_shifted = np.concatenate((np.zeros(dly), input_signal[:-dly]))
input_shifted = input_signal

# scaled data
#k = 0.56
k = 1
k_fxp = to_fxp(k, Q)
print(f"factor: {k} -> {k_fxp} ")
print(f"scaled signal: {k*input_shifted}")
print(f"fxp scaled signal: {[to_fxp(k*x, Q) for x in input_shifted]}")

# pass it to the filter
output_signal = lfilter(b, a, k*input_shifted)
print(f"output signal: {output_signal}")
print(f"fxp output signal: {[to_fxp(x, Q) for x in output_signal]}")