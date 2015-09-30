% Copyright (c) 2012, Freescale Semiconductor
function [ rotation_matrix ] = rotate_y_radians( angle )
%Generate 3x3 rotation about y
% Angle is in radians; Positive according to RHR
rotation_matrix = [cos(angle) 0 -sin(angle); 0 1 0; sin(angle) 0 cos(angle)];
end

