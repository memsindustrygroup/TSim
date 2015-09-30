function [ t ] = traj6( input_args )
% Unit test function for attitude trajectory class
path(path, '../tool');
close all;
clc;

LabelPts=1;
r = 2*pi();

% Angular acceleration initializaton
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
    t = t.set_aa('linear', time, data);
    t = t.compute(0.05, 0.01, [], []);

    num=sqrt(1/3);
    Vin = [num; num; num];  % Used for plot_rotation_sequence, which is itself called by plot_at_all
    t.plot_at_all(Vin);
    
end
