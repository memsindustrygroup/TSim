% Example using spline interpolation on use specified positions
path(path, '../tool');
close all;
clc;

TimeInc=0.01;

t = PositionTrajectory('Traj1');

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
