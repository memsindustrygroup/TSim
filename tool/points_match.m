% © 2012-2016 NXP Semiconductor N.V..  All rights reserved.
% SPDX-License-Identifier: BSD-3-Clause
% The BSD 3-clause license for this file can be found in the license.pdf file included with this 
% distribution or at https://spdx.org/licenses/BSD-3-Clause.html

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
