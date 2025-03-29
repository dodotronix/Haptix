clc
clear all
close all

pkg load control
pkg load signal


fs = 50e3;
Ts = 1/fs;

%data = load("table_setup/force_104348.txt");
data = load("table_setup/force_161238.txt");
%data = load("table_setup/force_173741.txt");
%data = load("table_setup/force_181638.txt");
%data = load("table_setup/force_193649.txt");
%data = load("table_setup/force_195732.txt");
test = load("touching_10ksmp_2V_5s_61kohm/force_152849.txt");


force = movmean(data(1:end, 1), 20);
x = movmean(data(1:end, 2), 20) - 126;
y = movmean(data(1:end, 3), 20) - 126;
z = movmean(data(1:end, 4), 20) - 126;



%touch = 50*[ zeros(length(force)-1e4-1.45e5, 1); -ones(1e4, 1); zeros(1.45e5, 1)];
%force = force + touch;

t = [0:length(force)-1]*Ts;

##% slewrate filter
##reading = 0;
##new_s = zeros(1, length(t));
##
##for i = 1:length(t)
##  if(reading == 0)
##    reading = force(i);
##  elseif (force(i) > reading)
##    reading = reading + 1;
##  else
##    reading = reading -1;
##  endif
##
##  new_s(i) = reading;
##end


% LMS algorithm

alpha = 5.4e-5;
W = zeros(4, 1);
e = 0;
err = zeros(1, length(t));
w = zeros(length(t), 4);

for n = 1:length(t)
  xx = [ 1; ...
       x(n); ...
       y(n); ...
       z(n)];

  d = force(n);

  e = d - W'*xx;
  W = W + 2*alpha*xx*e;
  err(n) = e;
  w(n, :) = W;
end


new_s = w(:, 1);

% CUSUM
h = 1e-4
S_t_prev = 0
xt_prev = new_s(1)
force_cusum = zeros(1, length(err));

for i = 2:length(force_cusum)
  tmp = S_t_prev + (xt_prev - new_s(i)) - h;

  if tmp < 0
    force_cusum(i) = 0;
    S_t_prev = 0;
  else
    force_cusum(i) = tmp;
    S_t_prev = tmp;
  endif

  xt_prev = new_s(i);
end


figure;
plot(t, force)
hold on
plot(t, x)
hold on
plot(t, y)
hold on
plot(t, z)
grid on

figure;
plot(t, err)
grid on

figure;
subplot(2, 1, 1)
plot(t, w)
grid on
subplot(2, 1, 2)
plot(t, w(:, 1))
hold on
plot(t, 10*force_cusum)
grid on


alpha = 6e-3;
W = zeros(4, 1);
e = 0;
err = zeros(1, length(test));
w = zeros(length(test), 4);

for n = 1:length(test)
  xx = [ 1; ...
       0; ...
       0; ...
       0];

  d = test(n);

  e = d - W'*xx;
  W = W + 2*alpha*xx*e;
  err(n) = e;
  w(n, :) = W;
end



figure;
plot(test)
grid on

figure;
plot(err)
grid on

figure;
subplot(2, 1, 1)
plot(w)
grid on
subplot(2, 1, 2)
plot(w(:, 1))
grid on
