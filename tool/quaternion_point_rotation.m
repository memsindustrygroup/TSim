% Copyright (c) 2012, Freescale Semiconductor
function [ output_vector ] = quaternion_point_rotation( q, v )
% This algorithm was derived from page 158 of Quaternions and Rotation
% Sequences by Jack B. Kuipers.
% Kuipers specifies the rotation as a FRAME rotation through a certain
% angle.  If you want a POINT rotation, it must be through the negative of
% that angle.  That is done by the transpose operator in the final
% statement.
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
C = [c11 c12 c13; c21 c22 c23; c31 c32 c33];
output_vector = C'*v;   % the transpose operation here is the only difference
                        % from the quaternion_frame_rotation function
end

