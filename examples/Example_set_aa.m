r = 2*pi();
% angular acceleration initialization
%       X     Y      Z
data = [0.0,  0.0,   0.0;
        r  ,  0.0,   0.0;
        r  ,  0.0,   0.0;
        0.0,  0.0,   0.0  ]; 
time = [0; 1; 5; 6];
t = AttitudeTrajectory('Traj1');
t = t.set_aa('linear', time, data);
t = t.compute(0.05, 0.01, [], []);
n=sqrt(1/3);
t.plot_at_all([n; n; n]);

