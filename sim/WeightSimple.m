clc
clear all
close all

pkg load control
pkg load signal

f = 10;
vibmag = 5;


#force_s = load("defined_weight_1.6846_1V_0.5s_21kohm/force_154237.txt");
force_s = load("defined_weight_1.6846_1V_1s_61kohm/force_154043.txt");
force_s = force_s(1:5:end);

dc_offset = 78;
f = movmedian(force_s-dc_offset, 200);

reading = 0;
test = f;
new_s = [];

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
subplot(2, 1, 1)
plot(new_s)
grid on
subplot(2, 1, 2)
plot(new_s_abs-0.5)
grid on
