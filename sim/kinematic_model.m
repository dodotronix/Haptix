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
h_soft = 50; % m - it's a distance where the motor starts to decelerate
h_soft_ratio = 0.1; % percentage where the speed drops to the v_decel

% example inputs
% v = 12e-3 % m/s
% accel = 0 % m/s^2

v0 = 0;
v1 = 10; % m/s
v_decel = 5; % m/s
accel = 2; % m/s^2
t_pressed = 10; % s - number of seconds when the two planes are pressing each other

% deceleration is calculated based on the soft switch limit
t_decel = (2*h_soft_ratio*h_soft)/(v1+v_decel) 
decel = -1*(v1-v_decel)/t_decel

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
t3_vec_a = [0:1/fs:t_decel-1/fs];
v3_vec_a = v1+decel*t3_vec_a; 

t3_vec_b = [0:1/fs:(1-h_soft_ratio)*h_soft/v_decel-1/fs];
v3_vec_b = v_decel*ones(1,length(t3_vec_b));

t3_vec = [t3_vec_a t3_vec_b];
v3_vec = [v3_vec_a v3_vec_b];

% % touch stage the speed is zero
t4_vec = [0:1/fs:t_pressed-1/fs];
v4_vec = zeros(1,length(t4_vec));

% concat all vectors
v_vec = [v1_vec v2_vec v3_vec v4_vec];
t_vec = [0:length(v_vec)-1]/fs;

length(t_vec)
length(v_vec)

plot(t_vec, v_vec)
