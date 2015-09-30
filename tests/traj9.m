function [ t ] = traj9( input_args )
% Create trajectory based on linear interpolation followed by low pass
% filter.  Angular velocity is square wave, position is triangular.
path(path, '../tool');
close all;
clc;

LabelPts=1;
r = 2*pi();
d=20;

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
Pdata = [0.0,  0.0,   0.0;
         0.0,  0.0,   0.0;
        10.0,  0.0,   0.0;
         0.0,  0.0,   0.0;
         0.0,  0.0,   0.0;
         0.0,  0.0,   0.0;
         0.0,  0.0,   0.0];
Ptime = [0; 1; (d/2)+1; d-3; d-2; d-1; d];

    % Compute parameters for a low pass filter
    % Cutoff frequency=1Hz, sample frequency = 200Hz, 200 taps
    % This filter takes several seconds to run, but does a nice job of
    % ensuring that our waveforms look reasonable.
    % Note that it DOES introduce phase delay (which we don't care about)
    [ N, D ] = LPF( 1, 200, 200 ); 
    
    t = CompositeTrajectory('Traj1');
    t = t.set_av('linear', Atime, Adata);
    t = t.set_position('linear', Ptime, Pdata);
    ok = t.precheck(); % Optional
%     RM = rotate_y_radians(pi()/10); % Optional
%     t = t.rotate(RM); % Optional
    t = t.compute(0.05, 0.005, N, D);
    
%     RM = rotate_z_radians(pi()/4);
%     t = t.retime_then_rotate(0.01, RM);
    
    num = sqrt(1/3);
    t.plot_all([num; num; num]); % vector chosen for visualizaton purposes only
  
end
