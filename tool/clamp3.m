% Copyright (c) 2012, Freescale Semiconductor
function [valOut] = clamp3(valIn, limit)
% clamp() simply forces a value to be between -limit and limit.  Useful as
% a sanity test prior to doing inverse trig functions.
x = clamp(valIn(1), limit);
y = clamp(valIn(2), limit);
z = clamp(valIn(3), limit);
valOut=[x;y;z];
end
