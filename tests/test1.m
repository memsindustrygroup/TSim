function [ P ] = test1( input_args )
% This file contains code used simply to test Matlab features which might
% be utilized within TSim.   It has no intrinsic use to anyone other than
% the developer.
    close all;
    %      time   X     Y      Z
    data = [0,      0,  -2.0,  0.0;
            1,    0.5,  -1.5,  0.5;
            2,    1.5,  -1.0,  0.5;
            7,    2.0,   0.0, -1.0
            ];

    RP = timeseries(data(:,2:4), data(:,1));
    startTime=min(RP.Time);
    endTime=max(RP.Time);
    newTimePoints = startTime:0.1:endTime
    RP.Name = 'RawPosition';
    RP.DataInfo.Units='meters';
    
    myFuncHandle = @(new_time, time, data)...
               interp1(time, data, new_time,...
                       'spline');
    myInterpObj = tsdata.interpolation(myFuncHandle);
    RP = setinterpmethod(RP,myInterpObj);
    P = resample(RP, newTimePoints);
    [V] = mydifferentiate(P);  V.Name='Velocity';
    [A] = mydifferentiate(V);  A.Name='Acceleration';
    
    e1 = tsdata.event('interrupt', 5);
    e1.Units = 'seconds';
    RP = addevent(RP, e1);
    P = addevent(P, e1);
    V = addevent(V, e1);
    A = addevent(A, e1);
     
    plot(RP);
    title('Raw Position Input Data');
    legend('X', 'Y', 'Z');

    figure;
    plot(P);
    title('Position Data (cubic spline fit)');
    legend('X', 'Y', 'Z');
    
    figure;
    plot(V);
    legend('Vx=dX', 'Vy=dY', 'Vz=dZ');
    title('Velocity Data');

    figure;
    plot(A);
    legend('Ax=dX^2', 'Ay=dY^2', 'Az=dZ^2');
    title('Acceleration Data');
    
end

function [ts] = myMovingAve(ts)
    [r, c] = size(ts.data)
    for i=1:r
        if (i==1)||(i==r)
            newData(i,:)=ts.data(i,:);
        elseif (i==2)||(i==r-1)
            newData(i,:)=(ts.data(i-1,:)+3*ts.data(i,:)+ts.data(i+1,:))/5;
        else
            newData(i,:)=(ts.data(i-2,:)+ts.data(i-1,:)+ts.data(i,:)+ts.data(i+1,:)+ts.data(i+2,:))/5;
        end           
    end
    ts.data=newData;
end

function [newts] = mydifferentiate(ts)
    newts=ts;
    [r, c] = size(ts.Data)
    dT = (ts.Time(2)-ts.Time(1));
    dTtwo = 2*dT;
    for i=2:r-1
            deltaD = ts.Data(i-1,:)+ts.Data(i+1,:)
            newts.Data(i,:)=deltaD/dTtwo;
    end
    newts.Data(1,:) = (ts.Data(2,:)-ts.Data(1,:))/dT;
    newts.Data(r,:) = (ts.Data(r,:)-ts.Data(r-1,:))/dT;
end
