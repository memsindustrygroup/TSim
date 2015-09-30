function [ data, time ] = sinusoid1( ts, stop_time, fx, magx, fy, magy, fz, magz  )
% This function creates continuous sin wave cycles for each of X, Y & Z.
% ts = sample time
% stop_time = maximum time for the simulation
% fx, fy, fz = frequency for the sinusoids
% magx, magy, magz = magnitude of the sin waves
% Example usage:
% sinusoid1(.01, 20, .3, 1, .5, 1, 1, 1);
    start_time = 0;
    [ data, time ] = sinusoid4( ts, start_time, stop_time, fx, magx, fy, magy, fz, magz  )
end

