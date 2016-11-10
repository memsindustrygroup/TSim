% © 2012-2016 NXP Semiconductor N.V..  All rights reserved.
% SPDX-License-Identifier: BSD-3-Clause
% The BSD 3-clause license for this file can be found in the license.pdf file included with this 
% distribution or at https://spdx.org/licenses/BSD-3-Clause.html

function [ orient ] = standard_orientation( choice )
% ORIENTATION CHANGE BY 90deg:
%-------------------------------
q0_0 = cosd(0/2);
q0_p90 = cosd(90/2);
q0_m90 = cosd(-90/2);
qx_0 = sind(0/2);
qx_p90 = sind(90/2);
qx_m90 = sind(-90/2);
% DEFINITIONS OF INITIAL ORIENTATION QUATERNIONS:
InitOrientQ_Axm1 = [q0_p90  0  qx_p90  0];  % Ax=-1 OK
InitOrientQ_Axp1 = [q0_m90  0  qx_m90  0];  % Ax=+1
InitOrientQ_Aym1 = [q0_m90  qx_m90  0  0];  % Ay=-1 OK
InitOrientQ_Ayp1 = [q0_p90  qx_p90  0  0];  % Ay=+1
InitOrientQ_Azm1 = [0  0  1  0];            % Az=-1
InitOrientQ_Azp1 = [1  0  0  0];            % Az=+1
switch choice
    case 1
        orient = InitOrientQ_Axm1;
    case 2
        orient = InitOrientQ_Axp1;
    case 3
        orient = InitOrientQ_Aym1;
    case 4
        orient = InitOrientQ_Ayp1;
    case 5
        orient = InitOrientQ_Azm1;
    case 6
        orient = InitOrientQ_Azp1
end

end

