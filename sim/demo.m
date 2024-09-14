clc 
close all
clear all

% constants
m = 50; % kg
g = 10; % m/s^2
fs = 100; % Hz
material_coeff = 1e1; % N/s^2 recommended range <2; inf)

% USER SETTINGS
h = 400; % mm
h_tool = 40; % mm
soft_switch = 200; % mm

a0 = 10; % mm/s^2
a1 = -5; % mm/s^2
a2 = -100; % mm/s^2

v0 = 0;
v1 = 12 % mm/s;
v2 = 6 % mm/s;

Ts = 1/fs;

% calculate corner values
% all the values have to be multiples 
% of my sampling frequency

t00_tmp = 1; % s
t00 = t00_tmp - mod(t00_tmp,Ts)

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
s4 = (v0+v2)*t4/2

margin = h-(s0+s2+s4)

if (s0+s2+s4) > h
    error('ERROR: The simulation does not have solution: s0+s2+s4 ~= h')
end

t1_tmp = (soft_switch - s0 - s2)/v1;
t1 = t1_tmp - mod(t1_tmp,Ts)

dist_new = v1*t1
soft_switch_new = dist_new + s0 + s2

if soft_switch_new < s0 + s2
    error('ERROR: The soft switch limit is activated too early')
end

t3 = (h-h_tool-soft_switch_new)/v2;
t3 = t3 - mod(t3,Ts)

h_tool_new = h - soft_switch_new - v2*t3

if (s4 > h_tool_new)
    error('ERROR: Your tool would get smashed')
end

s = s0 + s2 + s4 + v1*t1 + v2*t3 + v2*t4/2 

t0_vec = [Ts:Ts:t0];
t2_vec = [Ts:Ts:t2];
t4_vec = [Ts:Ts:t4];

v00_vec = v0*ones(1,length([0:Ts:t0]));
v0_vec = a0_new*t0_vec + v00_vec(end);
v1_vec = v1*ones(1,length([Ts:Ts:t1]));
v2_vec = a1_new*t2_vec + v1_vec(end);
v3_vec = v2_vec(end)*ones(1,length(Ts:Ts:t3));
v4_vec = a2_new*t4_vec + v3_vec(end);
v5_vec = v4_vec(end)*ones(1, length(Ts:Ts:t0));

v_vec = [v00_vec v0_vec v1_vec v2_vec v3_vec v4_vec v5_vec];
t_vec = [0:length(v_vec)-1]*Ts;

% calculate distance
s_vec = cumtrapz(v_vec)*Ts;

% create force vector which is pressing back on the tool
touch_point_inx = find(s_vec >= (s0 + v1*t1 + s2 + v2*t3))
s_vec(touch_point_inx)(1)

% here just for debugging purposes
test_v = v_vec(touch_point_inx(1))
test_t = t_vec(touch_point_inx(1))

f = (material_coeff*t4_vec).^2 + m*-a2_new*1e-3;

if length(f) > (length(s_vec) - length(touch_point_inx))
    error("ERROR: the material_coeff is too low")
end

contra_force = [zeros(1, touch_point_inx(1) - 1) f ...
    zeros(1, length(s_vec) - touch_point_inx(1) - length(f) + 1)];

length(v_vec)
length(s_vec)
length(t_vec)
length(contra_force)

%-----------------------------------------------------------------------------%

figure()
subplot(2, 1, 1)
plot(t_vec, v_vec, "b-o", 'linewidth', 2)
hold on
plot(test_t, test_v, "kx", 'markersize', 20)
ylabel("velocity [mm/s]")
xlabel("time [s]")
grid on


subplot(2, 1, 2)
plot(t_vec, s_vec, "g-o", 'linewidth', 2)
ylabel("distance [mm]")
xlabel("time [s]")
grid on

% calculate acceleration vector we get from accelerometer sensor (no noise)
a_vec = diff(v_vec)./diff([t_vec])*1e-3 + g;

% calculate force vector we get from force sensor
f_vec = m*a_vec;

figure()
subplot(2, 1, 1)
plot(t_vec(1:end-1), a_vec, "b-", 'linewidth', 2)
ylabel("acceleration [mm/s^2]")
xlabel("time [s]")
grid on

subplot(2, 1, 2)
plot(t_vec(1:end-1), f_vec, "k--", 'linewidth', 2)
hold on
plot(t_vec(1:end-1), contra_force(1:end-1)+m*g, "g-", 'linewidth', 2)
hold on
plot(t_vec(1:end-1), f_vec + contra_force(1:end-1), "r-o", 'linewidth', 2)
ylabel("force [N]")
xlabel("time [s]")
grid on
