clc 
clear all

% physical constants
fg = 500; % N
g = 9.81; % m/s^2

% artificial force coefficients
press_coef = 0.5; % F/t

% TODO define limit force, when the material is gonna break

% hights of the object and the hight of the seling
h = 200; % m
hr = 1; % m
h_soft = 5; % m - it's a distance where the motor starts to decelerate

v0 = 0;
v1 = 10; % m/s

% example inputs
% v = 12e-3 % m/s
% accel = 0 % m/s^2
% decel = 0 % m/s^2

accel = 2; % m/s^2
decel = -200; % m/s^2

% adc sampling
fs = 1000; % Hz

% building chart of the speed in reference to the time
% first stage 
t1 = (v1-v0)/accel;
s1 = 1/2*accel*t1^2+v0*t1;
t1_vec = [0:1/fs:t1-1/fs]; 
v1_vec = accel*t1_vec+v0;

% second stage
s2 = h-s1-h_soft
t2 = s2/v1
t2_vec = [1/fs:1/fs:t2];
v2_vec = v1*ones(1,length(t2_vec));

% decelaration stage - estimation of the distance
% solve quadratic equation
c = [0.5*decel, v1, -h_soft];
root_vec = roots(c)
t3_vec = [1/fs:1/fs:root_vec(root_vec>0)];
v3_vec = v1+decel*t3_vec; 

% % touch stage the speed is zero
% vstop = 0;
% s4 0;
% t4 = 2*(t1+t2+t3);

% concat all vectors
v_vec = [v1_vec v2_vec v3_vec];
t_vec = [0:length(v_vec)-1]/fs;

length(t_vec)
length(v_vec)

plot(t_vec, v_vec)
