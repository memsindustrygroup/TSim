function [ output_args ] = isp_example1_fast_acc( input_args )


path(path, '../tool');
outputDir = 'isp_example1_fast_acc_outputs';
close all;

% constant definitions
sample_rate = 200;               % sensor sample rate
ts = 1/sample_rate;

% Define the environment
env = Env(Env.ENU)

% Define our trajectory

traj = CompositeTrajectory('isp_example1');
%[ data, time ] = sinusoid1( ts, start_time, stop_time, fx, magx, fy, magy, fz, magz  )
 [ data, time ] = sinusoid4( ts, 1,          22,        .1, 2,    .2, 2,    1,  2  )
 data = Env.magG * data;
traj = traj.set_acceleration('linear', time, data );

% sinusoid3 is defined in the examples directory
[ Adata, Atime ] = sinusoid3( 0.01, 22, 1, 1 );
traj = traj.set_av('linear', Atime, 5*Adata);
traj = traj.compute(0.05, 0.005, [], []);
traj.plot_all([1;1;1], outputDir);
%traj.plot_acceleration_coords(outputDir);

% % Link sensor pod to the environment and trajectory
isp = IdealSensorPod(env, traj, ts);
% 
% % Plot resultant values
isp.plot_all(outputDir);
%isp.plot_acceleration(outputDir);

% % dump sensor information
isp.data_dump(outputDir);
traj.animate(5);
end

