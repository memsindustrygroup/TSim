% Copyright (c) 2012, Freescale Semiconductor
function [newData] = renormalize(data);
% normalize input to magnitude 1.  Often used to ensure we still have 
% valid unit quaternions
[r, c] = size(data);
for i=1:r
    mag = data(i,1)^2 + data(i,2)^2 + data(i,3)^2 + data(i,4)^2;
    mag = sqrt(mag);
    newData(i,:) = data(i,:) / mag;
end
end
