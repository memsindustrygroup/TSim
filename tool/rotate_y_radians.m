% © 2012-2016 NXP Semiconductor N.V..  All rights reserved.
% SPDX-License-Identifier: BSD-3-Clause
% The BSD 3-clause license for this file can be found in the license.pdf file included with this 
% distribution or at https://spdx.org/licenses/BSD-3-Clause.html

function [ rotation_matrix ] = rotate_y_radians( angle )
%Generate 3x3 rotation about y
% Angle is in radians; Positive according to RHR
rotation_matrix = [cos(angle) 0 -sin(angle); 0 1 0; sin(angle) 0 cos(angle)];
end

