clc
clear all
close all

pkg load control
pkg load signal

%data = dlmread("table_setup/haptix_discovery_test.csv",',',11, 0);
data = dlmread("table_setup/table_setup_matching.csv",',',11, 0);

offset = 0; %20;
ch2 = -3*data(offset+1:end, 3);
ch1 = data(1:end-offset, 2);
t = data(1:end-offset, 1);



alpha = 22e-2;
N = 200;
W = zeros(1, N);
e = zeros(1, N);
err = zeros(length(t), 1);


for n = 1:length(t)-N
  x = [ch2(n:n+N-1)];

  d = ch1(n:n+N-1);

  e = d - W*x;

  W = W + 2*alpha*e*x';
  err(n:n+N-1) = e;

end

figure;
plot(t, ch1)
hold on
plot(t, ch2)
hold on
plot(t, err)
grid on
