% Copyright (c) 2012, Freescale Semiconductor

path(path, '../tool');
close all;
clc;
outputDir = 'esp_example2_outputs';

% constant definitions
sample_rate = 100;               % sensor sample rate
ts = 1/sample_rate;              % sample interval

% Define the environment
env = Env(Env.ENU);

r = 2*pi()/20; d=9; % used in definition of Adata below
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
Pdata = [0.0,   0.0,  0.0;
    0.0,   0.0,  0.0;
    1.0,   0.0,  0.2;
    1.0,   1.0,  0.4;
    0.0,   1.0,  0.6;
    0.0,   0.0,  0.8;
    1.0,   0.0,  1.0;
    1.0,   1.0,  1.2;
    0.0,   1.0,  1.4;
    0.0,   0.0,  1.6];
Ptime=0:9;

% Compute parameters for a low pass filter
% Cutoff frequency=1Hz
% frequency = 200Hz, 200 taps
% This filter takes several seconds to run, but does a nice job of
% ensuring that our waveforms look reasonable.
% Note that it DOES introduce phase delay (which we don't care about)
[ N, D ] = LPF( 1, 200, 200 );

t = CompositeTrajectory('Traj1');
t = t.set_av('linear', Atime, Adata);
t = t.set_position('spline', Ptime, Pdata );
t = t.compute(0.01, 0.005, N, D);
t.plot_all([1;1;1], outputDir);

esp = ExampleSensorPod(env, t, ts);
esp.ap_gaussian_noise = 0.1;            % Pascals
esp.mag_gaussian_noise = [.1; .1; .1];  % microTesla for X, Y & Z
esp = esp.corrupt();

% dump sensor information
esp.plot_all(outputDir);