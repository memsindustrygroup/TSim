% © 2012-2016 NXP Semiconductor N.V..  All rights reserved.
% SPDX-License-Identifier: BSD-3-Clause
% The BSD 3-clause license for this file can be found in the license.pdf file included with this 
% distribution or at https://spdx.org/licenses/BSD-3-Clause.html

function [ result ] = modifyForDeadZone( input, gamma )
    % modify input to account for dead zone that can occur at the zero
    % crossing of some sensors.
    if (input<0)&&(input > (-gamma))
        result = -gamma;
    elseif (input>=0)&&(input < gamma)
        result = gamma;
    else
        result = input;
    end
end

