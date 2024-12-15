clc
clear all
close all

% motor freq 101.33 Hz

pkg load signal

%force_s = load("shaking_0_21kohm/force_163343.txt");
%accel_s = load("shaking_0_21kohm/accel_0.txt");

%force_s = load("touch_1_amp_21kohm_500ms_100ksmp_2V/force_161508.txt");
%force_s = load("touch_0/force_144032.txt");

%force_s = load("hand_vibrations_500ms_100kSmp_2V_amp_66kohm_accelerometer_on_the_load_cell/force_164943.txt");
accel_s = load("hand_vibrations_500ms_100kSmp_2V_amp_66kohm_accelerometer_on_the_load_cell/accel_0.txt");


%force_s = load("shaking_1_61kohm/force_163758.txt");
%force_s = load("shaking_1_61kohm/force_164245.txt");
%force_s = load("shaking_1_61kohm/force_164436.txt");
%accel_s = load("shaking_1_61kohm/accel_0.txt");

force = force_s(1:400:end);
accel = accel_s(1:length(force), :);


%figure;
%subplot(2, 1, 1)
%plot(force)
%hold on
%plot(y)
%grid on
%subplot(2, 1, 2)
%plot(accel)
%grid on


% kalman algorithm
function out = myKalman(z)
  persistent A H Q R
  persistent x P
  persistent firstRun


if isempty(firstRun)
  A = 1;
  H = 1;

  Q = 1e-2;
  R = 10;

  x = 70;
  P = 6;

  firstRun = 1;
end



xp = A*x; % prediction of estimate
Pp = A*P*A' + Q; % prediction of error cov

K = Pp*H'*inv(H*Pp*H' + R); % Kalman constant

x = xp + K*(z - H*xp); % computation of estimate
P = Pp - K*H*Pp; % computation of error covariance

out = x;
endfunction






fs = 100e3;
dt = 1/fs;
t = [0:length(force_s)-1]*dt;
sys = ss(1, 0, 1, 0, 1/fs);





Nsamples = length(t);

Xsaved = zeros(Nsamples, 1);
Zsaved = zeros(Nsamples, 1);


for k=1:Nsamples
  z = force_s(k);
  volt = myKalman(z);

  Xsaved(k) = volt;
  Zsaved(k) = z;
end


[b, a] = butter(2, [2*2/fs, 50*2/fs]);
force_fil = filter(b, a, Xsaved);






figure;
plot(t, Zsaved)
hold on
plot(t, Xsaved)
grid on

figure;
plot(t, Xsaved);
hold on
plot(t, force_fil);
grid on











