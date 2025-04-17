clc
clear all
close all

pkg load control
pkg load signal

%data = dlmread("table_setup/haptix_discovery_test.csv",',',11, 0);
#data = dlmread("table_setup/table_setup_matching.csv",',',11, 0);
data = dlmread("table_setup/channels_simple_vibration.csv",',',1, 0);

offset = 0; %20;
#ch2 = -3*data(offset+1:end, 3);
#ch1 = data(1:end-offset, 2);
#t = data(1:end-offset, 1);


Ts = 150e-6;
ch1 = data(1:end-offset, 1);
ch2 = data(offset+1:end, 2);
ch3 = data(offset+1:end, 3);
t = [0:length(ch1)-1]*Ts;

# calculate offset and subtract it
offset_ch1 = mean(ch1(1:100))
offset_ch2 = mean(ch2(1:100))
offset_ch3 = mean(ch3(1:100))
ch1 = ch1 - offset_ch1;
ch2 = ch2 - offset_ch2;
ch3 = ch3 - offset_ch3;

#normalize
ch1 = ch1/max(ch1);
ch2 = ch2/max(ch2);
ch3 = ch3/max(ch3);

alpha = 2e-2;
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
subplot(2, 1, 1)
plot(t, ch1)
hold on
plot(t, ch2)
hold on
plot(t, ch3)
grid on
#hold on
subplot(2, 1, 2)
plot(t, err)
grid on
