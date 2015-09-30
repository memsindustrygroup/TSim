function [ t ] = traj4( input_args )
% Unit test function for attitude trajectory class
path(path, '../tool');
close all;
clc;

LabelPts=1;
num = sqrt(0.5);
%       Time  q0    q1     q2    q3
    
% quaternion initialization
data = [0,    1.0,  0.0,   0.0,  0.0;  % identity
        1,    1.0,  0.0,   0.0,  0.0;  % 90 about X
        2,    num,  0.0,   num,  0.0;  % 90 about Y
        3,    0.0,  0.0,   1.0,  0.0;  % 180 degrees about y
        4,    num,  0.0,   -num, 0.0;  % -90 about Y
        5,    1.0,  0.0,   0.0,  0.0;  % back to identity
        6,    1,    0.0,   0.0,  0.0;  
]; % back to starting point

    t = AttitudeTrajectory('Traj1');
    t = t.quaternion_initialization(data(:,1), data(:,2:5));
    t = t.compute(0.05, 0.01, [], []);
    Vin = [1; 0; 0];  % Used for plot_rotation_sequence, which is itself called by plot_at_all
    t.plot_at_all(Vin);
    
end
