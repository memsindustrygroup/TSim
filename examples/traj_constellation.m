function [ t ] = traj_constellation( input_args )
% Create constellation needed for magnetic calibration
% This script does a two-pass process.  The first starts at no rotation,
% applies a bunch of angular velocity values, and outputs a final (initially
% unknown) rotation.
% The second pass uses the complex conjugate of that final rotation (which
% is the same as its inverse) as the STARTING rotation.  Then applying the
% same set of angular velocity values.  The result is that you end up with
% zero rotation at the end of the run.   This is very useful when you need
% to append multiple trajectories as part of the fusion library data
% injection and playback process.
% This two-pass system was added on 9 July, 2014 - MES
% Still to come: adjust trajectory so that final AA and AV are zero.

path('../tool', path);
t = CompositeTrajectory('Constellation');
time = [0; 20]';
data = [0, 0, 0; 0, 0, 0]; % No positional movement
t = t.set_position('linear', time, data );

Atime = [0:0.1:20]';
Adata(:,1) = 20*sin(2*pi*Atime);
Adata(:,2) = Atime/6;
Adata(:,3) = 20*sin(7*pi*Atime);
t = t.set_av('linear', Atime, Adata);
ok = t.precheck(); % Optional
t = t.compute(0.05, 0.005, [], []);

fo = t.O.Data(4001,:);  % this is the final orientation
% now rerun, with reverse fo as starting orientation
% this should put us with zero orientation at the end of the simulation
fo(2)=-fo(2);
fo(3)=-fo(3);
fo(4)=-fo(4);
t = CompositeTrajectory('Constellation'); % discard the old constellation
t = t.set_position('linear', time, data );
t.initial_orientation = fo';

% These statements are exactly as above
Atime = [0:0.1:20]';
Adata(:,1) = 20*sin(2*pi*Atime);
Adata(:,2) = Atime/6;
Adata(:,3) = 20*sin(7*pi*Atime);
t = t.set_av('linear', Atime, Adata);
ok = t.precheck(); % Optional
t = t.compute(0.05, 0.005, [], []);

num=1;
t.plot_at_all([num; num; num]); % vector chosen for visualizaton purposes only
% t.animate(5);
end
