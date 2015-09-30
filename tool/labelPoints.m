% Copyright (c) 2012, Freescale Semiconductor
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
