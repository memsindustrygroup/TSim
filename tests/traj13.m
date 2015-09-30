function [ t ] = traj13( input_args )
% Create trajectory based on linear interpolation followed by low pass
% filter.  Linear acceleration is a truncated triangle wave.  Angular
% velocity is initialized using the sinusoid3 example program.
close all;
clc;
% Compute parameters for a low pass filter
% Cutoff frequency=2Hz, sample frequency = 200Hz, 200 taps
% This filter takes several seconds to run, but does a nice job of
% ensuring that our waveforms look reasonable.
% Note that it DOES introduce phase delay (which we don't care about)
[ N, D ] = LPF( 2, 200, 200 );

t = CompositeTrajectory('Traj13');
data = [0, 0, 0; 0, 0, 0; 0, 0, Env.magG; 0, 0, -Env.magG];
time = [0; 1; 9; 22];
t = t.set_acceleration('linear', time, data );

[ Adata, Atime ] = sinusoid3( 0.01, 22, 1, 1 );
t = t.set_av('linear', Atime, 5*Adata);
ok = t.precheck(); % Optional
t = t.compute(0.05, 0.005, N, D);

num = sqrt(1/3);
t.plot_all([num; num; num]); % vector chosen for visualizaton purposes only

end
