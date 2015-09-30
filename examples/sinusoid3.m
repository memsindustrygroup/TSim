function [ data, time ] = sinusoid3( ts, stop_time, f, mag )
% This function creates an initial cycle of XYZ for calibration, then
% separate cycles for each of X, Y & Z.
% ts = sample time
% stop_time = maximum time for the simulation
% f = frequency for the sinusoids
% mag = magnitude of the second set of sin waves
offset = 0;
time=0:ts:stop_time;
%s = sinusoid(offset, magnitude, frequency, start_time, stop_time);
s0 = sinusoid( 0,    0.5*mag,         f,         2,          8);
s1 = sinusoid( 0,        mag,         f,         10,         12);
s2 = sinusoid( 0,        mag,         f,         14,         16);
s3 = sinusoid( 0,        mag,         f,         18,         20);
d1 = s1.value(time)+s0.value(time);
d2 = s2.value(time)+s0.value(time);
d3 = s3.value(time)+s0.value(time);
data(:,1)=d1;
data(:,2)=d2;
data(:,3)=d3;
% plot(time,data)
% title('sinusoid3 plot');
end

