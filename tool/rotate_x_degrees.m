% Copyright (c) 2012, Freescale Semiconductor
function [ rotation_matrix ] = rotate_x_degrees( angle )
%Generate 3x3 rotation matrix for rotation about x
% Angle is in degrees, positive according to RHR
angle = 2*pi* angle/360;
rotation_matrix = [1 0 0; 0 cos(angle) sin(angle); 0 -sin(angle) cos(angle)];
end

