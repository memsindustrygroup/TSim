% © 2012-2016 NXP Semiconductor N.V..  All rights reserved.
% SPDX-License-Identifier: BSD-3-Clause
% The BSD 3-clause license for this file can be found in the license.pdf file included with this 
% distribution or at https://spdx.org/licenses/BSD-3-Clause.html

function [ rotation_matrix ] = rotate_z_radians( angle )
% Generate 3x3 rotation matrix for rotation about z
% Angle is in radians; Positive according to RHR
% new_vector = rotation_matrix*old_vector
rotation_matrix = [cos(angle) sin(angle) 0; -sin(angle) cos(angle) 0; 0 0 1];
end

