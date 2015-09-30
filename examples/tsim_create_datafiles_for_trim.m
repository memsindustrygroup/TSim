function [ output_args ] = marg_create_datafiles_for_trim( input_args )
path('../tool', path);

sample_rate = 200;               % sensor sample rate
ts = 1/sample_rate;

% Define the environment
env = Env(Env.ENU)

% Pull in pre-defined trajectory
traj   = traj_rotations();

% Link sensor pod to the environment and trajectory
isp = IdealSensorPod(env, traj, ts);

Vin=[1;1;1];
isp.traj.plot_rotation_sequence(Vin);
isp.plot_acceleration();
isp.plot_magnetic_field();

% save data file
isp.data_dump('rotations');

%%%%%%%%%%%%%%%%%%%%%%% Now let's discard the trajectory and ISP used above
%%%%%%%%%%%%%%%%%%%%%%% and create new ones for the constellation data.
%%%%%%%%%%%%%%%%%%%%%%% The environment can (of course) be re-used.
% Pull in pre-defined trajectory
traj   = traj_constellation();

% Link sensor pod to the environment and trajectory
isp = IdealSensorPod(env, traj, ts);

Vin=[1;1;1];
isp.traj.plot_rotation_sequence(Vin);

% save data file
isp.data_dump('constellation');

%%%%%%%%%%%%%%%%%%%%%%% AND ONE MORE TIME!
%%%%%%%%%%%%%%%%%%%%%%% Now let's discard the trajectory and ISP used above
%%%%%%%%%%%%%%%%%%%%%%% and create new ones for the static data set.
% Pull in pre-defined trajectory
traj   = traj_static();

% Link sensor pod to the environment and trajectory
isp = IdealSensorPod(env, traj, ts);

% save data file
isp.data_dump('static');

end

