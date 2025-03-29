clc
clear all
close all

pkg load control
pkg load signal

fs = 40e3;
Ts = 1/fs;

f1 = 1e3;
f2 = 5.1e2;
f3 = 2.4e3;

a1 = 0.33;
a2 = 0.8;
a3 = 0.54;

t = [0:100*fs/f1-1]*Ts;

s1 = sin(2*pi*f1*t);
s2 = sin(2*pi*f2*t);
s3 = sin(2*pi*f3*t);

DC = 6;

pwidth = 4e2;
pdelay = 2e3;
pulse = 2*[zeros(1, pdelay), ones(1, pwidth), zeros(1, length(t) - pwidth - pdelay)];
mixed_s = a1*s1 + a2*s2 + a3*s3 + pulse + DC;

%s1 = [s1(101:end) s1(1:100)];
%s2 = [s2(101:end) s2(1:100)];
%s3 = [s3(101:end) s3(1:100)];

figure;
subplot(2, 1, 1)
plot(t, s1)
hold on
plot(t, s2)
hold on
plot(t, s3)
grid on
subplot(2, 1, 2)
plot(t, mixed_s)
grid on


% LMS algorithm

alpha = 1e-2;
W = zeros(4, 1);
e = 0;
err = zeros(1, length(t));
w = zeros(length(t), 4);


for n = 1:length(t)
  x = [ 1; ...
       s1(n); ...
       s2(n); ...
       s3(n)];

  d = mixed_s(n);

  e = d - W'*x;
  W = W + 2*alpha*x*e;
  err(n) = e;
  w(n, :) = W;
end

figure;
plot(err)
grid on

figure;
plot(w)
grid on

