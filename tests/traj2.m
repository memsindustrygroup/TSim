function [ t ] = traj2( input_args )
% Unit test function for position trajectory class
path(path, '../tool');
path(path, '../examples');
close all;
clc;

TimeInc=0.01;
testType = 'position';
% testType = 'velocity';
%testType = 'acceleration';
% testType = 'sinusoidal';

t = PositionTrajectory('Traj1');

if (strcmp(testType, 'position'))
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
    
    t = t.set_position('spline', data(:,1), data(:,2:4) );
    t = t.compute(TimeInc, [], []);
    t.plot_pt_all();
    
elseif (strcmp(testType, 'velocity'))
    %      time   X     Y      Z
    data = [0,    0.0,   0.0,  0.0;
            1,    0.0,   0.0,  0.0;
            2,    1.0,   1.0,  1.0;
            3,    1.0,   1.0,  1.0;
            4,    0.0,   0.0,  0.0;
            5,    0.0,   0.0,  0.0;
            6,    0.0,   0.0,  0.0;
            7,    0.0,   0.0,  0.0];
    
    t = t.set_velocity('linear', data(:,1), data(:,2:4) );
    t = t.compute(TimeInc, [], []);
    t.plot_pt_all();
elseif (strcmp(testType, 'acceleration'))
    %      time   X     Y      Z
    data = [0,    0.0,   0.0,  0.0;
        1,    0.0,   0.0,  0.0;
        2,    1.0,   0.0,  0.0;
        3,    1.0,   0.0,  0.0;
        4,    -1.0,   0.0,  0.0;
        5,    -1.0,   1.0,  0.0;
        6,    0.0,   1.0,  0.0;
        7,    0.0,   -1.0,  0.0;
        8,    0.0,   -1.0,  1.0;
        9,    0.0,   0.0,  1.0;
        10,    0.0,   0.0,  -1.0;
        11,    0.0,   0.0,  -1.0;
        12,    0.0,   0.0,  0.0;
        13,    0.0,   0.0,  0.0 ];
    
    t = t.set_acceleration('linear', data(:,1), data(:,2:4) );
    t = t.compute(TimeInc, [], []);
    t.plot_pt_all();
    
elseif (strcmp(testType, 'sinusoidal'))
    % sinusoid2 is defined in the 'examples' directory
    [ data, time ] = sinusoid2( 0.01, 20, 1, 1 );
    t = t.set_acceleration('spline', time, data );
    t = t.compute(TimeInc, [], []);
    t.plot_pt_all();
end
end
