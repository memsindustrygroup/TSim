function [ data, time ] = sinusoid2( ts, stop_time, f, mag  )
% This function creates separate sin wave cycles for each of X, Y & Z.
% ts = sample time
% stop_time = maximum time for the simulation
% f = frequency for the sinusoids
% mag = magnitude of the sin waves
    offset = 0;
    time=0:ts:stop_time;
    %s = sinusoid(offset, magnitude, frequency, start_time, stop_time);
    s1 = sinusoid( 0,      mag,         f,         2,          4);
    s2 = sinusoid( 0,      mag,         f,         6,          8);
    s3 = sinusoid( 0,      mag,         f,         10,         12);
    d1 = s1.value(time);  
    d2 = s2.value(time);  
    d3 = s3.value(time);  
    data(:,1)=d1;
    data(:,2)=d2;
    data(:,3)=d3;
    plot(time,data)
    title('sinusoid2 plot');
end

