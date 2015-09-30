function [ output_args ] = isp_test1( input_args )

path(path, '../tool');
Mref = [0; 24.34777; -41.47411]; % Magnetic North Frame of Reference: X=East, Y=North, Z=Up, in microTeslas
Gref = [0; 0; 9.80665];          % Gravity vector
temperature = 25;                % Celcius
Altitude = 400;                  % value in meters
sample_rate = 200;               % sensor sample rate
ts = 1/sample_rate;

% Define the environment
env = Env(Env.ENU, Gref, Altitude, Mref, @standard_air_pressure, temperature)

% Pull in pre-defined trajectory
traj   = traj9();

% Link sensor pod to the environment and trajectory
isp = IdealSensorPod(env, traj, ts);

% Plot resultant values
isp.plot_all();
% save data
isp.data_dump('isp_test1')
end

