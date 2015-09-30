function [ data, time ] = sinusoid4( ts, start_time, stop_time, fx, magx, fy, magy, fz, magz  )
% This function creates continuous sin wave cycles for each of X, Y & Z.
% ts = sample time
% stop_time = maximum time for the simulation
% fx, fy, fz = frequency for the sinusoids
% magx, magy, magz = magnitude of the sin waves
% Example usage:
% sinusoid4(.01, 20, .3, 1, .5, 1, 1, 1);
% sinusoid1 is a subset of this function.
    offset = 0;
    time=0:ts:stop_time;
    %s = sinusoid(offset, magnitude, frequency, start_time, stop_time);
    s1 = sinusoid( 0,      magx,         fx,    start_time, stop_time);
    s2 = sinusoid( 0,      magy,         fy,    start_time, stop_time);
    s3 = sinusoid( 0,      magz,         fz,    start_time, stop_time);
    d1 = s1.value(time);  
    d2 = s2.value(time);  
    d3 = s3.value(time);  
    data(:,1)=d1;
    data(:,2)=d2;
    data(:,3)=d3;
     plot(time,data)
     title('sinusoid1 plot');
end

