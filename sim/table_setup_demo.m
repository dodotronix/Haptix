clc
clear all
close all

pkg load control
pkg load signal


data = load("table_setup/data.csv");
t = data(1:end, 1);

data_accel = data(1:end, 2);
data_accel = data_accel/max(abs(data_accel)) + 0.889;

data_force = data(1:end, 3);
data_force = data_force/max(abs(data_force)) + 0.1;


%accel_py = load("shaking_0_21kohm/accel_0.txt");
%force_py = load("shaking_0_21kohm/force_163343.txt");

force_py = load("hand_vibrations_500ms_100kSmp_2V_amp_66kohm_accelerometer_on_the_load_cell/force_164943.txt");
accel_py = load("hand_vibrations_500ms_100kSmp_2V_amp_66kohm_accelerometer_on_the_load_cell/accel_0.txt");
accel_py = accel_py(1:length(force_py)/400, 1:end);

t_accel = [0:length(accel_py)-1]/250;
t_force = [0:length(force_py)-1]/100e3;

% test interpolation
accel_resampled = interp1(t_accel, accel_py, t_force, 'linear');

% Ensure all reference signals are column vectors
accel_X = accel_resampled(:, 1) + 0.1;
accel_Y = accel_resampled(:, 2) - 0.3;
accel_Z = accel_resampled(:, 3) - 10.6;


figure;
plot(t_force, accel_X)
hold on
plot(t_force, accel_Y)
hold on
plot(t_force, accel_Z)
hold on
plot(t_force, force_py)
grid on

alpha = 0.1e-4;
N = 2;
W = zeros(3, 1);
e = zeros(N, 1);
err = zeros(1, length(accel_X));


for n = 1:length(accel_X)-N
  x = [accel_X(n:n+N-1), ...
       accel_Y(n:n+N-1), ...
       accel_Z(n:n+N-1)];

  d = force_py(n:n+N-1);

  e = d - x*W;

  W = W + 2*alpha*x'*e;
  err(n:n+N-1) = e;
end

figure;
plot(force_py)
hold on
plot(err)
grid on


# filter both signals
%[b, a] = butter(4, 5e2*2/4e3, 'low');

%data_accel = filter(b, a, data_accel);
%data_force = filter(b, a, data_force);

%order_n = 135;


##mu = 0.6;
##y = [];
##e = [];
##w = zeros(1, order_n);
##epsilon = 1e-6;
##lambda = 0.9;
##
##
##accel_in = [zeros(1, order_n-1), data_accel'];
##force_in = [zeros(1, order_n-1), data_force'];
##P_x = 0;
##
##for i=1:length(data_force)
##  x = accel_in(i:i+order_n-1);
##  P_x = lambda * P_x + (1 - lambda) * (norm(x)^2);
##
##  y(i) = sum(w.*x);
##
##  e(i) = force_in(i) - y(i);
##
##  w = w + mu * e(i) * x / (P_x + epsilon);
##end

##n_samples = length(data_force)
##lambda = 0.95;
##delta = 100;
##
##
##w = zeros(order_n, 1);          % Filter weights
##P = eye(order_n) * delta;       % Initial inverse correlation matrix
##y = zeros(1, n_samples);        % Filter output
##e = zeros(1, n_samples);        % Error signal
##
##% RLS Algorithm
##for n = order_n:n_samples
##    x_n = flip(data_accel(n-order_n+1:n));
##
##    Pi_x = P*x_n;
##    k = Pi_x / (lambda + x_n' * Pi_x);
##
##    y(n) = w' * x_n;
##    e(n) = data_force(n) - y(n);
##
##
##    P = (P - k * x_n' * P) / lambda;
##    w = w + k * e(n);
##end
##
##figure;
##plot(t, data_force)
##hold on
##plot(t, data_accel)
##hold on
##plot(t, e + 0.5)
##grid on



##F = [ 1,   t(2)-t(1); 0,  1]
##
##G = 0;
##
##Q = [1e-4, 0; 0, 1e-4]
##
##H = [1, 0]
##
##R = [1]
##
##I = eye(2)
##
##
##% initialization
##u_n = [0; 0]; % acceleration vector
##x_00 = [0; 0];
##P_00 = diag([0, 0]);
##
##x_n = F*x_00 + G*u_n;
##P_n = F*P_00*F' + Q;
##
##
##% output variables
##est_f = zeros(1, length(data_force));
##
##for i = 1:length(data_force)
##
##  % measurement
##  z = [data_force(i)];
##  ref = data_accel(i);
##
##  % update
##  K = P_n*H'*inv(H*P_n*H' + R);
##  x_n = x_n + K*(z - H*x_n);
##  P_n = (I - K*H)*P_n*(I - K*H)' + K*R*K';
##
##  est_f(i) = x_n(1);
##
##  % prediction
##  x_n = F*x_n + G*u_n;
##  P_n = F*P_n*F' + Q;
##
##end
##
##figure;
##plot(t, data_force)
##hold on
##plot(t(1:end-3), 5.05*data_accel(4:end))
##hold on
##plot(t, data_force - 5.05*data_accel)
##grid on
##
##
##figure;
##plot(data_force)
##hold on
##plot(est_f)
##grid on


