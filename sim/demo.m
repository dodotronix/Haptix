clc 
close all
clear all

% constants
m = 50; % kg
g = 10;
fs = 1e4; % Hz
material_coeff = 8e3; % N/s^2 recommended range <2; inf)
peak_max = 4e2; % N

% USER SETTINGS
h = 200; % m
h_tool = 1; % m
soft_switch = 150;

a0 = 10; % m/s^2
a1 = -5; % m/s^2
a2 = -100; % m/s^2

v0 = 0;
v1 = 10;
v2 = 5;

Ts = 1/fs;

% calculate corner values
% all the values have to be multiples 
% of my sampling frequency

h_new = h - mod(h, Ts) 
h_tool_new = h_tool - mod(h_tool, Ts)
soft_switch_new = (soft_switch - mod(soft_switch, Ts))/h_new

t0_tmp = (v1-v0)/a0
t0 = t0_tmp - mod(t0_tmp,Ts)
a0_new = (v1-v0)/t0

t2_tmp = (v2-v1)/a1
t2 = t2_tmp - mod(t2_tmp,Ts)
a1_new = (v2-v1)/t2

t4_tmp = (v0-v2)/a2
t4 = t4_tmp - mod(t4_tmp,Ts)
a2_new = (v0-v2)/t4

if ((t0 <= 0) || (t2 <= 0) || (t4 <= 0)) 
    error('ERROR: The time values are not positive, try increase fs')
end

s0 = (v1+v0)*t0/2 
s2 = (v2+v1)*t2/2
s3 = (v0+v2)*t4/2
margin = h_new-(s0+s2+s3)

if (s3 > h_tool_new)
    error('ERROR: Your tool would get smashed')
end

if (s0+s2+s3) > h
    error('ERROR: The simulation does not have solution: s0+s2+s3 ~= h')
end

dist = soft_switch - s0 - s2

if soft_switch < s0 + s2
    error('ERROR: The soft switch limit is activated too early')
end

t1 = dist/v1
t3 = (h_new-h_tool_new-soft_switch)/v2

h_new_alternative = v1*t1 + v2*t3

t5_tmp = 1; % s
t5 = t5_tmp - mod(t5_tmp,Ts)

s = s0 + s2 + s3 + v1*t1(end) + v2*t3(end) + v2*t4(end)/2 

t00_vec = [0:Ts:t5];
t0_vec = [Ts:Ts:t0];
t1_vec = [Ts:Ts:t1];
t2_vec = [Ts:Ts:t2];
t3_vec = [Ts:Ts:t3];
t4_vec = [Ts:Ts:t4];
t5_vec = [Ts:Ts:t5];

v00_vec = v0*ones(1,length(t00_vec));
v0_vec = a0_new*t0_vec + v00_vec(end);
v1_vec = v0_vec(end)*ones(1,length(t1_vec));
v2_vec = a1_new*t2_vec + v1_vec(end);
v3_vec = v2_vec(end)*ones(1,length(t3_vec));
v4_vec = a2_new*t4_vec + v3_vec(end);
v5_vec = v4_vec(end)*ones(1,length(t5_vec));


v_vec = [v00_vec v0_vec v1_vec v2_vec v3_vec v4_vec v5_vec];
t_vec = [0:length(v_vec)-1]*Ts;

% calculate distance
s_vec = cumtrapz(v_vec)/fs;

% create force vector which is pressing back on the tool
touch_point = find(s_vec >= h_new-h_tool_new);
f_max = peak_max - mod(peak_max, Ts)
x_max = sqrt(f_max/(material_coeff^2))
x = [0:Ts:x_max];
f = (material_coeff*x).^2 + m*-a2_new;

if length(f) > length(touch_point)
    error("ERROR: the material_coeff is too low")
end

% we have to make the length -1 because of the acceleration vector size
contra_force = [zeros(1, length(s_vec) - length(touch_point)) ...
    f zeros(1,length(touch_point) - length(f) -1)];

%-----------------------------------------------------------------------------%

figure()
subplot(2, 1, 1)
plot(t_vec, v_vec, "r-", 'linewidth', 2)
ylabel("velocity [m/s]")
xlabel("time [s]")
grid on

subplot(2, 1, 2)
plot(t_vec, s_vec, "g-", 'linewidth', 2)
ylabel("distance [m]")
xlabel("time [s]")
grid on

% calculate acceleration vector we get from accelerometer sensor (no noise)
a_vec = diff(v_vec)./diff([t_vec]) + g;

% calculate force vector we get from force sensor
f_vec = m*a_vec;

figure()
subplot(2, 1, 1)
plot(t_vec(1:end-1), a_vec, "b-", 'linewidth', 2)
ylabel("acceleration [m/s^2]")
xlabel("time [s]")
grid on

subplot(2, 1, 2)
plot(t_vec(1:end-1), f_vec+contra_force, "b-", 'linewidth', 2)
hold on
plot(t_vec(1:end-1), contra_force+m*g, "g--", 'linewidth', 2)
ylabel("force [N]")
xlabel("time [s]")
grid on

%-----------------------------------------------------------------------------%



