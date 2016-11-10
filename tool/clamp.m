% © 2012-2016 NXP Semiconductor N.V..  All rights reserved.
% SPDX-License-Identifier: BSD-3-Clause
% The BSD 3-clause license for this file can be found in the license.pdf file included with this 
% distribution or at https://spdx.org/licenses/BSD-3-Clause.html

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
