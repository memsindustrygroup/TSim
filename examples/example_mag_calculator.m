function [ M ] = example_mag_calculator( t, position, temperature)
% x=position(1);
% y=position(2);
% z=position(3);
Mref = [24.34777; 0; +41.47411]; % Magnetic North Frame of Reference: X=North, Y=East, Z=Down, in microTeslas

if ((t>=5)&&(t<15))
    X = 50+50*cos(2*pi()*0.1*(t-10));
else
    X = 0;
end
if ((t>=8)&&(t<20))
    Y = -25-25*cos(2*pi()*0.08*(t-14.25));
else
    Y = 0;
end
if ((t>=16)&&(t<24))
    Z = 12.5+12.5*cos(2*pi*0.125*(t-20));
else
    Z = 0;
end
M = [X;Y;Z] + Mref;
end

