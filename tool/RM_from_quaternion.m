% © 2012-2016 NXP Semiconductor N.V..  All rights reserved.
% SPDX-License-Identifier: BSD-3-Clause
% The BSD 3-clause license for this file can be found in the license.pdf file included with this 
% distribution or at https://spdx.org/licenses/BSD-3-Clause.html

function [ RM ] = RM_from_quaternion( q )
% This algorithm was extracted from page 158 of Quaternions and Rotation
% Sequences by Jack B. Kuipers.
q0 = q(1);
q1 = q(2);
q2 = q(3);
q3 = q(4);
c11 = 2*q0*q0-1+2*q1*q1;
c12 = 2*q1*q2+2*q0*q3;
c13 = 2*q1*q3-2*q0*q2;
c21 = 2*q1*q2-2*q0*q3;
c22 = 2*q0*q0-1+2*q2*q2;
c23 = 2*q2*q3+2*q0*q1;
c31 = 2*q1*q3+2*q0*q2;
c32 = 2*q2*q3-2*q0*q1;
c33 = 2*q0*q0-1+2*q3*q3;
RM = [c11 c12 c13; c21 c22 c23; c31 c32 c33];
end

