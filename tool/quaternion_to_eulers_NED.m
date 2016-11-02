function [ eulers ] = quaternion_to_eulers_NED( q )
% Convert quaternion to Aerospace Euler Angles
% References:
% * fNEDAnglesDegFromRotationMatrix from the NXP Sensor Fusion code.
% * page 168 of Quaternions and Rotation Sequences by Jack B. Kuipers
q0 = q(1);
q1 = q(2);
q2 = q(3);
q3 = q(4);
m11 = 2*q0*q0+2*q1*q1-1;
m12 = 2*q1*q2 + 2*q0*q3;
m13 = 2*q1*q3 - 2*q0*q2;
m22 = 2*q0*q0 + 2*q2*q2 - 1;
m23 = 2*q2*q3 + 2*q0*q1;
m32 = 2*q2*q3 - 2*q0*q1;
m33 = 2*q0*q0+2*q3*q3-1;

% calculate the pitch angle -90.0 <= Theta <= 90.0 deg
theta = asind(-m13);

% calculate the roll angle range -180.0 <= Phi < 180.0 deg
phi = atan2d(m23, m33);
if (phi == 180.0) 
    phi = -180.0; % map +180 roll onto the functionally equivalent -180 deg roll
end

% calculate the yaw (compass) angle 0.0 <= Psi < 360.0 deg
if (theta == 90)
    psi = atan2d(m32, m22) + phi;
elseif (theta == -90)
    psi = atan2d(-m32, m22) - phi;
else
    psi = atan2d(m12, m11);
end
% map yaw angle Psi onto range 0.0 <= Psi < 360.0 deg
if (psi<0)          
    psi = psi + 360; % map yaw angle Psi onto range 0.0 <= Psi < 360.0 deg
end
% check for rounding errors mapping small negative angle to 360 deg
if (psi >= 360)
    psi = 0;
end

phi = real(phi);
theta = real(theta);
psi = real(psi);
eulers = [phi, theta, psi];

end

