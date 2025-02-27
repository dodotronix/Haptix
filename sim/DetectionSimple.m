clc
clear all
close all

pkg load control
pkg load signal

f = 10;
dc_offset = 111; % offset of the measured force
vibmag = 5;
viblen = 10

fs = 1e4; % 10kHz
Ts = 1/fs;

t = [0:Ts:viblen/f-Ts];

s1 = sin(2*pi*f*t);

s2 = (vibmag*(t(end)-t)./t(end)).^2;

vibes = s1.*s2;

force_s = load("touching_10ksmp_2V_5s_61kohm/force_152849.txt");

% create artifitial force signal!!!
dc_len = 1e4; % length of the plateau
arts0 = force_s(1:2.8526e5);

step_size = 1;
tmp = ones(dc_len,1)*58 + randn(dc_len, 1)*1.5;
arts1 = round(tmp/step_size)*step_size;
arts2 = [force_s(2.8526e5+1:2.8526e5+1e3); force_s(2.8526e5+1e3+dc_len+1:end)];
force_sim = [arts0; arts1; arts2];


vibes_vect = [zeros(1, 2e5) vibes zeros(1, 7e4) vibes zeros(1, 1e5) vibes];
vibes_vect_aligned = [vibes_vect zeros(1,length(force_s)-length(vibes_vect))];
noise = randn(1, length(vibes_vect_aligned))*0.8;

vibes_vect_aligned_noise = vibes_vect_aligned + noise;


accel = vibes_vect_aligned_noise./vibmag^2 + 9.4;

%%% combine the vibration signal with force
%meas_data = force_s + vibes_vect_aligned_noise' - dc_offset;
meas_data = force_sim + vibes_vect_aligned_noise' - dc_offset;

t_data = [0:length(meas_data)-1]*Ts;


figure;
subplot(3, 1, 1)
plot(t, s1)
grid on
subplot(3, 1, 2)
plot(t, s2)
grid on
subplot(3, 1, 3)
plot(t, vibes)
grid on

figure;
subplot(3, 1, 1)
plot(t_data, force_s)
grid on
subplot(3, 1, 2)
plot(t_data, vibes_vect_aligned_noise)
grid on
subplot(3, 1, 3)
plot(t_data, meas_data)
grid on


figure;
subplot(2, 1, 1)
plot(t_data, accel)
grid on
subplot(2, 1, 2)
plot(t_data, meas_data)
grid on


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Processing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

win = 100
%accel_mean = movmean(accel, win);
%accel_med = movmedian(accel, win);

%force_mean = movmean(meas_data, win);
%force_med = movmedian(meas_data, win);

%accel_deviation = movstd(accel, win);
%force_deviation = movstd(meas_data, win);

##reading = 0;
##test = force_mean;
##new_s = [];
##
##
##for i = 1:length(test)
##  if(reading == 0)
##    reading = test(i);
##  elseif (test(i) > reading)
##    reading = reading + 1;
##  else
##    reading = reading -1;
##  endif
##
##  new_s(i) = reading;
##end
##
##
##new_s_abs = abs(new_s);
##envelope_s = [];
##prev_envelope = 0;
##alpha = 0.01;
##
##for i = 1:length(new_s_abs)
##  envelope_s(i) = alpha*new_s_abs(i) + (1 - alpha)*prev_envelope;
##  prev_envelope = envelope_s(i);
##end

##figure;
##subplot(4, 1, 1)
##plot(t_data, accel_mean)
##grid on
##subplot(4, 1, 2)
##plot(t_data, accel_deviation)
##grid on
##subplot(4, 1, 3)
##plot(t_data, force_mean)
##grid on
##subplot(4, 1, 4)
##plot(t_data, force_deviation)
##grid on
##
##figure;
##subplot(2, 1, 1)
##plot(t_data, new_s)
##grid on
##subplot(2, 1, 2)
##plot(t_data, new_s_abs)
##grid on


##hoho = force_mean;
##%hoho = [0, -94, -95, -98, -95, -91, -40];
##
##h = 4e-3;
##S_t_prev = 0;
##xt_prev = hoho(1);
##force_cumsum = zeros(1, length(hoho));
##
##
##for i = 2:length(hoho)
##  lala = hoho(i) - 25*(accel_mean(i) - 9.4);
##  tmp = S_t_prev + (lala - xt_prev) - h;
##
##  if tmp < 0
##    force_cumsum(i) = 0;
##    S_t_prev = 0;
##  else
##    force_cumsum(i) = tmp;
##    S_t_prev = tmp;
##  endif
##
##  xt_prev = lala;
##end
##
##figure;
##plot(hoho)
##hold on
##plot(hoho' - 25*(accel_mean - 9.4))
##hold on
##plot(5*force_cumsum - 80)
##grid on

% TODO try EWAVG (exponential weighting avg)



% TODO Kalman filter (try subtracting the reference signal)

F = [ 1,   Ts; 0,  1]

G = 0;

Q = [1e-3, 0; 0, 1e-3]

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
est_f = zeros(1, length(meas_data));
est_a = zeros(1, length(meas_data));

for i = 1:length(meas_data)

  % measurement
  z = [meas_data(i)];
  ref = 25*(accel(i) - 9.4);

  % update
  K = P_n*H'*inv(H*P_n*H' + R);
  x_n = x_n + K*(z - H*x_n - ref);
  P_n = (I - K*H)*P_n*(I - K*H)' + K*R*K';

  est_f(i) = x_n(1);

  % prediction
  x_n = F*x_n + G*u_n;
  P_n = F*P_n*F' + Q;

end

figure;
plot(meas_data)
hold on
plot(est_f)
grid on


