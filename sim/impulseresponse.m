clc
clear all
close all

pkg load control
pkg load signal

force_s = load("hand_vibrations_500ms_100kSmp_2V_amp_66kohm_accelerometer_on_the_load_cell/force_164943.txt");
mu = mean(force_s);
force_imp = force_s(4.336e5:4.336e5+27e3) - mu;
force_imp = force_imp/3e1;


fs = 1e5; %Hz
sim_time = 0.3; %s
N = pow2(floor(log2(sim_time*fs)))

t = [0:N-1]/fs;
force_imp = force_imp(1:length(t));

pshift = 0;
pwidth = 10;

sig_in = [zeros(pshift, 1); ...
               ones(pwidth, 1);...
              zeros(length(t)-pwidth-pshift, 1)];

%h = fir1(200, 1e3/fs);
%fil2 = conv(h, sig_in);
%test = deconv(fil2, h);

% decimate data
force_set = reshape(force_s-mu, 100, []);
force_dec = sum(force_set);
force_norm = force_dec/max(force_dec);


m = 1e2; %kg
b = 1.5e4; %N*s/m
k = 7e6; %N/m

sys = tf(3.8e4, [m b k])
sig_out = lsim(sys, sig_in, t);


Kp = 300;
C = pid(Kp)
T = feedback(C*sys,1)

[y, tout] = impulse(sys,[0:floor(N*1e3/fs)-1]/1e3);

test = ifft(fft(force_norm)./fft(y, length(force_norm)));

figure;
plot(t, force_imp, 'linewidth', 0.5);
hold on
plot(tout, y, 'linewidth', 2)
grid on

figure;
plot(test)
grid on

##figure;
##plot(t, sig_in);
##grid on

##figure;
##plot(sig_out)
##grid on


