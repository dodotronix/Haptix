clc
clear all
close all

pkg load control
pkg load signal


fs = 50e3;
Ts = 1/fs;

%data = load("table_setup/force_104348.txt");
%data = load("table_setup/force_161238.txt");
%data = load("table_setup/force_173741.txt");
%data = load("table_setup/force_181638.txt");
%data = load("table_setup/force_193649.txt");
data = load("table_setup/force_195732.txt");

force = movmean(data(1:end, 1), 20) - 144;
x = movmean(data(1:end, 2), 20)-125;
y = movmean(data(1:end, 3), 20)-125;
z = movmean(data(1:end, 4), 20)-125;

%touch = 50*[ zeros(length(force)-1e4-1.45e5, 1); -ones(1e4, 1); zeros(1.45e5, 1)];
%force = force + touch;

t = [0:length(force)-1]*Ts;

new_s = force;
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

alpha = 1e-5;
N = 1;
W = zeros(N, 3)
e = zeros(N, 3)
err = zeros(1, length(t));
w = zeros(length(t), 3);


for n = 1:length(t)-N
  xx = [x(n:n+N-1)'; ...
       y(n:n+N-1)'; ...
       z(n:n+N-1)'];

  d = sum(new_s(n:n+N-1)) * ones(N);
  e = d - W*xx;

  W = W + 2*alpha*e*xx';
  err(n:n+N-1) = sum(e);
  w(n:n+N-1, :) = W;

end

##% CUSUM
##h = 4e-2
##S_t_prev = 0
##xt_prev = err(1)
##force_cusum = zeros(1, length(err));
##
##for i = 2:length(force_cusum)
##  tmp = S_t_prev + (err(i) - xt_prev) - h;
##
##  if tmp < 0
##    force_cusum(i) = 0;
##    S_t_prev = 0;
##  else
##    force_cusum(i) = tmp;
##    S_t_prev = tmp;
##  endif
##
##  xt_prev = err(i);
##end


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
plot(new_s)
hold on
plot(err)
##hold on
##plot(force_cusum)
grid on
