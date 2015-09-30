path(path, '../tool'); % set this to point to the TSim 
% tool sub-directory
close all;
clc;
traj = PositionTrajectory('test1');
time = [0; 5; 10; 15]';
data = [0, 0, 0; 1, 0, 0; 1, 0, 0; 0, 0, 0]; 
traj = traj.set_acceleration('linear', time, data );
traj = traj.compute(0.05, [], []);
traj.plot_pt_all(); 	% plot all available 
% plots for PositionTrajectory
