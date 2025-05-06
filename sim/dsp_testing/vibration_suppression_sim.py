import numpy as np
import matplotlib.pyplot as plt

import padasip as pa

# TODO create artificial force signal
# TODO create artificial accelerometer x signal
# TODO create artificial accelerometer z signal

Ts = 150e-6
fs = 1/Ts
v = 0.7 #cm/s, peak lasts for (5.2ms -> 0.36um)

def smooth_pulse(length, start, width, rise_time, amp=1.0):
    sig = np.zeros(length)

    rise_samples = int(rise_time)
    flat_samples = int(width)
    fall_samples = rise_samples

    # Build the pulse shape
    rise = np.linspace(0, amp, rise_samples)
    flat = np.full(flat_samples, amp)
    fall = np.linspace(amp, 0, fall_samples)
    pulse = np.concatenate((rise, flat, fall))
    sig[start:start + len(pulse)] = pulse

    return sig


T = 0.5
alpha = 10e1
f_vib = 100
shift = 510 # samples

t_model = np.linspace(0, T, int(fs*T))
t_partial = t_model[:len(t_model) - shift]

tmp = 1*np.exp(-alpha*t_partial)*np.sin(2*np.pi*f_vib*t_partial)
force_vibration = np.concatenate([np.zeros(shift), tmp])
touch = smooth_pulse(len(t_model), 600, 500, 10, 0.3)
noise = 0.001*np.random.randn(len(t_model))

# TEST impulse response recovery
s0 = np.sin(2*np.pi*f_vib*t_partial)
s1 = 0.2*np.sin(2*np.pi*(f_vib-80)*t_partial)
s2 = 0.9*np.sin(2*np.pi*(f_vib+20)*t_partial)

sig_in = 1*np.exp(-alpha*t_partial)*(s0 + s1 + s2)
sig_out = 1*np.exp(-alpha*t_partial)*(np.sin(2*np.pi*(f_vib-5)*t_partial) + s1 + s2)

U1 = np.fft.fft(sig_in)
U2 = np.fft.fft(sig_out)

H = U2/U1
print(H.shape)
h = np.real(np.fft.ifft(H))
h = h[:300]
test = np.convolve(h, sig_in)

n = np.arange(len(h))

plt.figure(0)
plt.plot(h)
plt.grid(True)

plt.figure(1)
plt.plot(sig_in)
plt.plot(sig_out)
plt.plot(test)
plt.grid(True)

plt.show()