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

sigma_a = 0.1; %m*s^2

F = []

G = []

Q = []

H = []

R = []

I = eye(2)


% initialization
u_n = [0; 0; 0] % acceleration vector
x_00 = [0; 0; 0]
P_00 = diag([0, 0, 0])

x_n = F*x_00 + G*u_n
P_n = F*P_00*F' + Q


% output variables
est_f = zeros(1, length(x));


##for i = 1:length(x)
##
##  % measurement
##  z = [force(i); accel(i, 1); accel(i, 2), accel(i, 3)]
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
##  x_n = F*x_n + G*u_n
##  P_n = F*P_n*F' + Q
##
##
##end
