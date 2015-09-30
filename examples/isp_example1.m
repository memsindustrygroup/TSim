function [ output_args ] = isp_example1( input_args )

path(path, '../tool');
outputDir = 'isp_example1_outputs';
close all;

% constant definitions
sample_rate = 200;               % sensor sample rate
ts = 1/sample_rate;

% Define the environment
env = Env(Env.ENU)

% Define our trajectory

traj = CompositeTrajectory('isp_example1');
data = [0, 0, 0; 0, 0, 0; 0, 0, Env.magG; 0, 0, -Env.magG];
time = [0; 1; 9; 22];
traj = traj.set_acceleration('linear', time, data );

% sinusoid3 is defined in the examples directory
[ Adata, Atime ] = sinusoid3( 0.01, 22, 1, 1 );
traj = traj.set_av('linear', Atime, 5*Adata);
traj = traj.compute(0.05, 0.005, [], []);
traj.plot_all([1;1;1], outputDir);

% Link sensor pod to the environment and trajectory
isp = IdealSensorPod(env, traj, ts);

% Plot resultant values
isp.plot_all(outputDir);
% dump sensor information
isp.data_dump(outputDir);
traj.animate(5);
end

