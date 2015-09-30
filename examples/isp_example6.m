function [ output_args ] = isp_example6( input_args )

path(path, '../tool');
outputDir = 'isp_example6_outputs';
close all;

% constant definitions
sample_rate = 10;                % sensor sample rate
ts = 1/sample_rate;

% Define the environment
env = Env(Env.NED)

% Define our trajectory

traj = CompositeTrajectory('Constellation');

Atime = [0; 1; 2; 11; 12; 13];
Adata = [0, 0, 0; ...
    0, 0, 0; ...
    1, 0, 0; ...
    1, 0, 0; ...
    0, 0, 0; ...
    0, 0, 0 ];
traj = traj.set_av('linear', Atime, Adata);

Ptime = 0:13;
Pdata = [0.0,   0.0,  0.0;
    0.0,   0.0,  0.0;
    1.0,   0.0,  0.0;
    1.0,   0.0,  0.0;
    -1.0,  0.0,  0.0;
    -1.0,  1.0,  0.0;
    0.0,   1.0,  0.0;
    0.0,  -1.0,  0.0;
    0.0,  -1.0,  1.0;
    0.0,   0.0,  1.0;
    0.0,   0.0, -1.0;
    0.0,   0.0, -1.0;
    0.0,   0.0,  0.0;
    0.0,   0.0,  0.0 ];
traj = traj.set_acceleration('spline', Ptime, Pdata );

traj = traj.compute(0.01, 0.005, [], []);

traj.plot_all([1; 1; 1], outputDir); % vector chosen for visualizaton purposes only
traj.animate(10);
% Link sensor pod to the environment and trajectory
isp = IdealSensorPod(env, traj, ts);

% Plot resultant values
isp.plot_all(outputDir);

end

