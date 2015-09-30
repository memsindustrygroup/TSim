function [ output_args ] = testDeadZone( input_args )
    %UNTITLED2 Summary of this function goes here
    %   Detailed explanation goes here
    close all;
    gamma = 0.015;
    p=pi();
    inc=2*p/5000;
    i=1;
    for trueAngle=-p:inc:p-inc;
        x(i) = cos(trueAngle);
        y(i) = sin(trueAngle);
        xdz(i) = modifyForDeadZone(x(i)+noise(), gamma);
        ydz(i) = modifyForDeadZone(y(i)+noise(), gamma);
        adz(i) = atan2(ydz(i), xdz(i));
        error1(i) = trueAngle - adz(i);
        ideal1(i) = trueAngle;
        i=i+1;
    end
    plot(ideal1, error1, 'k');
    hold on;
    
    inc=2*p/72;
    i=1;
    for trueAngle=-p:inc:p-inc;
        x(i) = cos(trueAngle);
        y(i) = sin(trueAngle);
        xdz(i) = modifyForDeadZone(x(i)+noise(), gamma);
        ydz(i) = modifyForDeadZone(y(i)+noise(), gamma);
        adz(i) = atan2(ydz(i), xdz(i));
        error2(i) = trueAngle - adz(i);
        ideal2(i) = trueAngle;
        i=i+1;
    end
    plot(ideal2, error2, 'b');
    hold on;

    i=1;
    inc=2*p/24;
    for trueAngle=-p:inc:p-inc;
        x(i) = cos(trueAngle);
        y(i) = sin(trueAngle);
        xdz(i) = modifyForDeadZone(x(i)+noise(), gamma);
        ydz(i) = modifyForDeadZone(y(i)+noise(), gamma);
        adz(i) = atan2(ydz(i), xdz(i));
        error3(i) = trueAngle - adz(i);
        ideal3(i) = trueAngle;
        i=i+1;
    end
    plot(ideal3, error3, '-r');
end

function [xx] = fix_overflow(x)
    p=pi();    
    if (x>2*p)
        xx=x-2*pi;
    elseif (x<-2*p)
        xx=x+2*p;
    else
        xx=x;
    end    
end

function [n] = noise()
    n = 0.0014*2*(rand-0.5);
end

