% Create trajectory based on linear interpolation followed by low pass
% filter.  Angular velocity is square wave, position is triangular.
path(path, '../tool');
close all;
clc;

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
num = sqrt(1/3);
t.plot_orientation_and_position([num; num; num])
