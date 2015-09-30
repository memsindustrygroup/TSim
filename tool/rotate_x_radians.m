% Copyright (c) 2012, Freescale Semiconductor
function [ rotation_matrix ] = rotate_x_radians( angle )
%Generate 3x3 rotation matrix for rotation about x
% Angle is in radians.  Positive according to RHR
rotation_matrix = [1 0 0; 0 cos(angle) sin(angle); 0 -sin(angle) cos(angle)];
end

