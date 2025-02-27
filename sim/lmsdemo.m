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

a1 = 1;
a2 = 1;
a3 = 1;

t = [0:50*fs/f1]*Ts;


s1 = a1*sin(2*pi*f1*t);

s2 = a2*sin(2*pi*f2*t);

s3 = a3*sin(2*pi*f3*t);

DC = 6;
mixed_s = 0.1*s1 + 0.33*s2 + 2*s3 + DC;

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

alpha = 0.9e-3;
N = 2;
W = zeros(3, 1);
e = zeros(N, 1);
err = zeros(1, length(t));


for n = 1:length(t)-N
  x = [s1(n:n+N-1)', ...
       s2(n:n+N-1)', ...
       s3(n:n+N-1)'];

  d = mixed_s(n:n+N-1)';

  e = d - x*W;

  W = W + 2*alpha*x'*e;
  err(n:n+N-1) = e;

end


figure;
plot(err)
grid on

