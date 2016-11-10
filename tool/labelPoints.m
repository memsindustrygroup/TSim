% © 2012-2016 NXP Semiconductor N.V..  All rights reserved.
% SPDX-License-Identifier: BSD-3-Clause
% The BSD 3-clause license for this file can be found in the license.pdf file included with this 
% distribution or at https://spdx.org/licenses/BSD-3-Clause.html

function [ts2] = labelPoints(ts1, ts2)
if (~isempty(ts1))
    [r, c] = size(ts1.Time);
    if (r<=30)
        for i=1:r
            time = ts1.Time(i);
            e1 = tsdata.event('interrupt', time);
            e1.Units = 'seconds';
            events(i)=e1;
        end
        ts2 = addevent(ts2, events);
    end
end
