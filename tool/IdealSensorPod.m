% Copyright (c) 2012, Freescale Semiconductor
classdef IdealSensorPod
    % Converts trajectory information into idealized sensor readings
    % This class assumes that sensors use same frame of reference as that
    % defined in the envionment instance.  Physical sensor models (which in
    % turn reference this class) can add additional frame of reference
    % rotations as appropriate.
    
    properties
        traj;   % trajectory
        env;    % environment
        P;      % Position time series
        V;      % Linear velocity time series
        A;      % Linear acceleration seen from the sensor's perspective
        TA;     % Linear acceleration from global perspective
        O;      % Orientation time series
        AV;     % Angular velocity seen from the sensor's perspective
        M;      % Magnetic vector seen from the sensor's perspective
        AP;     % Air pressure as function of other variables
        T;      % Temperature
        G;      % acceleration due to gravity only
    end
    properties (SetAccess = private)
        ts;     % Sample interval
    end

    methods
        function [isp] = IdealSensorPod(environment, trajectory, ts)
            isp.traj = trajectory;
            isp.env  = environment;
            isp.ts   = ts;
            isp.O    = isp.traj.changeTimeIncrement(isp.traj.O, isp.ts);
            isp.AV   = isp.traj.changeTimeIncrement(isp.traj.AV, isp.ts);
            isp.P    = isp.traj.changeTimeIncrement(isp.traj.P, isp.ts);
            isp.V    = isp.traj.changeTimeIncrement(isp.traj.V, isp.ts);
            isp.A    = isp.traj.changeTimeIncrement(isp.traj.A, isp.ts);
            isp.TA   = isp.A;
            rf = isp.env.rf;
            [r, c] = size(isp.O.Data);
            time = isp.O.Time;
            for i=1:r
                currentTime = time(i);
                position = isp.P.Data(i,:)';
                temperature = isp.env.get_temperature(currentTime, position);
                orientation_quaternion = isp.O.Data(i,:)';
                RM = RM_from_quaternion(orientation_quaternion);
                isp.A.Data(i,:)  = (RM * (isp.A.Data(i,:)'+isp.env.AccelAtRest))/Env.magG;                
                isp.TA.Data(i,:) = isp.TA.Data(i,:)/Env.magG;  % This is TRUE acceleration in global frame
                isp.AV.Data(i,:) = (RM * isp.AV.Data(i,:)');
                localM = isp.env.get_magnetic_vector(currentTime, position, temperature); % now in microTeslas
                G(i,:) = RM*isp.env.AccelAtRest/(Env.magG);
                M(i,:) = RM*localM;
                AP(i,1) = isp.env.get_air_pressure(currentTime, position, temperature, isp.env.altitude);
                T(i,1) = temperature;
            end
            if ((isp.env.rf==Env.NED)||(isp.env.rf==Env.Win8))
                % convert acceleration plots to gravity standard
                isp.A.Data = -isp.A.Data;
                isp.TA.Data = -isp.TA.Data;
            end
            isp.M = timeseries(M, time);
            isp.AP = timeseries(AP, time);
            isp.T  = timeseries(T, time);
            isp.G  = timeseries(G, time);
            
            isp.T.Name='Temperature';
            isp.M.Name='Magnetic Field';
            isp.AP.Name='Air Pressure';
            isp.G.Name='Acceleration Due to Gravity';

            isp.A.DataInfo.Units='gravities';
            isp.TA.DataInfo.Units='gravities';
            isp.G.DataInfo.Units='gravities';
            isp.M.DataInfo.Units='microTeslas';
            isp.AP.DataInfo.Units='Pascals';
            isp.T.DataInfo.Units='Celcius';
            
            isp.A  = labelPoints(isp.traj.RAWPT, isp.A);
            isp.G  = labelPoints(isp.traj.RAWPT, isp.G);
            isp.TA  = labelPoints(isp.traj.RAWPT, isp.TA);
            isp.AV = labelPoints(isp.traj.RAWPT, isp.AV);
            isp.M  = labelPoints(isp.traj.RAWPT, isp.M);
            isp.AP = labelPoints(isp.traj.RAWPT, isp.AP);
            isp.T  = labelPoints(isp.traj.RAWPT, isp.T);

        end
        function [sampleCount] = get_sample_count(isp)
            [sampleCount, c] = size(isp.O.Data);
        end
        function [] = data_dump(isp, dirName)
            % dirName = output directory name
            if ((7==exist(dirName)) || mkdir(dirName))
                var=isp.O.Time(:)     ; save(fullfile(dirName,'TRUE_time.dat'), '-ascii', 'var');
                var=isp.M.Data(:,1:3) ; save(fullfile(dirName,'magnetometer.dat'), '-ascii', 'var');
                var=isp.A.Data(:,1:3) ; save(fullfile(dirName,'accelerometer.dat'), '-ascii', 'var');
                var=isp.AV.Data(:,1:3); save(fullfile(dirName,'gyro.dat'), '-ascii', 'var');
                var=isp.TA.Data(:,1:3) ; save(fullfile(dirName,'TRUE_accelerometer.dat'), '-ascii', 'var');
                var=isp.AP.Data(:)    ; save(fullfile(dirName,'TRUE_air_pressure.dat'), '-ascii', 'var');
                var=isp.T.Data(:)     ; save(fullfile(dirName,'TRUE_temperature.dat'), '-ascii', 'var');
                var=isp.O.Data(:,1:4) ; save(fullfile(dirName,'TRUE_quaternion.dat'), '-ascii', 'var');
                var=isp.P.Data(:,1:3) ; save(fullfile(dirName,'TRUE_position.dat'), '-ascii', 'var');
                var=isp.V.Data(:,1:3) ; save(fullfile(dirName,'TRUE_velocity.dat'), '-ascii', 'var');
                var=isp.G.Data(:,1:3) ; save(fullfile(dirName,'TRUE_gravity.dat'), '-ascii', 'var');
                [r,c] = size(isp.O.Data);
                for i=1:r
                    q = isp.O.Data(i,:);
                    rm  = RM_from_quaternion( q );
                    RM(i,1:3) = rm(1,1:3);
                    RM(i,4:6) = rm(2,1:3);
                    RM(i,7:9) = rm(3,1:3);
                end
                save(fullfile(dirName,'TRUE_rotations.dat'), '-ascii', 'RM');
                location=dbstack;
                fn = location(2).file;
                % save a copy of this file into the output
                copyfile(fn, dirName);
                load_script = strrep(mfilename('fullpath'),'IdealSensorPod', 'load_sensor_dataset.m');
                copyfile(load_script, dirName);
            end
        end
        
        function [] = plot_all(isp, dirName)
            % dirName is optional.  If supplied, plots will be saved as
            % jpegs into that directory.
            if (nargin==1)
                dirName='';
            end
            isp.plot_acceleration(dirName);
            isp.plot_gravity(dirName);
            isp.plot_angular_velocity(dirName);
            isp.plot_magnetic_field(dirName);
            isp.plot_air_pressure(dirName);
            isp.plot_temperature(dirName);
        end
        function [] = plot_acceleration(isp, dirName)
            if (nargin==1)
                dirName='';
            end
            figure;
            plot(isp.A);
            legend('Ax=dX^2', 'Ay=dY^2', 'Az=dZ^2');
            title('Sensor Plot: Acceleration Data');
            savePlot( dirName, 'accelerometer.jpg' );
        end
        function [] = plot_gravity(isp, dirName)
            if (nargin==1)
                dirName='';
            end
            figure;
            plot(isp.G);
            legend('Ax=dX^2', 'Ay=dY^2', 'Az=dZ^2');
            title('Sensor Plot: Acceleration due to Gravity');
            savePlot( dirName, 'gravity.jpg' );
        end
        function [] = plot_angular_velocity(isp, dirName)
            if (nargin==1)
                dirName='';
            end
            figure;
            plot(isp.AV);
            legend('X', 'Y', 'Z');
            title('Sensor Plot: Angular Velocity');
            savePlot( dirName, 'gyro.jpg' );
        end
        function [] = plot_magnetic_field(isp, dirName)
            if (nargin==1)
                dirName='';
            end
            figure;
            plot(isp.M);
            legend('X', 'Y', 'Z');
            title('Sensor Plot: Magnetic Field in microTeslas');
            savePlot( dirName, 'magnetometer.jpg' );
        end
        function [] = plot_temperature(isp, dirName)
            if (nargin==1)
                dirName='';
            end
            figure;
            plot(isp.T);
            title('Sensor Plot: Temperature in C');
            savePlot( dirName, 'temperature.jpg' );
        end
        function [] = plot_air_pressure(isp, dirName)
            if (nargin==1)
                dirName='';
            end
            figure;
            plot(isp.AP);
            title('Sensor Plot: Air Pressure in Pascals');
            savePlot( dirName, 'air_pressure.jpg' );
        end

    end
    methods (Access=private)
        % These may get optimized/replaced with time
    end
end

