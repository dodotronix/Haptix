clc
clear all
close all

pkg load control
pkg load signal

force_s = load("hand_vibrations_500ms_100kSmp_2V_amp_66kohm_accelerometer_on_the_load_cell/force_164943.txt");
accel_s = load("hand_vibrations_500ms_100kSmp_2V_amp_66kohm_accelerometer_on_the_load_cell/accel_0.txt");


fs = 100e3;
mu = mean(force_s)
mu_z = mean(accel_s(1:end, 3));

force_imp = force_s(4.332e5:4.332e5+27e3) - mu;
accel_imp = accel_s(1:end, 3)-mu_z;
accel_imp_usmp = upsample([zeros(15, 1); accel_imp], 400);


pwidth = 300;
pshift = 0;
sim_input_s = [zeros(pshift, 1); ...
               ones(pwidth, 1);...
              zeros(length(force_imp)-pwidth-pshift, 1)];


[b, a] = butter(2, 5e2*2/fs);
input_s = filter(b, a, sim_input_s);
%input_s = force_imp / max(force_imp);

[b, a] = butter(2, 5e3*2/fs);
force_imp_filtered = filter(b, a, force_imp);
output_s = force_imp_filtered / max(force_imp_filtered);


X = fft(input_s);
Y = fft(output_s);
H = Y./X;

h = real(ifft(H));


% resampling
hfir = fir1(5000, 125*2/fs);


test = filter(hfir, 1, accel_imp_usmp);
%test = test(4.332e5:4.332e5+27e3);
test = test / max(test);
test = test(4.35e5:4.5e5);


test1 = filter(hfir, 1, force_s-mu);
test1 = test1 / max(test1);
test1 = test1(4.35e5:4.5e5);


sim_in_test = [zeros(pshift, 1); ...
               ones(pwidth, 1);...
               zeros(length(test1)-pwidth-pshift, 1)];
sim_in_test = filter(hfir, 1, sim_in_test);
sim_in_test = [sim_in_test(1001:end); zeros(1000, 1)];

TEST_Y = fft(test);
TEST_X = fft(sim_in_test);

TEST_H = TEST_Y./TEST_X;

test_h = real(ifft(TEST_H));

%test = accel_imp_usmp;

figure;
subplot(2, 1, 1)
plot(accel_imp)
grid on
subplot(2, 1, 2)
plot(test)
hold on
plot(test1)
hold on
plot(sim_in_test)
grid on

figure;
plot(abs(TEST_H))
grid on

figure;
plot(test_h)
grid on


##figure;
##plot(input_s)
##hold on
##plot(output_s)
##grid on
##
##figure;
##plot(abs(H))
##grid on
##
##figure;
##plot(h)
##grid on
##
##
##test = filter(b, a, force_s);
##test_conv = conv(test, h);
##
##figure;
##plot(test_conv)
##grid on

