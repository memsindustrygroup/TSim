function [ eulers ] = quaternion_to_eulers_Win8( q )
% Convert quaternion to Win8 Euler Angles
% This is a direct translation of fWin8AnglesDegFromRotationMatrix from
% the NXP Sensor Fusion code.
q0 = q(1);
q1 = q(2);
q2 = q(3);
q3 = q(4);
m11 = 2*q0*q0 + 2*q1*q1-1;
m12 = 2*q1*q2 + 2*q0*q3;
m13 = 2*q1*q3 - 2*q0*q2;
m21 = 2*q1*q2 - 2*q0*q3;
m22 = 2*q0*q0 + 2*q2*q2 - 1;
m23 = 2*q2*q3 + 2*q0*q1;
m33 = 2*q0*q0 + 2*q3*q3 - 1;

% calculate the roll angle -90.0 <= Phi <= 90.0 deg
if (m33==0)
    if (m13>=0)
        phi = -90;
    else
        phi = 90;
    end
else  % general case
    phi = atand(-m13/m33);
end

% first calculate the pitch angle The in the range -90.0 <= The <= 90.0 deg
theta = asind(m23);

if (m33<0)
    theta = 180-theta;
end
% map the pitch angle The to the range -180.0 <= The < 180.0 deg
if (theta>=180) % map the pitch angle The to the range -180.0 <= The < 180.0 deg
    theta = theta - 360;
end

% calculate the yaw angle Psi
if (theta == 90)
    % vertical upwards gimbal lock case: -270 <= Psi < 90 deg
    psi = atan2d(m12, m11) - phi;
elseif (theta == -90)
    % vertical downwards gimbal lock case: -270 <= Psi < 90 deg
    psi = atan2d(m12, m11) + phi;
else
    % general case: -180 <= Psi < 180 deg
    psi = atan2d(-m21, m22);
    % correct the quadrant for Psi using the value of The to give -180 <= Psi < 380 deg
    if (abs(theta) >= 90)
        psi = psi + 180;
    end
end
% map yaw angle Psi onto range 0.0 <= Psi < 360.0 deg
if (psi < 0)
    psi = psi + 360;
end
% check for any rounding error mapping small negative angle to 360 deg
if (psi >= 360)
    psi = 0;
end

phi = real(phi);
theta = real(theta);
psi = real(psi);
eulers = [phi, theta, psi];

end

