% Copyright (c) 2012, Freescale Semiconductor
classdef Env
    % Class definition for sensor environment
    
    properties
        rf;                     % Should be one of Env.NED, Env.ENU, Env.Win8 or Env.Android
        AccelAtRest;            % 3X1 zero-rotation physical accelometer output vector in m/s^2
        altitude;               % Altitude (in meters) at vertical = 0;
        magnetic_calculator;    % 3X1 magnetic vector OR handle to function of form [V = f([X; Y; Z]);
                                % Magnetic values are in microTeslas
        pressure_calculator;    % handle to function of form [V = f([X; Y; Z], temperature_in_C);
                                % Pressure is in Pascals
        temperature_calculator; % Temperature (in C) as a function of time in seconds, or a constant T
    end
    
    properties (Constant)
        NED = 1;                % X = North, Y = East,  Z = Down
        ENU = 2;                % X = East,  Y = North, Z = Up
        Win8 = 4;
        Android = 8;
        magG=9.80665;          % meters/sec^2
    end
    
    methods
        
        function [env] = Env(varargin)
            % varargin is only 1 parameter, it is: RF
            % if varargin has 6 values, it is: RF, Gref, altitude, MC, PC, TC
            magG=9.80665;          % meters/sec^2
            env.rf = varargin{1};
            if (nargin==1)
                env.altitude = 400;                  % value in meters
                env.temperature_calculator = 25;     % Celcius
                env.pressure_calculator = @standard_air_pressure;
                if (env.rf==Env.NED)
                    env.magnetic_calculator = [24.34777; 0; 41.47411]; % Magnetic North Frame of Reference: X=North, Y=East, Z=Down, in microTeslas
                    env.AccelAtRest = [0; 0; -magG];          % +Z is down
                elseif (env.rf==Env.Win8)||(env.rf==Env.Android)||(env.rf==Env.ENU)
                    env.magnetic_calculator = [0; 24.34777; -41.47411]; % Magnetic North Frame of Reference: X=East, Y=North, Z=Up, in microTeslas
                    env.AccelAtRest = [0; 0; magG];            % +Z is up
                else
                    error('Supplied frame of reference must be one of: Env.NED, Env.ENU, Env.Win8 or Env.Android.\n');
                end
            else
                env.AccelAtRest = varargin{2};
                env.altitude = varargin{3};
                env.magnetic_calculator = varargin{4};
                env.pressure_calculator = varargin{5};
                env.temperature_calculator = varargin{6};
            end
            % Now let's check that we got the sensible values
            if (isa(env.magnetic_calculator, 'double'))
                [r, c] = size(env.magnetic_calculator);
                if ((r==3)&&(c==1))
                    fprintf('Environment initialized with constant magnetic vector: %f, %f, %f.\n' , env.magnetic_calculator(1), env.magnetic_calculator(2), env.magnetic_calculator(3));
                end
            elseif (isa(env.magnetic_calculator, 'function_handle'))
                fprintf('Environment initialized with magnetic function handle - OK.\n');
            else
                error('Supplied magnetic function must be 3x1 double OR Matlab function handle.\n');
            end
            if (isa(env.AccelAtRest, 'double'))
                [r, c] = size(env.AccelAtRest);
                if ((r==3)&&(c==1))
                    fprintf('Environment initialized with constant gravity vector: %f, %f, %f.\n', env.AccelAtRest(1), env.AccelAtRest(2), env.AccelAtRest(3));
                else
                    error('Supplied gravity vector must be 3x1 double.\n');
                end
            else
                error('Supplied gravity vector must be 3x1 double.\n');
            end
            if (isa(env.pressure_calculator, 'double'))
                [r, c] = size(env.pressure_calculator);
                if ((r==1)&&(c==1))
                    fprintf('Environment initialized with constant air pressure value: %f.\n', env.pressure_calculator);
                end
            elseif (isa(env.pressure_calculator, 'function_handle'))
                fprintf('Environment initialized with pressure function handle - OK.\n');
            else
                error('Supplied air pressure function must be 1x1 double OR Matlab function handle.\n');
            end
            if (isa(env.temperature_calculator, 'double'))
                [r, c] = size(env.temperature_calculator);
                if ((r==1)&&(c==1))
                    fprintf('Environment initialized with constant temperature value: %f.\n', env.temperature_calculator);
                end
            elseif (isa(env.temperature_calculator, 'function_handle'))
                fprintf('Environment initialized with temperature function handle - OK.\n');
            else
                error('Supplied temperature function must be 1x1 double OR Matlab function handle.\n');
            end
        end
        function [M] = get_magnetic_vector(env, time, position, temperature)
                % time is in seconds
                % position should be of form [X; Y; Z]
                [r, c] = size(env.magnetic_calculator);
                if ((r==3)&&(c==1))
                    M = env.magnetic_calculator;
                elseif (isa(env.magnetic_calculator, 'function_handle'))
                    M = env.magnetic_calculator(time, position, temperature);
                else
                    error('Supplied magnetic function must be 3X1 vector (X, Y & Z Teslas) OR Matlab function handle.\n');
                end
        end
        function [P] = get_air_pressure(env, time, position, temperature, altitude)
                % position should be of form [X; Y; Z]
                [r, c] = size(env.pressure_calculator);
                if (isa(env.pressure_calculator, 'function_handle'))
                    P = env.pressure_calculator(time, position, temperature, altitude);
                elseif ((r==1)&&(c==1))
                    P = env.pressure_calculator;
                else
                    error('Supplied pressure function must be 1X1 value (in Pascals) OR Matlab function handle.\n');
                end
        end
        function [T] = get_temperature(env, time, position)
                % position should be of form [X; Y; Z]
                [r, c] = size(env.temperature_calculator);
                if (isa(env.temperature_calculator, 'function_handle'))
                    T = env.temperature_calculator(position);
                elseif ((r==1)&&(c==1))
                    T = env.temperature_calculator;
                else
                    error('Supplied temperature function must be 1X1 value (in C) OR Matlab function handle.\n');
                end
        end
    end 
end

