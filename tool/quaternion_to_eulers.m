function [ phi, theta, psi ] = quaternion_to_eulers( q0, q1, q2, q3 )
% Convert quaternion to Euler Angles
% From page 168 of Quaternions and Rotation Sequences by Jack B. Kuipers
m11 = 2*q0*q0+2*q2*q1-1;
m12 = 2*q1*q2 + 2*q0*q3;
m13 = 2*q1*q3 - 2*q0*q2;
m23 = 2*q2*q3 + 2*q0*q1;
m33 = 2*q0*q0+2*q3*q3-1;
psi = atan2(m12, m11);
theta = asin(-m13);
phi = atan2(m23, m33);
end

