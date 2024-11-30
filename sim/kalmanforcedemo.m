clc
clear all
close all





%force_s = load("touch_0/force_144032.txt");
%accel_s = load("touch_0/accel_0.txt");


force_s = load("hand_vibrations_500ms_100kSmp_2V_amp_66kohm_accelerometer_on_the_load_cell/force_164943.txt");
accel_s = load("hand_vibrations_500ms_100kSmp_2V_amp_66kohm_accelerometer_on_the_load_cell/accel_0.txt");

force = force_s;
ax = repelem(accel_s(1:end, 1), 400);

ay = repelem(accel_s(1:end, 2), 400);
az = repelem(accel_s(1:end, 3), 400);

accel = [ax(1:length(force)) ay(1:length(force)) az(1:length(force))]; %[ax; ay; az];



figure;
subplot(2, 1, 1)
plot(force)
grid on
subplot(2, 1, 2)
plot(accel)
grid on





##for i = 1:length(x)
##
##  % measurement
##  z = [x(i); y(i)]
##
##  % update
##  K = P_n*H'*inv(H*P_n*H' + R)
##  x_n = x_n + K*(z - H*x_n)
##  P_n = (I - K*H)*P_n*(I - K*H)' + K*R*K'
##
##  est_x(i) = x_n(1);
##  est_y(i) = x_n(4);
##
##  % prediction
##  x_n = F*x_n
##  P_n = F*P_n*F' + Q
##
##
##end
