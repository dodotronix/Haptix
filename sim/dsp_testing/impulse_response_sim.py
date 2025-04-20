import numpy as np
import matplotlib.pyplot as plt

data = np.loadtxt("../../meas/table_setup/channels_simple_vibration_fzx.csv", delimiter=',', skiprows=1)
Ts = 150e-6

force = data[:,0]
accel_z = data[:,1]
accel_x = data[:,2]

# calculate offset and subtract it
offset_force = np.mean(force[1:100])
offset_accel_z = np.mean(accel_z[1:100])
offset_accel_x = np.mean(accel_x[1:100])

force = force - offset_force
accel_z = accel_z - offset_accel_z
accel_x = accel_x - offset_accel_x

#normalize
force = force/np.max(force)
accel_x = accel_x/np.max(accel_z)
accel_z = accel_z/np.max(accel_z)

t = np.linspace(0, len(force)*Ts, len(force))

plt.plot(t, force)
plt.plot(t, accel_z)
plt.plot(t, accel_x)
plt.grid(True)
plt.show()