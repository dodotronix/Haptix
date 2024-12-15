clc
clear all
close all

% motor freq 101.33 Hz

pkg load signal

fs = 100e3;


%force_s = load("hand_vibrations_500ms_100kSmp_2V_amp_66kohm_accelerometer_on_the_load_cell/force_164943.txt");
accel_s = load("hand_vibrations_500ms_100kSmp_2V_amp_66kohm_accelerometer_on_the_load_cell/accel_0.txt");

force_s = load("first_test/extra/samp_bouchani");
%force_s = load("shaking_1_61kohm/force_163758.txt");
%force_s = load("shaking_1_61kohm/force_164245.txt");
%force_s = load("shaking_1_61kohm/force_164436.txt");
%accel_s = load("shaking_1_61kohm/accel_0.txt");

%accel = load("touch_1_amp_21kohm_500ms_100ksmp_2V/accel_0.txt");
%force_s = load("touch_0/force_144032.txt");
%force_s = load("touch_1_amp_21kohm_500ms_100ksmp_2V/force_161508.txt");
%force_s = load("hand_vibrations_500ms_100kSmp_2V_amp_66kohm_accelerometer_on_the_load_cell/force_164943.txt");

force = force_s(1:400:end);
accel = accel_s(1:length(force), :);


%fs1 = 100e3;
%sig = force_s(1:fs/fs1:end);
fs1 = 1e3;
sig = force_s(1e4:end-1e4);
win = 2e3;

%fs1 = 250;
%sig = accel(1:end, 3);
%win = 250;


t = [0:length(sig)-1]/fs1;


Y = fft(sig);
PSD = abs(Y).^2/length(Y);
fx = [0:length(PSD)-1]*fs1/length(PSD);

indices = ((PSD > 2e7));
denoised_PSD = indices.* PSD;

denoised_Y = indices.* Y;
denoised_sig = ifft(denoised_Y);


figure;
subplot(2, 1, 1)
plot(t, sig);
grid on
subplot(2, 1, 2)
plot(t, denoised_sig);
grid on


figure;
plot(fx, PSD)
hold on
plot(fx, denoised_PSD)
grid on
xlim([0 fs1/2])
ylim([0 2e3])


% spectrogram

figure;
specgram(sig, win, fs1)

figure;
specgram(denoised_sig, win, fs1)

