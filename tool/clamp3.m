% © 2012-2016 NXP Semiconductor N.V..  All rights reserved.
% SPDX-License-Identifier: BSD-3-Clause
% The BSD 3-clause license for this file can be found in the license.pdf file included with this 
% distribution or at https://spdx.org/licenses/BSD-3-Clause.html

function [valOut] = clamp3(valIn, limit)
% clamp() simply forces a value to be between -limit and limit.  Useful as
% a sanity test prior to doing inverse trig functions.
x = clamp(valIn(1), limit);
y = clamp(valIn(2), limit);
z = clamp(valIn(3), limit);
valOut=[x;y;z];
end
