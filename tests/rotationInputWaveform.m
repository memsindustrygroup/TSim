function [ t ] = rotationInputWaveform(  )
% Unit test function for attitude trajectory class
path(path, '../tool');
path(path, '../examples');
close all;
clc;

num = sqrt(0.5);
%       Time  q0    q1     q2    q3
    
% Quaternion initialization
data = [1.0,  0.0,   0.0,  0.0;  % identity
        1.0,  0.0,   0.0,  0.0;  % identity
        num,  num,   0.0,  0.0;  % 90 about X
        num,  num,   0.0,  0.0;  % 90 about X
        num,  num,   0.0,  0.0
]; 
    time = [0, 5, 6.0, 9.0, 10.0];  % Used for ploting purposes

    Vin = [1; 0; 0];  % Used for ploting purposes
    t = AttitudeTrajectory('Traj1');
    t = t.quaternion_initialization(time, data);
    t = t.compute(0.01, 0.0, [], []);
    t.plot_at_all(Vin);

end
