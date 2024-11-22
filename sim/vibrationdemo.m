clc
clear all
close all

% motor freq 101.33 Hz

pkg load signal

accel_motor = load("motor_moving_up/accel_0.txt");
force = load("motor_moving_up/force_145241.txt");

%accel_s = load("hand_vibrations_500ms_100kSmp_2V_amp_21kohm/accel_0.txt");
accel_s = load("hand_vibrations_500ms_100kSmp_2V_amp_21kohm/accel_1.txt");

%force_s = load("hand_vibrations_500ms_100kSmp_2V_amp_21kohm/force_160311.txt");
force_s = load("hand_vibrations_500ms_100kSmp_2V_amp_21kohm/force_160529.txt");

%accel_s = load("hand_vibrations_500ms_100kSmp_2V_amp_66kohm_accelerometer_on_the_load_cell/accel_0.txt");
%force_s = load("hand_vibrations_500ms_100kSmp_2V_amp_66kohm_accelerometer_on_the_load_cell/force_164943.txt");


accel_mz = accel_motor(1:1500, 3);
accel_z = accel_s(1:1500, 3);
t = [0:length(accel_z)-1]/250;

accel_mz_aligned  = [accel_mz; zeros(548, 1)];
accel_z_aligned = [accel_z; zeros(548, 1)];



force_usmp = reshape(force_s, 400, []);
force_aligned = [force_usmp, zeros(400, 548)];
force_aligned_sum = sum(force_aligned)/400;

[b, a] = butter(2, 2*2/250, 'high');
ynew = filter(b, a, force_aligned_sum);

ynew_integrated = cumtrapz(abs(ynew));
%ynew_derivative = diff(ynew_integrated(1:length(t)))./diff(t);


TEST1 = fft(force_aligned_sum);
YNEW = fft(ynew)

fstep = 250/length(accel_z_aligned);
fx = [0:length(accel_z_aligned)-1]*fstep;


figure()
plot(force_s)
grid on

figure()
plot(accel_s)
grid on


figure()
plot(t, force_aligned_sum(1:length(t)))
hold on
%plot(t, ynew(1:length(t)))
hold on
plot(t, force_aligned(1, 1:length(t)))
%plot(t, ynew_integrated(1:length(t)), '-o')
%hold on
%plot(t(1:end-1), ynew_derivative.^2, '-x')
grid on
%ylim([90 110])

figure()
plot(t, accel_z)
grid on

figure()
plot(fx, abs(TEST1).^2)
xlim([0 125])
ylim([0 1e6])
grid on
