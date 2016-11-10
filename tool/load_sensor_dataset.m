% © 2012-2016 NXP Semiconductor N.V..  All rights reserved.
% SPDX-License-Identifier: BSD-3-Clause
% The BSD 3-clause license for this file can be found in the license.pdf file included with this 
% distribution or at https://spdx.org/licenses/BSD-3-Clause.html

function [time, mag, acc, gyro, true_AP, true_temp, ...
    true_A, true_quaternions, true_rotations, true_positions, ...
    true_velocity, true_gravity] = load_sensor_dataset(dirName)
% load_sensor_dataset() is used to load a dataset created via
% idealSensorPod::data_dump().
% dirName = directory name created by data_dump()
% time = Nx1 vector of time values
% mag = Nx3 array of X/Y/Z magnetometer readings
% acc = Nx3 array of X/Y/Z accelerometer readings
% gyro = Nx3 array of X/Y/Z gyro readings
% true_AP = Nx1 vector of TRUE air pressure values
% true_quaternions = Nx4 array of orientation quaternions w/X/Y/Z
% true_rotations = Nx9 array of orientation rotation matrices.
%                  order is RM(1,1:3), RM(2,1:3), RM(3,1:3).
% true_positions = Nx3 array of X/Y/Z true coordinates
% true_velocity = Nx3 array of X/Y/Z true velocity
% true_gravity = Nx3 array of X/Y/Z acceleration due to gravity
time = load(fullfile(dirName,'TRUE_time.dat'));
mag = load(fullfile(dirName,'magnetometer.dat'));
acc = load(fullfile(dirName,'accelerometer.dat'));
gyro = load(fullfile(dirName,'gyro.dat'));
true_A = load(fullfile(dirName,'TRUE_accelerometer.dat'));
true_AP = load(fullfile(dirName,'TRUE_air_pressure.dat'));
true_temp = load(fullfile(dirName,'TRUE_temperature.dat'));
true_quaternions = load(fullfile(dirName,'TRUE_quaternion.dat'));
true_positions = load(fullfile(dirName,'TRUE_position.dat'));
true_velocity = load(fullfile(dirName,'TRUE_velocity.dat'));
true_gravity = load(fullfile(dirName,'TRUE_gravity.dat'));
rotation_coefs =  load(fullfile(dirName,'TRUE_rotations.dat'));
[r,c] = size(rotation_coefs);
for i=1:r
    rm(1,1:3) = rotation_coefs(i,1:3);
    rm(2,1:3) = rotation_coefs(i,4:6);
    rm(3,1:3) = rotation_coefs(i,7:9);
    true_rotations{i} = rm;
end

end
