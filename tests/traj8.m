function [ t ] = traj8( input_args )
% Create trajectory based on linear interpolation and no low pass filtering
path(path, '../tool');
close all;
clc;

LabelPts=1;
num = sqrt(1/3);
r = 2*pi();
d=20;

% Angular velocity initialization
%        X     Y      Z      
Adata = [0.0,  0.0,   0.0;
         0.0,  0.0,   0.0;
         r  ,  0.0,   0.0;
         r  ,  0.0,   0.0;
         0.0,  0.0,   0.0;
         0.0,  0.0,   0.0];
Atime = [0; 1; 2; d-2; d-1; d];

% position initialization
Pdata = [0.0,  0.0,   0.0;
         0.0,  0.0,   0.0;
         1  ,  0.0,   0.0;
         0.0,  0.0,   0.0;
         0.0,  0.0,   0.0;
         0.0,  0.0,   0.0;
         0.0,  0.0,   0.0];
Ptime = [0; 1; (d/2)+1; d-3; d-2; d-1; d];

    t = CompositeTrajectory('Traj1');
    t = t.set_av('linear', Atime, Adata);
    t = t.set_position('linear', Ptime, Pdata);
    t = t.compute(0.05, 0.005, [], []);

    num = sqrt(1/3);
    t.plot_all([num; num; num]); % vector chosen for visualizaton purposes only

end
