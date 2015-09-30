% Copyright (c) 2012, Freescale Semiconductor
function [ rotation_matrix ] = rotate_y_degrees( angle )
%Generate 3x3 rotation about y
% Angle is in degrees; Positive according to RHR
angle = 2*pi* angle/360;
rotation_matrix = [cos(angle) 0 -sin(angle); 0 1 0; sin(angle) 0 cos(angle)];
end

