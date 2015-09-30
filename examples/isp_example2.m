function [ output_args ] = isp_example2( input_args )

path(path, '../tool');
outputDir = 'isp_example2_outputs';
close all;

% constant definitions
sample_rate = 10;               % sensor sample rate
ts = 1/sample_rate;

% Define the environment
env = Env(Env.NED)

% Define our trajectory

traj = CompositeTrajectory('Constellation');
time = [0; 2]';
data = [0, 0, 0; 0, 0, 0]; % No positional movement
traj = traj.set_position('linear', time, data );

Atime = [0:0.1:2]';
Adata(:,1) = 20*sin(pi*Atime);
Adata(:,2) = Atime/6;
Adata(:,3) = 20*sin(pi*Atime/3);
traj = traj.set_av('spline', Atime, Adata);
traj = traj.compute(0.05, 0.005, [], []);
num=1;
traj.plot_at_all([num; num; num], outputDir); % vector chosen for visualizaton purposes only

% Link sensor pod to the environment and trajectory
isp = IdealSensorPod(env, traj, ts);

% Plot resultant values
isp.plot_all(outputDir);
% dump sensor information
isp.data_dump(outputDir);
end

