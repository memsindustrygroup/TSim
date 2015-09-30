clc;
ts = 0.01;
time=(0:ts:30);
%s = sinusoid(offset, magnitude, frequency,   start_time,     stop_time);
s1 = sinusoid( 0,      1,         .5,         10,             20);
d1 = s1.value(time);
plot(time,d1);
title('sinusoid1 plot');
