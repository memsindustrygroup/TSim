% © 2012-2016 NXP Semiconductor N.V..  All rights reserved.
% SPDX-License-Identifier: BSD-3-Clause
% The BSD 3-clause license for this file can be found in the license.pdf file included with this 
% distribution or at https://spdx.org/licenses/BSD-3-Clause.html

function [ rotation_matrix ] = rotate_z_degrees( angle )
% Generate 3x3 rotation matrix for rotation about z
% Angle is in degrees; Positive according to RHR
% new_vector = rotation_matrix*old_vector
angle = 2*pi* angle/360;
rotation_matrix = [cos(angle) sin(angle) 0; -sin(angle) cos(angle) 0; 0 0 1];
end

