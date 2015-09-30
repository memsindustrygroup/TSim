% Quaternion initialization
num = 1/sqrt(2);
data = [1.0,  0.0,   0.0,  0.0;  % identity
        num,  num,   0.0,  0.0;  % 90 about X
        0.0,  1.0,   0.0,  0.0;  % 180 degrees about X
        num,  -num,  0.0,  0.0;  % -90 about X
        -1.0, 0.0    0.0,  0.0;  % back to identity
        num,  0.0,   num,  0.0;  % 90 about Y
        0.0,  0.0,   1.0,  0.0;  % 180 degrees about y
        num,  0.0,   -num, 0.0;  % -90 about Y
        -1.0, 0.0    0.0,  0.0;  % back to identity
        num,  0.0,   0.0,  num;  % 90 about Z
        0.0,  0.0,   0.0,  1.0;  % 180 degrees about Z
        num,  0.0,   0.0,  -num; % -90 about Z
        1.0,  0.0,   0.0,  0.0
]; % back to starting point
 
    time = 0:12;
    Vin = [1; 0; 0];  % Used for ploting purposes
    t = AttitudeTrajectory('Traj1');
    t = t.quaternion_initialization(time, data);
    t = t.compute(0.1, 0.01, [], []);
    t.plot_at_all(Vin);
