% © 2012-2016 NXP Semiconductor N.V..  All rights reserved.
% SPDX-License-Identifier: BSD-3-Clause
% The BSD 3-clause license for this file can be found in the license.pdf file included with this 
% distribution or at https://spdx.org/licenses/BSD-3-Clause.html

function [ q ] = RM_to_quaternion(RM)
% Convert rotation matrix to quaternion format
% Equations arfe from page 169 of Kuipers
q0 = sqrt(RM(1,1)+RM(2,2)+RM(3,3)+1)/2;
q1 = (RM(2,3)-RM(3,2))/(4*q0);
q2 = (RM(3,1)-RM(1,3))/(4*q0);
q3 = (RM(1,2)-RM(2,1))/(4*q0);
q = [q0; q1; q2; q3];
end

