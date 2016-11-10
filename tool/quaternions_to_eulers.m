% © 2012-2016 NXP Semiconductor N.V..  All rights reserved.
% SPDX-License-Identifier: BSD-3-Clause
% The BSD 3-clause license for this file can be found in the license.pdf file included with this 
% distribution or at https://spdx.org/licenses/BSD-3-Clause.html

% Convert an Nx4 array of quaternion coefficients into an Nx3 array of
% Euler angles.
function [eulers] = quaternions_to_eulers(quaternions, refFrame)
    [r1, c1] = size(quaternions);
    for i=1:r1
        switch refFrame
            case Env.NED
                eulers(i,:) = quaternion_to_eulers_NED(quaternions(i,:));
            case Env.Win8
                eulers(i,:) = quaternion_to_eulers_Win8(quaternions(i,:));
            case Env.Android
                eulers(i,:) = quaternion_to_eulers_AndrENU(quaternions(i,:));
        end
    end
end

