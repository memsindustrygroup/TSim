% Copyright (c) 2012, Freescale Semiconductor
function [ q ] = RM_to_quaternion(RM)
% Convert rotation matrix to quaternion format
% Equations arfe from page 169 of Kuipers
q0 = sqrt(RM(1,1)+RM(2,2)+RM(3,3)+1)/2;
q1 = (RM(2,3)-RM(3,2))/(4*q0);
q2 = (RM(3,1)-RM(1,3))/(4*q0);
q3 = (RM(1,2)-RM(2,1))/(4*q0);
q = [q0; q1; q2; q3];
end

