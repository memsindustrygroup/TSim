% Copyright (c) 2012, Freescale Semiconductor
function [ R ] = quaternion_multiplication( p, q )
% See Page 109 of Kuipers, eq. 5.3  r = pq
p0=p(1);
p1=p(2);
p2=p(3);
p3=p(4);

P = [p0, -p1, -p2, -p3; 
     p1,  p0, -p3,  p2; 
     p2,  p3,  p0, -p1; 
     p3, -p2,  p1,  p0];
 
R = P*q;
end
