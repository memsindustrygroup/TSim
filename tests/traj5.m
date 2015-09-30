function [ t ] = traj5( input_args )
% Unit test function for attitude trajectory class
path(path, '../tool');
close all;
clc;

LabelPts=1;
r = 2*pi();

% Angular velocity initialization
%       X     Y      Z      
data = [0.0,  0.0,   0.0;
        r  ,  0.0,   0.0;
        r  ,  0.0,   0.0;
        0.0,  0.0,   0.0;
        0.0,  0.0,   0.0;
        -r  , 0.0,   0.0;
        -r  , 0.0,   0.0;
        0.0,  0.0,   0.0;
        0.0,  0.0,   0.0;
        0.0,  r  ,   0.0;
        0.0,  r  ,   0.0;
        0.0,  0.0,   0.0;
        0.0,  0.0,   0.0;
        0.0, -r  ,   0.0;
        0.0, -r  ,   0.0;
        0.0,  0.0,   0.0;
        0.0,  0.0,   0.0;
        0.0,  0.0,   r  ;
        0.0,  0.0,   r  ;
        0.0,  0.0,   0.0;
        0.0,  0.0,   0.0;
        0.0,  0.0,  -r  ;
        0.0,  0.0,  -r  ;
        0.0,  0.0,   0.0;
        0.0,  0.0,   0.0  ];

    [r, c] = size(data);
    time = (0:1:r-1)';
    t = AttitudeTrajectory('Traj1');
    t = t.set_av('linear', time, data);
    t = t.compute(0.05, 0.01, [], []);

    Vin = [1; 0; 0];  % Used for plot_rotation_sequence, which is itself called by plot_at_all
    t.plot_at_all(Vin);
    
end
