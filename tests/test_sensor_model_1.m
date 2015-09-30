function [ output_args ] = test_sensor_model_1( input_args )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
path('../tool', path);
noise = 1e-4*[1;1;1];
s = three_axis_sensor_model_1(2, 12, 1/200);
s = s.set_noise_density(noise);
s = s.set_random_walk(noise, 200);
s = s.add_scale_factor([1.1;1.1;1.1]);
s = s.add_misalignment_in_radians([0.01; 0; 0]);
s = s.add_misalignment_in_degrees([0; 0.5; 0]);
temperature=26;
vectorIn=[.9;.5;.4];
otherVectorIn=[0;0;0];
for time=1:10
    [vectorOut] = s.corrupt(temperature, time, vectorIn, otherVectorIn)
end
end

