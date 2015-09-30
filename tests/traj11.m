function [ t ] = traj11( input_args )
% Create trajectory based on linear interpolation followed by low pass
% filter.  There is no linear acceleration in this trajectory.  Angular
% velocity is initialized with the sinusoid3 example routine
close all;
clc;
path('../tool', path);
path('../examples', path);

% Compute parameters for a low pass filter
    % Cutoff frequency=2Hz, sample frequency = 200Hz, 200 taps
    % This filter takes several seconds to run, but does a nice job of
    % ensuring that our waveforms look reasonable.
    % Note that it DOES introduce phase delay (which we don't care about)
    [ N, D ] = LPF( 2, 200, 200 ); 
    
    t = CompositeTrajectory('Traj11');
    data = [0, 0, 0; 0, 0, 0];
    time = [0; 22];
    t = t.set_velocity('linear', time, data );

    % sinusoid3 is defined in the examples sub-directory
    [ Adata, Atime ] = sinusoid3( 0.01, 22, 1, 1 );
    t = t.set_av('linear', Atime, 5*Adata);
    ok = t.precheck(); % Optional
    t = t.compute(0.05, 0.005, N, D);
        
    num = sqrt(1/3);
    t.plot_all([num; num; num]); % vector chosen for visualizaton purposes only
  
end
