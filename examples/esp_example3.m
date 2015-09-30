% Copyright (c) 2012, Freescale Semiconductor

path(path, '../tool');
close all;
clc;
outputDir = 'esp_example3_outputs';

% constant definitions
sample_rate = 100;               % sensor sample rate
ts = 1/sample_rate;

% Define the environment
env = Env(Env.ENU);

r = 2*pi()/20;
d=9;

% Adata for this test is angular velocity
%        X     Y      Z
Adata = [0.0,  0.0,   0.0;
    0.0,  0.0,   0.0;
    r  ,  0.0,   0.0;
    r  ,  0.0,   0.0;
    0.0,  0.0,   0.0;
    0.0,  0.0,   0.0];
Atime = [0; 1; 2; d-2; d-1; d];

% Pdata is position data
% time   X     Y      Z
data = [0,    0.0,   0.0,  0.0;
    1,    0.0,   0.0,  0.0;
    2,    1.0,   0.0,  0.2;
    3,    1.0,   1.0,  0.4;
    4,    0.0,   1.0,  0.6;
    5,    0.0,   0.0,  0.8;
    6,    1.0,   0.0,  1.0;
    7,    1.0,   1.0,  1.2;
    8,    0.0,   1.0,  1.4;
    9,    0.0,   0.0,  1.6];

% Compute parameters for a low pass filter
% Cutoff frequency=1Hz
% frequency = 200Hz, 200 taps
% This filter takes several seconds to run, but does a nice job of
% ensuring that our waveforms look reasonable.
% Note that it DOES introduce phase delay (which we don't care about)
[ N, D ] = LPF( 1, 200, 200 );

t = CompositeTrajectory('Traj1');
t = t.set_av('linear', Atime, Adata);
t = t.set_position('spline', data(:,1), data(:,2:4) );
t = t.compute(0.01, 0.005, N, D);

t.plot_orientation_and_position([1;1;1], outputDir)

esp = ExampleSensorPod(env, t, ts);
esp = esp.initialize_models();
esp.plot_all();
time = esp.get_time();

for i=1:esp.num_points()
    acc(i,:) = esp.get_acc_sample(i);
    mag(i,:) = esp.get_mag_sample(i);
    gyro(i,:) = esp.get_gyro_sample(i);
    ap(i,1) = esp.get_air_pressure_sample(i);
    temp(i,:) = esp.get_temperature_sample(i);
end
figure; plot(time, acc); title('Accelerometer'); legend('X', 'Y', 'Z');
figure; plot(time, mag); title('Magnetometer'); legend('X', 'Y', 'Z');
figure; plot(time, gyro); title('Gyro'); legend('X', 'Y', 'Z');
figure; plot(time, ap); title('Barometer'); 
figure; plot(time, temp); title('Thermometer'); 


