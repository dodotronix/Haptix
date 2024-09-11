clc 
clear all

% physical constants
fg = 500; % N
g = 9.81; % m/s^2

% artificial force coefficients
press_coef = 0.5; % F/t

% hights of the object and the hight of the seling
h = 200; % m
h_tool = 1; % m
h_soft = 20; % m - it's a distance where the motor starts to decelerate
h_soft_ratio = 0.1; % percentage where the speed drops to the v_decel

% example inputs
% v = 12e-3 % m/s
% accel = 0 % m/s^2

v0 = 0;
v1 = 10; % m/s
v_decel = 4; % m/s
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
t1_vec = [0:1/fs:t1]; 
s1_vec = 0.5*accel*t1_vec.^2+v0*t1_vec; 
v1_vec = accel*t1_vec+v0;

% second stage
s2 = h-s1_vec(end)-h_soft
t2 = s2/v1
t2_vec = [0:1/fs:t2-1/fs];
s2_vec = v1*t2_vec + s1_vec(end);
v2_vec = v1*ones(1,length(t2_vec));

% decelaration stage - estimation of the distance
t3_vec_a = [0:1/fs:t_decel-1/fs];
v3_vec_a = v1+decel*t3_vec_a; 
s3_vec_a = 0.5*decel*t3_vec_a.^2+v1*t3_vec_a + s2_vec(end);

t3_vec_b = [0:1/fs:(1-h_soft_ratio)*h_soft/v_decel-1/fs];
v3_vec_b = v_decel*ones(1,length(t3_vec_b));
s3_vec_b = s3_vec_a(end) + v_decel*t3_vec_b;

t3_vec = [t3_vec_a t3_vec_b];
v3_vec = [v3_vec_a v3_vec_b];

% % touch stage the speed is zero
t4_vec = [0:1/fs:t_pressed-1/fs];
v4_vec = zeros(1,length(t4_vec));
s4_vec = s3_vec_b(end)*ones(1,length(t4_vec));

% concat all vectors
v_vec = [v1_vec v2_vec v3_vec v4_vec];
t_vec = [0:length(v_vec)-1]/fs;
s_vec = [s1_vec s2_vec s3_vec_a s3_vec_b s4_vec];

% create step vector simulating when the tool hits the grinding wheel
s_vec_cut = s_vec(s_vec<=(h-h_tool));
length(s_vec_cut)
step_vec = [ones(1,length(s_vec_cut)) zeros(1,length(s_vec) - length(s_vec_cut))];

length(t_vec)
length(v_vec)
length(s_vec)

figure(1)
plot(v_vec.*step_vec)
% hold on
% plot(step_vec)

figure(2)
plot(s_vec)

