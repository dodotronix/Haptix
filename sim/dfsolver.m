clear all


pkg load symbolic

syms t k m c

A = sym([sym(0), sym(1); -k/m, c/m]);

exp_At = expm(A * t);
%result = int(exp_At, t, 0, delta_t);

k_val = 2e-3; m_val = 50; c_val = 100; t_val = 1/100e3;
result_numeric = subs(exp_At, [k, m, c, t], [k_val, m_val, c_val, t_val]);
result_array = double(result_numeric);

disp(result_array);
