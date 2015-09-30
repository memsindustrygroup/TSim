% Copyright (c) 2012, Freescale Semiconductor
function [valOut] = clamp(valIn, limit)
% clamp() simply forces a value to be between -limit and limit.  Useful as
% a sanity test prior to doing inverse trig functions.
if (valIn>limit)
    valOut = limit;
elseif (valIn < -limit)
    valOut = -limit;
else
    valOut = valIn;
end
end
