function [ t ] = traj_rotations( input_args )
% Trajectory for 'rotations' calibration (accelerometer positions)
path('../tool', path);
close all;
% Quaternion initialization
num = sqrt(0.5);
Adata = [1.0,  0.0,   0.0,  0.0;   % identity
    1.0,  0.0,   0.0,  0.0;   % identity
    num,  num,   0.0,  0.0;   % 90 about X
    num,  num,   0.0,  0.0;   % 90 about X
    0.0,  1.0,   0.0,  0.0;   % 180 degrees about X
    0.0,  1.0,   0.0,  0.0;   % 180 degrees about X
    num,  -num,  0.0,  0.0;   % -90 about X
    num,  -num,  0.0,  0.0;   % -90 about X
    -1.0,  0.0    0.0,  0.0;  % back to identity
    -1.0,  0.0    0.0,  0.0;  % back to identity
    num,  0.0,   num,  0.0;   % 90 about Y
    num,  0.0,   num,  0.0;   % 90 about Y
    0.0,  0.0,   1.0,  0.0;   % 180 degrees about y
    0.0,  0.0,   1.0,  0.0;   % 180 degrees about y
    num,  0.0,   -num, 0.0;   % -90 about Y
    num,  0.0,   -num, 0.0;   % -90 about Y
    -1.0,  0.0    0.0,  0.0;  % back to identity
    -1.0,  0.0    0.0,  0.0;  % back to identity
    num,  0.0,   0.0,  num;   % 90 about Z
    num,  0.0,   0.0,  num;   % 90 about Z
    0.0,  0.0,   0.0,  1.0;   % 180 degrees about Z
    0.0,  0.0,   0.0,  1.0;   % 180 degrees about Z
    num,  0.0,   0.0,  -num;  % -90 about Z
    num,  0.0,   0.0,  -num;  % -90 about Z
    1.0,  0.0,   0.0,  0.0;   % back to starting point
    1.0,  0.0,   0.0,  0.0
    ];
[r,c]=size(Adata);

t = CompositeTrajectory('Rotations');
Ptime = [0; r]';
Pdata = [0, 0, 0; 0, 0, 0]; % No positional movement
t = t.set_position('linear', Ptime, Pdata );

Atime = (1:r)';
t = t.quaternion_initialization(Atime, Adata);
ok = t.precheck(); % Optional
t = t.compute(0.05, 0.005, [], []);
num=1;
t.plot_rotation_sequence([0; num; num]); % vector chosen for visualizaton purposes only
% t.animate(10);
end
