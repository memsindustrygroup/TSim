% © 2012-2016 NXP Semiconductor N.V..  All rights reserved.
% SPDX-License-Identifier: BSD-3-Clause
% The BSD 3-clause license for this file can be found in the license.pdf file included with this 
% distribution or at https://spdx.org/licenses/BSD-3-Clause.html

function [q] = fix_quaternion_polarity(qin)
    [r1, c1] = size(qin);
    for i=1:r1
        if (qin(i,1)<0) 
            q(i,:) = -qin(i,:);
        else
            q(i,:) = qin(i,:);
        end
    end
end
