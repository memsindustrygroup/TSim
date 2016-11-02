% Copyright (c) 2012-2015, Freescale Semiconductor

path(path, '../tool');
close all;
clc;
outputDir = 'animation_example1_outputs';

% constant definitions
sample_rate = 100;               % sensor sample rate
ts = 1/sample_rate;

% Define the environment
env = Env(Env.ENU);

r = 5*pi();

% Adata for this test is angular velocity
%   X     Y      Z
Adata = [...
    0.0,  r,   0.0;
    0.0,  r,   0.0;
    0.0,  0.0, 0.0;
    r  ,  0.0, 0.0;
    r  ,  0.0, 0.0;
    0.0,  0.0, 0.0; 
    0.0,  0.0    r;
    0.0,  0.0,   r];
Atime = [0; 1; 3; 4; 6; 7; 8; 9];

% Pdata is position data
% time   X     Y      Z
Pdata = [...
    0.0,   0.0,  0.0;
    0.0,   0.0,  0.0;
    1.0,   0.0,  0.2;
    1.0,   1.0,  0.4;
    0.0,   1.0,  0.6;
    0.0,   0.0,  0.8;
    1.0,   0.0,  1.0;
    1.0,   1.0,  1.2;
    0.0,   1.0,  1.4;
    0.0,   0.0,  1.6];
Ptime = 0:9;

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
t.plot_all([1;1;1]);

t.animate(5, 'animation_example1');
