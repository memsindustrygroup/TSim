% © 2012-2016 NXP Semiconductor N.V..  All rights reserved.
% SPDX-License-Identifier: BSD-3-Clause
% The BSD 3-clause license for this file can be found in the license.pdf file included with this 
% distribution or at https://spdx.org/licenses/BSD-3-Clause.html

function [ q ] = quaternion_from_angular_rates( deltaT, w )
% quaternion_from_angular_rates() computes an incremental rotation
% quaternion based upon supplied delta time and angular rates.

% phi   = roll  = rotation about X (w(1))
% theta = pitch = rotation about Y (w(2))
% psi   = yaw   = rotation about Z (w(3))

psi   = w(3)*deltaT;
theta = w(2)*deltaT;
phi   = w(1)*deltaT;

qz = [cos(psi/2);   0;          0;            sin(psi/2)];
qy = [cos(theta/2); 0;          sin(theta/2); 0         ];
qx = [cos(phi/2);   sin(phi/2); 0;            0         ];

q1 = quaternion_multiplication(qy, qz);
q  = quaternion_multiplication(qx, q1);
end

