clc
clear all
close all

% motor freq 101.33 Hz

pkg load signal

fs = 250;

full_run1 = load("touching_10ksmp_2V_5s_61kohm/force_152252.txt");
full_run1 = full_run1(6043e1:end); % aligning the chart with the next chart
full_run2 = load("touching_25ksmp_2V_2s_61kohm/force_151836.txt");


force_raw = load("first_test/extra/samp_bouchani");
force_raz = load("first_test/raz_2.5mm/samp_1_2.5mm");
force_raz1 = load("first_test/raz_4mm/samp_1_4mm");


length(force_raw) % 78350
%force = force_raw(32e3:32e3+32e3-1)-25e3;
force = force_raz1(16e3:32e3+16e3-1)-25e3;
%force = force_raz(16e3:32e3+16e3-1)-25e3;


force_usmp = reshape(force, 4, []);
force_aligned = [force_usmp, zeros(4, 192)];
force_aligned_sum = sum(force_aligned)/4;


full_run_usmp = reshape(full_run1(1:end-11), 40, []);
full_run_aligned = [full_run_usmp, zeros(40, 2895)];
full_run_aligned_sum = sum(full_run_aligned)/40;

Y = fft(force_aligned_sum);
YY = fft(full_run_aligned_sum);

fx =[0:length(Y)-1]*fs/length(Y);
fxx =[0:length(YY)-1]*fs/length(YY);

figure()
plot(fx, abs(Y).^2);
%hold on
%plot(fxx, 10e2*abs(YY).^2)
xlim([0 fs/2])
ylim([0 1e9])
grid on


[b, a] = butter(2, [10*2/fs, 20*2/fs]);
%ynew = filter(b, a, force_aligned_sum(1:end-192));
ynew = filter(b, a, full_run_aligned_sum(1:end-2895));

%ynew_integrated = cumtrapz(ynew())/6e3;

t = [0:length(ynew)-1]/fs;
tt = [0:length(full_run1)-1]/10e3;
ttt = [0:length(full_run2)-1]/25e3;


figure()
plot(tt, full_run1)
hold on
plot(ttt, full_run2)
grid on

figure()
%plot(t, force_aligned_sum(1:length(t)))
%hold on
plot(t, ynew)
grid on


