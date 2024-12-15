clc
clear all
close all

% motor freq 101.33 Hz

pkg load signal

fs = 250;

full_run1 = load("touching_10ksmp_2V_5s_61kohm/force_152252.txt");
full_run1 = full_run1(6043e1:end); % aligning the chart with the next chart

full_run_usmp = reshape(full_run1(1:end-11), 40, []);
full_run_aligned = [full_run_usmp, zeros(40, 2895)];
full_run_aligned_sum = sum(full_run_aligned)/40;

YY = fft(full_run_aligned_sum);
fxx =[0:length(YY)-1]*fs/length(YY);


figure()
plot(fxx, abs(YY).^2);
xlim([0 fs/2])
ylim([0 1e6])
grid on

t = [0:length(full_run_aligned_sum(1:end-2895))-1]/fs;


%[b, a] = butter(2, [10*2/fs, 20*2/fs]);
[b, a] = butter(2, 5*2/fs, 'high');
ynew = filter(b, a, full_run_aligned_sum);

figure()
plot(t, full_run_aligned_sum(1:length(t)));
hold on
plot(t, ynew(1:length(t)))
grid on


test = filter(b, a, full_run_usmp(1, 1:end));
test_processed = movvar(test, 1e1);

figure()
plot(test)
hold on
plot(test_processed)
grid on
