function [ output_args ] = esp_example1( input_args )

path(path, '../tool');
outputDir = 'esp_example1_outputs';
close all;

% constant definitions
sample_rate = 100;                % sensor sample rate
ts = 1/sample_rate;

% Define the environment
env = Env(Env.ENU);

% Define our trajectory

traj = CompositeTrajectory('isp_example1');
data = [0, 0, 0; 0, 0, 0; 0, 0, Env.magG/20; 0, 0, -Env.magG/20];
time = [0; 1; 9; 22];
traj = traj.set_acceleration('linear', time, data );

% sinusoid3 is defined in the examples directory
[ Adata, Atime ] = sinusoid3( 0.01, 22, 1, 1 );
traj = traj.set_av('linear', Atime, 5*Adata);
traj = traj.compute(0.05, 0.01, [], []);
traj.plot_all([1;1;1], outputDir);
save('session.mat');
%load('session.mat');
% Link sensor pod to the environment and trajectory
esp = ExampleSensorPod(env, traj, ts);
esp = esp.corrupt();

% Plot resultant values
esp.plot_all(outputDir);
% dump sensor information
esp.data_dump(outputDir);
end

