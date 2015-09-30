% Copyright (c) 2012, Freescale Semiconductor
classdef sinusoid
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        o, m, f, start, stop;
    end
    
    methods
        function [s] = sinusoid(offset, magnitude, frequency, start_time, stop_time)
            s.o=offset;
            s.m=magnitude;
            s.f=frequency;
            s.start=start_time;
            s.stop=stop_time;
        end
        function [val] = single_value(s, t)
            if (t<=s.start)
                val = s.o;
            elseif (t>=s.stop)
                angle = s.f*(s.stop-s.start)*2*pi();
                val = s.o+s.m*sin(angle);
            else
                angle = s.f*(t-s.start)*2*pi();
                val = s.o+s.m*sin(angle);
            end
        end
        function [data] = value(s, ts)
            [r, c] = size(ts);
            if ((r>1)&&(c>1)) 
                error('time value supplied to sinusoid is not 1xN or Nx1 or 1x1.')
                data=0;
            elseif ((r==1)&&(c==1))
                data=s.single_value(ts);
            else
                m=0;
                for i=1:r
                    for j=1:c
                        m=m+1;
                        data(m) = s.single_value(ts(i,j));
                    end
                end
            end
        end
        function [] = plot(s, t1, t2, tinc)
            ts = t1:tinc:t2;
            data = s.value(ts);
            plot(ts, data);
        end
    end
    
end

