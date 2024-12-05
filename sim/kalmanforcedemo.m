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


sigma_a = 0.1; %m*s^2
fs = 100e3;
dt = 1/fs;


F = [ 1,   dt; 0,  1]
%F = [1, dt; 0, 1]

G = 0;

Q = [1e-3, 0;
0, 1e-3]

H = [1, 0]

R = [1]

I = eye(2)


% initialization
u_n = [0; 0]; % acceleration vector
x_00 = [0; 0];
P_00 = diag([0, 0]);

x_n = F*x_00 + G*u_n;
P_n = F*P_00*F' + Q;


% output variables
est_f = zeros(1, length(force));
est_a = zeros(1, length(force));


for i = 1:length(force)

  % measurement
  z = [force(i)];

  % update
  K = P_n*H'*inv(H*P_n*H' + R);
  x_n = x_n + K*(z - H*x_n);
  P_n = (I - K*H)*P_n*(I - K*H)' + K*R*K';

  est_f(i) = x_n(1);
  est_a(i) = x_n(2);

  % prediction
  x_n = F*x_n + G*u_n;
  P_n = F*P_n*F' + Q;


end

figure;
subplot(3, 1, 1)
plot(force)
hold on
plot(est_f)
grid on

subplot(3, 1, 2)
plot(est_a)
grid on

subplot(3, 1, 3)
plot(accel)
grid on
