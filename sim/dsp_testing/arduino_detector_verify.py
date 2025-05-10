import numpy as np

def to_fxp(x, q):
    if x == 1:
        return 2**q - 1
    return int(round(x*(2**q)))

Q = 15
alpha = 0.01
threshold = 4
detector = 0.03
lag = 4
circ_buf = np.zeros(lag)
head = 0

print(f"alpha {alpha} -> {to_fxp(alpha, Q)}")
print(f"detector {detector} -> {to_fxp(detector, Q)}")
print(f"threshold {threshold} -> {to_fxp(threshold, Q)}")

# generate sqrt table
sqrt_lut = [to_fxp(np.sqrt(x/(2**Q)), Q) for x in range(256)]
print(f"sqrt LUT: {sqrt_lut}")

input_raw = [512, 400, 580, 600, 800, 1000, 1020, 200, 300, 443, 700, 100]
input_raw_q = [int(i - 512) << (Q - 10) for i in input_raw]
print(input_raw_q)

# transfer input signal to float
input_signal = np.array(input_raw_q)/(2**Q)
print(input_signal)
print("")

avgFilt = np.zeros(len(input_signal))
avgFilt_py = np.zeros(len(input_signal))
stdFilt = np.zeros(len(input_signal))
stdFilt_py = np.zeros(len(input_signal))
events = np.zeros(len(input_signal))
filtered = np.zeros(len(input_signal))

for i in range(1, len(input_signal)-lag):
    filtered[i] = input_signal[i]
    limit = threshold * np.sqrt(stdFilt[i-1])
    input = np.abs(input_signal[i] - avgFilt[i-1])
    ema_a = alpha*input_signal[i]
    ema_b = (1 - alpha)*filtered[i-1]

    print(f"input signal: {input_signal[i]} {to_fxp(input_signal[i], Q)}")
    print(f"last average filter: {avgFilt[i - 1]} {to_fxp(avgFilt[i - 1], Q)}")
    print(f"last variance: {stdFilt[i - 1]} {to_fxp(stdFilt[i - 1], Q)}")
    print(f"limit: {limit} {to_fxp(limit, Q)}")
    print(f"input: {input} {to_fxp(input, Q)}")
    print(f"ema_a: {ema_a} {to_fxp(ema_a, Q)}")
    print(f"ema_b: {ema_b} {to_fxp(ema_b, Q)}")

    if ((input > limit) and (limit > 0)):
        events[i] = 0
        if (input_signal[i] > avgFilt[i - 1]) and (input_signal[i] > detector):
            events[i] = 1
        filtered[i] = ema_a + ema_b
    else:
        filtered[i] = input_signal[i]
        events[i] = 0

    # average and variance update
    old = circ_buf[head]
    avg_old = avgFilt[i-1]
    avgFilt[i] = avg_old + (filtered[i] - old)/lag
    stdFilt[i] = stdFilt[i-1] + (filtered[i] - old)*(filtered[i] - avgFilt[i] + old - avg_old)/lag

    print(f"filtered: {filtered[i]} {to_fxp(filtered[i], Q)}")
    print(f"avgFilt: {avgFilt[i]} {to_fxp(avgFilt[i], Q)}")
    print(f"stdFilt: {stdFilt[i]} {to_fxp(stdFilt[i], Q)}")
    print(f"stddev: {np.sqrt(stdFilt[i])} {to_fxp(np.sqrt(stdFilt[i]), Q)}")
    print("")

    # circular buffer update
    circ_buf[head] = filtered[i]
    head = (head + 1) & (lag - 1)
