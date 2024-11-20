clc
clear all
close all

% motor freq 101.33 Hz


pkg load signal

accel = load("accel_0.txt");
force = load("force_161508.txt");

%force = load("force_162337.txt");
%force = load("force_162946.txt");
%force = load("force_144032.txt");


accel_z = accel(1:1500, 3);
accel_z_aligned = [accel_z; zeros(548, 1)];
length(accel_z_aligned)


taccel = [0:length(accel_z)-1]/250;
t = [0:length(force)-1]/1e5;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Y = fft(accel_z_aligned);
fstep = 250/length(accel_z_aligned);
fx = [0:length(accel_z_aligned)-1]*fstep;

IR2 = [zeros(168, 1); ones(345, 1); zeros(1024-345-168, 1)];
IR = [IR2; flip(IR2)];


%Ynew = IR.*Y;
%ynew = real(ifft(Ynew));
%[b, a] = butter(5, 45*2/250);
[b, a] = butter(2, [4*2/250, 60*2/250]);

ynew = filter(b, a, accel_z)

figure()
plot(taccel, 50*accel_z-500)
hold on
plot(t, force)
hold on
plot(taccel, 50*ynew)

figure()
plot(fx(1:end), abs(Y(1:end)).^2)
hold on
plot(fx(1:end), 1e5*IR(1:end))
xlim([0 125])
ylim([0 100000])

%figure()
%plot(force(1:2000*))


[xx, lags] = xcorr(ynew, force(1:400:end)-100);

xx = reshape(xx, 1, []);

figure()
plot(lags/250, xx)
