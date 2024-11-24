clc
clear all
close all

% motor freq 101.33 Hz

pkg load signal

accel_motor = load("motor_moving_up/accel_0.txt");
force = load("motor_moving_up/force_145241.txt");

accel = load("touch_0/accel_0.txt");
tforce = load("touch_0/force_144032.txt");

%accel = load("touch_1_amp_21kohm_500ms_100ksmp_2V/accel_0.txt");
%tforce = load("touch_1_amp_21kohm_500ms_100ksmp_2V/force_161508.txt");

accel_mz = accel_motor(1:1500, 3);
accel_z = accel(1:1500, 3);
accel_sz = accel_z - accel_mz;

accel_mz_aligned  = [accel_mz; zeros(548, 1)];
accel_z_aligned = [accel_z; zeros(548, 1)];

accel_sz_aligned = accel_z_aligned - accel_mz_aligned;
taccel = [0:length(accel_z)-1]/250;

Ym = fft(accel_mz_aligned);
Y = fft(accel_z_aligned);
Ys = fft(accel_sz_aligned);
Yss = Y - Ym;

force_usmp = reshape(force, 400, []);
tforce_usmp = reshape(tforce, 400, []);
force_aligned = [force_usmp, zeros(400, 548)];
tforce_aligned = [tforce_usmp, zeros(400, 548)];
force_aligned_sum = sum(force_aligned)/400;
tforce_aligned_sum = sum(tforce_aligned)/400;

%[b, a] = butter(1, [5*2/250, 80*2/250]);
[b, a] = butter(5, 20*2/250, 'high');
ynew = filter(b, a, tforce_aligned_sum);

ynew_integrated = cumtrapz(abs(ynew))/5;
ynew_derivative = diff(ynew_integrated(1:length(taccel)))./diff(taccel);


figure()
%plot(taccel, accel_mz)
%hold on
%plot(taccel, accel_z)
%hold on
%plot(taccel, accel_sz)
plot(taccel, force_usmp(1, 1:end))
hold on
plot(taccel, force_aligned_sum(1:length(accel_mz)))
hold on
plot(taccel, tforce_aligned_sum(1:length(accel_mz)))
hold on
plot(taccel, ynew(1:length(accel_mz)))
hold on
plot(taccel, ynew_integrated(1:length(accel_mz)), '-o')
hold on
plot(taccel(1:end-1), ynew_derivative.^2/3.2e3, '-x')
grid on



TEST1 = fft(force_aligned(1, 1:end));
TEST2 = fft(force_aligned, 2048, 2);
TEST3 = fft(force_aligned_sum);
TEST4 = fft(tforce_aligned_sum);
FILTERED = fft(ynew);

fstep = 250/length(accel_z_aligned);
fx = [0:length(accel_z_aligned)-1]*fstep;


figure()
%plot(fx, 40*abs(Ym).^2)
%hold on
%plot(fx, 40*abs(Y).^2)
%hold on
%plot(fx, abs(Ys).^2)
%hold on
%plot(fx, abs(Yss).^2)
plot(fx, abs(TEST4).^2)
hold on
plot(fx, abs(TEST3).^2)
hold on
plot(fx, abs(FILTERED).^2)
%plot(fx, abs(TEST2).^2)

grid on
xlim([0 125])
ylim([0 1e6])



