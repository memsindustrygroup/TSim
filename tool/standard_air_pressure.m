% Copyright (c) 2012, Freescale Semiconductor
function [ P ] = standard_air_pressure( time, position, temperature, altitude )
% Calculate pressure based on standard equations from NASA: 
% "U.S. Standard Atmosphere, 1976".
% Position is of form [X; Y; Z] in meters.
% Temperature is in Celcius
% Altitude is differential between vertical=0 and sea level.
% Time is not used by this version of the function, but is a required
% parameter for the template.
K_to_Celcius = 273.15;  % difference between degrees kelvin and Celcius

T = temperature + K_to_Celcius;
H = position(3)+altitude;
P0 = 101325; % Pascals
L = -6.5e-3; % K/M
C = -5.25588;  % C is a precalculated value for the fixed exponential value found in the NASA
               % equation.  It is calculated as [g0'M0/R*Lm,b]
P = P0*(T/(T+L*H))^C;
end

