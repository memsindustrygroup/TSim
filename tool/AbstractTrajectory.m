% Copyright (c) 2012, Freescale Semiconductor
classdef AbstractTrajectory
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = public)
        startTime, endTime, name;
    end
    
    methods
        function [traj] = AbstractTrajectory(name)
            if  nargin > 0
                traj.name=name;
            else
                traj.name='none'
            end
            traj.startTime=0;
            traj.endTime=0;
        end
        
        % the following methods are utility functions which may be useful by
        % classes derived upon this one.
        %
        function [tsOut] = optional_filter(traj, ts, filter_numerator, filter_denominator)
            if (isempty(filter_numerator) && isempty(filter_denominator))
                tsOut = ts;
            else
                tsOut = filter(ts, filter_numerator, filter_denominator);
            end
        end
        function [newTs] = differentiate(traj, ts, newName)
            data = ts.get('Data');
            time = ts.get('Time');
            
            [r, c] = size(data);
            dT = (time(2)-time(1));
            dTtwo = 2*dT;
            for i=2:r-1
                deltaD = data(i+1,:)-data(i-1,:);
                newData(i,:)=deltaD/dTtwo;
            end
            newData(1,:) = (data(2,:)-data(1,:))/dT;
            newData(r,:) = (data(r,:)-data(r-1,:))/dT;
            newTs = timeseries(newData, time);
            newTs.set('Name', newName);
            newTs.setinterpmethod('linear');
            newUnits = strcat(ts.DataInfo.Units,'/sec');
            newTs.DataInfo.Units = newUnits;
        end
        % compute a new time series from an existing one
        % traj parameter is actually not used.  Function grouped here for
        % convenience.
        function [newTs] = integrate(traj, ts, newName, units, initial_value)
            data = ts.get('Data');
            time = ts.get('Time');
            
            [r, c] = size(data);
            newData(1,:) = time(1)*data(1,:) + initial_value';
            for i=2:r
                dT = (time(i)-time(i-1));
                deltaD = dT*(data(i,:)+data(i-1,:))/2;
                newData(i,:)=newData(i-1,:) + deltaD;
            end
            newTs = timeseries(newData, time);
            newTs.set('Name', newName);
            newTs.DataInfo.Units = units;
        end
        function [newTs] = copyTimeSeries(traj, ts, newName)
            newTs = ts;
            newTs.set('Name', newName);
        end
        function [ts] = rotate_in_place(traj, ts, RM, vector)
            [r, c] = size(ts.Data);
            for i=1:r
                if (vector==1)
                    ts.Data(i,:) = (RM*ts.Data(i,:)')';
                else % assume quaternion orientation values instead
                    p = RM_to_quaternion(RM);
                    ts.Data(i,:) = (quaternion_multiplication(p, ts.Data(i,:)'))';
                end
            end
        end
        function [newTs] = changeTimeIncrement(traj, ts, inc)
            time = ts.TimeInfo.Start:inc:ts.TimeInfo.End;
            newTs = resample(ts, time);
        end
        function [newTs] = retime_and_rotate_ts(traj, ts, inc, RM, vector)
            newTs = traj.changeTimeIncrement(ts, inc);
            newTs = traj.rotate_in_place(newTs, RM, vector);
        end
    end  
end

