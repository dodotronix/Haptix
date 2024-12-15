clc
clear all
close all

% motor freq 101.33 Hz

pkg load signal

function [signals,avgFilter,stdFilter] = ThresholdingAlgo(y,lag,threshold,influence)


% Initialise signal results
signals = zeros(length(y),1);
% Initialise filtered series
filteredY = y(1:lag+1);
% Initialise filters
avgFilter(lag+1,1) = mean(y(1:lag+1));
stdFilter(lag+1,1) = std(y(1:lag+1));
% Loop over all datapoints y(lag+2),...,y(t)
for i=lag+2:length(y)
    % If new value is a specified number of deviations away
    if abs(y(i)-avgFilter(i-1)) > threshold*stdFilter(i-1)
        if y(i) > avgFilter(i-1)
            % Positive signal
            signals(i) = 1;
        else
            % Negative signal
            signals(i) = -1;
        end
        % Make influence lower
        filteredY(i) = influence*y(i)+(1-influence)*filteredY(i-1);
    else
        % No signal
        signals(i) = 0;
        filteredY(i) = y(i);
    end
    % Adjust the filters
    avgFilter(i) = mean(filteredY(i-lag:i));
    stdFilter(i) = std(filteredY(i-lag:i));
end
% Done, now return results
end







accel_s = load("hand_vibrations_500ms_100kSmp_2V_amp_21kohm/accel_0.txt");
%accel_s = load("hand_vibrations_500ms_100kSmp_2V_amp_21kohm/accel_1.txt");

force_s = load("hand_vibrations_500ms_100kSmp_2V_amp_21kohm/force_160311.txt");
%force_s = load("hand_vibrations_500ms_100kSmp_2V_amp_21kohm/force_160529.txt");

fs = 250;

force_usmp = reshape(force_s, 400, []);
force_aligned = [force_usmp, zeros(400, 548)];
force_aligned_sum = sum(force_aligned)/400;


accel = accel_s(1:1500, 3);
force = force_aligned_sum(1:end-548);

[b, a] = butter(2, [2*2/fs, 100*2/fs]);
force_fil = filter(b, a, force);
accel_fil = filter(b, a, accel);


data = [force_fil(1e2-84:end-84)', accel_fil(1e2:end)];
data_mean = mean(data);
data_centered = data - data_mean;

cov_matrix = cov(data_centered);

[V, D] = eig(cov_matrix);

[eigenvalues, idx] = sort(diag(D), 'descend');
V = V(:, idx);

pca_components = data_centered*V;

event_component = pca_components(:, 1);
interference_component = pca_components(:, 2);

figure;
subplot(4, 1, 1);
plot(data(:, 1));
title('Original Load Cell Signal');
grid on
subplot(4, 1, 2);
plot(event_component);
title('Event Component (First Principal Component)');
grid on
subplot(4, 1, 3);
plot(interference_component);
title('Interference Component (Second Principal Component)');
grid on
subplot(4, 1, 4);
plot(data(:,1) - interference_component);
title('Interference Component (Second Principal Component)');
grid on


figure;
plot(data(:, 1), data(:,2), '.');
grid on

figure;
plot(data(:, 1))
hold on
plot(data(:, 2), '-x')
grid on


xc = xcorr(data(:,1), data(:,2), 'biased');

figure;
plot(xc)
grid on

fs1 = 2e3;
test = resample(accel, 8, 1)-103;
test_force = force_s(1:100e3/fs1:end)-10;

[b, a] = butter(2, [2*2/fs1, 250*2/fs1]);
test_fil = filter(b, a, test);
test_force_fil = filter(b, a, test_force-10);


figure;
%plot([0:length(accel)-1]/fs, accel)
%hold on
plot([0:length(test_fil)-1]/fs1, test_fil)
hold on
plot([0:length(test_force_fil)-1]/fs1, test_force_fil)
grid on



