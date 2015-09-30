% Copyright (c) 2012, Freescale Semiconductor
function [ rates ] = quaternion_rates( q, dq )
% See equations 148 and 150 from "Representing Attitude: Euler Angles, Unit
% Quaternions and Rotation Vectors" by James Diebel.
% q = current orientation in quaternion format
% dq = derivative of that quaternion
% rates = angular rates output (radians/sec)

q0=q(1);
q1=q(2);
q2=q(3);
q3=q(4);

Q = [-q1, q0, -q3,  q2;
     -q2, q3,  q0, -q1;
     -q3,-q2,  q1,  q0];
 
rates = 2*Q*dq;

end
