function [ t ] = traj10( input_args )
% Create trajectory based on linear interpolation followed (NO low pass
% filter).  sinusoid2 utility function is used for both linear and angular
% velocity.
close all;
clc;
path('../tool', path);
path('../examples', path);

LabelPts=1;
r = 2*pi();
d=20;

    % Compute parameters for a low pass filter
    % Cutoff frequency=2Hz, sample frequency = 200Hz, 200 taps
    % This filter takes several seconds to run, but does a nice job of
    % ensuring that our waveforms look reasonable.
    % Note that it DOES introduce phase delay (which we don't care about)
    [ N, D ] = LPF( 2, 200, 200 ); 
    
    t = CompositeTrajectory('Traj1');
    % sinusoid2 is defined in the 'examples' directory
    [ data, time ] = sinusoid2( 0.01, 20, 1, 1 );
    t = t.set_velocity('linear', time, data );

    [ Adata, Atime ] = sinusoid2( 0.01, 20, 1, 1 );

    t = t.set_av( 'linear', Atime, 5*Adata);
    ok = t.precheck(); % Optional
    t = t.compute(0.05, 0.005, [], []);
    
%     RM = rotate_z_radians(pi()/4);
%     t = t.retime_then_rotate(0.01, RM);
    
    num = sqrt(1/3);
    t.plot_all([num; num; num]); % vector chosen for visualizaton purposes only
  
end
