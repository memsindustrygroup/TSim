function [ t ] = traj_static( input_args )
% This trajectory has NO MOTION at all.  It is used for creating the
% "static" data set needed for sensor calibration

t = CompositeTrajectory('Static');
time = [0; 10]';
data = [0, 0, 0; 0, 0, 0]; % No positional movement
t = t.set_position('linear', time, data );
t = t.set_av('linear', time, data);
ok = t.precheck(); % Optional
t = t.compute(0.05, 0.01, [], []);
end
