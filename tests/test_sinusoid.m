function [ output_args ] = test_sinusoid( input_args )
% Unit test of the sinusoid class
clc;
close all;
offset = .5;
magnitude =2;
frequency = 1;
start_time = 2;
stop_time = 6;

    s = sinusoid(offset, magnitude, frequency, start_time, stop_time);
    s.plot(0, 10, .01)

end

