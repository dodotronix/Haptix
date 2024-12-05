clc
clear all
close all

pkg load control
pkg load signal

force_s = load("hand_vibrations_500ms_100kSmp_2V_amp_66kohm_accelerometer_on_the_load_cell/force_164943.txt");


fs = 100e3;
mu = mean(force_s)
force_imp = force_s(4.332e5:4.332e5+27e3) - mu;


pwidth = 600;
pshift = 0;
sim_input_s = [zeros(pshift, 1); ...
               ones(pwidth, 1);...
               zeros(length(force_imp)-pwidth-pshift, 1)];


[b, a] = butter(2, 5e2*2/fs);
input_s = filter(b, a, sim_input_s);
%input_s = force_imp / max(force_imp);

[b, a] = butter(2, 5e3*2/fs);
force_imp_filtered = filter(b, a, force_imp);
output_s = force_imp_filtered / max(force_imp_filtered);


X = fft(input_s);
Y = fft(output_s);
H = Y./X;

h = real(ifft(H));


figure;
plot(input_s)
hold on
plot(output_s)
grid on

figure;
plot(abs(H))
grid on

figure;
plot(h)
grid on


test = filter(b, a, force_s);
test_conv = conv(test, h);

figure;
plot(test_conv)
grid on

