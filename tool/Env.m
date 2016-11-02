% Copyright (c) 2012, Freescale Semiconductor
classdef Env
    % Class definition for sensor environment
    
    properties
        rf;                     % Should be one of Env.NED, Env.Win8 or Env.Android
        gravity;                % 3X1 zero-rotation gravity vector in m/s^2
        altitude;               % Altitude (in meters) at vertical = 0;
        magnetic_calculator;    % 3X1 magnetic vector OR handle to function of form [V = f([X; Y; Z]);
                                % Magnetic values are in microTeslas
        pressure_calculator;    % handle to function of form [V = f([X; Y; Z], temperature_in_C);
                                % Pressure is in Pascals
        temperature_calculator; % Temperature (in C) as a function of time in seconds, or a constant T
    end
    
    properties (Constant)
        NED = 1;                % X = North, Y = East,  Z = Down
        Win8 = 4;
        Android = 8;
        magG=9.80665;           % meters/sec^2
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
                % Assuming the sensor pod is aligned with the global frame,
                % we need to define our reference vectors
                switch env.rf
                    case Env.NED
                        env.magnetic_calculator = [24.2976; 0; 41.3285]; % Magnetic North Frame of Reference: X=North, Y=East, Z=Down, in microTeslas
                        env.gravity = [0; 0; -magG];  % gravity/accel standard
                    case Env.Win8
                        env.magnetic_calculator = [0; 24.2976; -41.3285]; % Magnetic North Frame of Reference: X=East, Y=North, Z=Up, in microTeslas
                        env.gravity = [0; 0; +magG]; % gravity/accel standard
                   case Env.Android
                        env.magnetic_calculator = [0; 24.2976; -41.3285]; % Magnetic North Frame of Reference: X=East, Y=North, Z=Up, in microTeslas
                        env.gravity = [0; 0; +magG];  % accel/gravity standard
                   otherwise
                        error('Supplied frame of reference must be one of: Env.NED, Env.Win8 or Env.Android.\n');
                end
            else
                env.gravity = varargin{2};
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
            if (isa(env.gravity, 'double'))
                [r, c] = size(env.gravity);
                if ((r==3)&&(c==1))
                    fprintf('Environment initialized with constant gravity vector: %f, %f, %f.\n', env.gravity(1), env.gravity(2), env.gravity(3));
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
        function [env] = install_magnetic_calculator(env, MC)
            env.magnetic_calculator = MC;
            if (isa(env.magnetic_calculator, 'function_handle'))
                fprintf('Environment re-initialized with magnetic function handle - OK.\n');
            else
                error('Supplied magnetic function must be 3x1 double OR Matlab function handle.\n');
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
        function [] = report(env, fn, mode)
            % env = self pointer
            % fn = filename to write to
            % mode = 'w' or 'w+'
            fid = fopen(fn, mode);
            if (fid==-1)
                printf('Error, could not open %s\n', fn);
                return;
            else
                fprintf(fid, '----------------------------------------------------\n');
                fprintf(fid, 'TSIM Simulation Environment:\n');
                switch env.rf
                    case env.NED
                        fprintf(fid, '* Frame of Reference: NED\n');
                    case env.Win8
                        fprintf(fid, '* Frame of Reference: Win8\n');
                    case env.Android
                        fprintf(fid, '* Frame of Reference: Android\n');
                    otherwise
                        fprintf(fid, '* Frame of Reference: Uknown\n');
                end % switch  
                
                fprintf(fid, '* Accelerometer output at rest in m/s^2: [%f %f %f]\n', ...
                    env.gravity(1), env.gravity(2), env.gravity(3));
                
                fprintf(fid, '* Altitude at (vertical=0): %6.1f meters\n', env.altitude);
                
                [r, c] = size(env.temperature_calculator);
                if (isa(env.temperature_calculator, 'function_handle'))
                    str = func2str(env.temperature_calculator);
                    fprintf(fid, '* Temperature is modeled as %s(time, position)\n', str);
                elseif ((r==1)&&(c==1))
                    T = env.temperature_calculator;
                    fprintf(fid, '* Temperature is modeled as constant: %4.1f C\n', T);
                end
                
                [r, c] = size(env.pressure_calculator);
                if (isa(env.pressure_calculator, 'function_handle'))
                    str = func2str(env.pressure_calculator);
                    fprintf(fid, '* Pressure is modeled as %s(time, position, temperature, altitude)\n', str);
                elseif ((r==1)&&(c==1))
                    P = env.pressure_calculator;
                    fprintf(fid, '* Pressure is modeled as constant: %f Pascals\n', P);
                end
                [r, c] = size(env.magnetic_calculator);
                if ((r==3)&&(c==1))
                fprintf(fid, '* The ambient magnetic field is modeled as a constant: [%f %f %f] microTeslas\n', ...
                    env.magnetic_calculator(1), ...
                    env.magnetic_calculator(2), ...
                    env.magnetic_calculator(3));
                fprintf(fid, '* The magnitide of that field is %f\n', norm(env.magnetic_calculator));
                elseif (isa(env.magnetic_calculator, 'function_handle'))
                    str = func2str(env.magnetic_calculator);
                    fprintf(fid, '* The ambient magnetic field is modeled as %s(time, position, temperature)\n', str);
                end
                fclose(fid);
            end % else 
        end % function
    end % methods
end % classdef

