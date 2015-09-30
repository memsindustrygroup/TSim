function [ data, time ] = sinusoid5( ts, f, mag )
% This function creates an initial 3 cycles of XYZ for calibration, then
% separate cycles (3 each) for each of X, Y & Z.
% ts = sample time
% stop_time = maximum time for the simulation
% f = frequency for the sinusoids
% mag = magnitude of the second set of sin waves
offset = 0;
dur = 1/f;  % duration for three cycles
sp=2;
stop_time = 5*sp+4*dur
time=0:ts:stop_time;
%s = sinusoid(offset, magnitude, frequency, start_time, stop_time);
s0 = sinusoid( 0,    0.5*mag,         f,         sp,         sp+dur);
s1 = sinusoid( 0,        mag,         f,         2*sp+dur,   2*sp+2*dur);
s2 = sinusoid( 0,        mag,         f,         3*sp+2*dur, 3*sp+3*dur);
s3 = sinusoid( 0,        mag,         f,         4*sp+3*dur, 4*sp+4*dur);
d1 = s1.value(time)+s0.value(time);
d2 = s2.value(time)+s0.value(time);
d3 = s3.value(time)+s0.value(time);
data(:,1)=d1;
data(:,2)=d2;
data(:,3)=d3;
plot(time,data)
title('sinusoid5 plot');
end

