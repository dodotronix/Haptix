clc
clear all
close all

pkg load control
pkg load signal

first_test = load("first_test/mess_24-bit/samp_2_24bit");
force_s = load("touching_10ksmp_2V_5s_61kohm/force_152849.txt");
force_s = force_s(69800:3e5);

# filter down to 500Hz with lowpass first orderfields
[b, a] = butter(1, 2*500/10e3, 'low');
force_s = filter(b, a, force_s);


t = [0:length(force_s)-1]/10e3;

test = detrend(force_s, 2);
new_s = [];

reading = 0;
for i = 1:length(test)
  if(reading == 0)
    reading = test(i);
  elseif (test(i) > reading)
    reading = reading + 1;
  else
    reading = reading -1;
  endif

  new_s(i) = reading;
end

new_s_abs = abs(new_s);
envelope_s = [];
prev_envelope = 0;
alpha = 0.01;

for i = 1:length(new_s_abs)
  envelope_s(i) = alpha*new_s_abs(i) + (1 - alpha)*prev_envelope;
  prev_envelope = envelope_s(i);
end

figure;
plot(first_test)
grid on


figure;
plot(t, force_s)
grid on

figure;
plot(test)
grid on

figure;
plot(new_s)
hold on
plot(envelope_s)
grid on
