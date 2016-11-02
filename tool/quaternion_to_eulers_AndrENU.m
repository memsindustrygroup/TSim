function [ eulers ] = quaternion_to_eulers_AndrENU( q )
% Convert quaternion to Euler Angles for Android reference frame
% This is a direct translation of fAndroidAnglesDegFromRotationMatrix
% from the NXP Sensor Fusion implementation.
q0 = q(1);
q1 = q(2);
q2 = q(3);
q3 = q(4);
m11 = 2*q0*q0 + 2*q1*q1 - 1;
m12 = 2*q1*q2 + 2*q0*q3;
m13 = 2*q1*q3 - 2*q0*q2;
m21 = 2*q1*q2 - 2*q0*q3;
m22 = 2*q0*q0 + 2*q2*q2 - 1;
m23 = 2*q2*q3 + 2*q0*q1;
m33 = 2*q0*q0 + 2*q3*q3 - 1;

phi = asind(m13);            % ROLL
theta = atan2d(-m23, m33);   % PITCH
if (theta == 180.0) 
    theta=-180.0; % map +180 pitch onto the functionally equivalent -180 deg pitch
end
if (phi == 0.0)      
    psi = atan2d(m21, m22) - theta;% vertical downwards gimbal lock case
elseif (phi == -90.0) 
    psi = atan2d(m21, m22) + theta;% vertical upwards gimbal lock case
else
    psi = atan2d(-m12, m11);        % general case YAW
end
% map yaw angle Psi onto range 0.0 <= Psi < 360.0 deg
if (psi<0)          
    psi = psi + 360; % map yaw angle Psi onto range 0.0 <= Psi < 360.0 deg
end
% check for rounding errors mapping small negative angle to 360 deg
if (psi > 360)
    psi = 0;
end

phi = real(phi);
theta = real(theta);
psi = real(psi);
eulers = [phi, theta, psi];
end
