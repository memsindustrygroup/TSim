% Copyright (c) 2012, Freescale Semiconductor
function [retVal] = points_match(a, b)
eps=0.0001;
[ra, ca] = size(a);
[rb, cb] = size(b);
retVal=1;
if ((ra~=rb)||(ca~=cb))
    retVal = 0; % return false
elseif ((ra>1)&&(ca>1))
    retVal = 0; % return false
else
    m=max(ra,ca);
    for i=1:m
        d=abs(a(i)-b(i));
        if (d>eps)
            retVal = 0; % return false
            break;
        end
    end
end
end
