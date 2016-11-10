% © 2012-2016 NXP Semiconductor N.V..  All rights reserved.
% SPDX-License-Identifier: BSD-3-Clause
% The BSD 3-clause license for this file can be found in the license.pdf file included with this 
% distribution or at https://spdx.org/licenses/BSD-3-Clause.html

classdef ExampleSensorPod < IdealSensorPod & PhysicalSensorPodInterface
    % This class provides the ability to "corrupt" sensor outputs
    
    properties
        a;     % accelerometer model
        g;     % gyro model
        m;     % magnetometer model
        t;     % temperature model
        ap;    % air pressure model
        OPD;   % Total gyro drift over time (Nx3)

        accelerometer_range = 4;    % +/-8 g's
        accelerometer_NB = 14;       % 14 bits ADC resolution for accelerometer
        accelerometer_gaussian_noise = [100e-6;100e-6;100e-6]; % units are g's
        accelerometer_random_walk = [0;0;0];
        acc_rw_tau = 100;           % seconds
        % for acceleration, let's assume we've calibrated the offset
        accelerometer_offset = randn(3,1).*[.001; .001; .001]; % units are in g
        %accelerometer_offset = [0; 0; 0]; % units are in g
        
        gyro_range = 2000 * pi / 180;  % 2000dps = 34.907 radians/sec
        gyro_NB = 16;               % 14 bits ADC resolution for gyro
        gyro_gaussian_noise = (pi/180)*[0.025;0.025;0.025]; % units are radians/sec
        %gyro_random_walk = (pi/180)*[0.4; 0.4; 0.4];     % in (rad/s)/min;        
        gyro_random_walk = [0; 0; 0];     % in (rad/s)/min;        
        gyro_rw_tau = 60;          % seconds
        % gyro sensitivity modeled at 62.5 mdps/LSB
        gyro_offset = 15*.0625*(pi/180)*randn(3,1).*[1; 1; 1]; % units are in rad/s
        
        mag_range = 1200;           % +/- 1000 microTeslas
        mag_NB = 16;
        mag_gaussian_noise = [0.085;0.085;0.13]; % units are microTeslas
        mag_random_walk = [0;0;0];
        mag_rw_tau = 100;           % seconds
        mag_offset = [0; 0; 0]; % units are in microTeslas
        mag_gain = [1; 1; 1];
        
        t_range = 200;              % +/- 150C
        t_NB = 12;
        t_gaussian_noise = 0;       % Celcius
        t_random_walk = 0;
        t_rw_tau = 100;             % seconds
        
        ap_range = 131072;          % +/- 2^17 pascals
        ap_NB = 16;
        ap_gaussian_noise = 0;      % Celcius
        ap_random_walk = 0;
        ap_rw_tau = 20;             % seconds
    end
    
    methods
        function [psp] = ExampleSensorPod(environment, trajectory, ts, dirName)
            psp = psp@IdealSensorPod(environment, trajectory, ts);
            if (nargin<4)
                psp.a = three_axis_sensor_model_1(   'Accel',    psp.accelerometer_range, psp.accelerometer_NB, ts);
                psp.g = three_axis_sensor_model_1(   'Gyro',     psp.gyro_range         , psp.gyro_NB,          ts);
                psp.m = three_axis_sensor_model_1(   'Mag',      psp.mag_range          , psp.mag_NB,           ts);
                psp.t = single_axis_sensor_model_2(  'Temp',     psp.t_range            , psp.t_NB,             ts);
                psp.ap = single_axis_sensor_model_2( 'Pressure', psp.ap_range           , psp.ap_NB,            ts);
            else
                psp = psp.restore(dirName);
            end
        end
        function [psp] = save(psp, dirName)
            [s, mess, messid] = mkdir(dirName);
            delete(strcat(dirName, '\*.*'));
            o = psp.a; save([dirName, '/accel.mat'], 'o');
            o = psp.m; save([dirName, '/mag.mat'], 'o');
            o = psp.g; save([dirName, '/gyro.mat'], 'o');
            o = psp.t; save([dirName, '/tempSensor.mat'], 'o');
            o = psp.ap; save([dirName, '/pressureSensor.mat'], 'o');
        end
        function [psp] = restore(psp, dirName)
            load([dirName, '/accel.mat'], 'o'); psp.a=o;
            load([dirName, '/mag.mat'], 'o'); psp.m=o;
            load([dirName, '/gyro.mat'], 'o'); psp.g=o;
            load([dirName, '/tempSensor.mat'], 'o'); psp.t=o;
            load([dirName, '/pressureSensor.mat'], 'o'); psp.ap=o;
        end
        function [sz] = num_points(psp)
                        [sz,c] = size(psp.A.Data);
        end
        function [time] = get_time(psp)
               time = psp.A.Time;
        end
        function [psp] = initialize_models(psp)
            psp.a  = psp.a.clear_random_walk();
            psp.g  = psp.g.clear_random_walk();
            psp.m  = psp.m.clear_random_walk();
            psp.t  = psp.t.clear_random_walk();
            psp.ap = psp.ap.clear_random_walk();

            psp.a = psp.a.set_offset(psp.accelerometer_offset);
            psp.a = psp.a.set_noise_density(psp.accelerometer_gaussian_noise);
            psp.a = psp.a.set_random_walk(psp.accelerometer_random_walk, psp.acc_rw_tau);

            psp.g = psp.g.set_offset(psp.gyro_offset);
            psp.g = psp.g.set_noise_density(psp.gyro_gaussian_noise);
            psp.g = psp.g.set_random_walk(psp.gyro_random_walk, psp.gyro_rw_tau);
            
            psp.m = psp.m.set_offset(psp.mag_offset);
            psp.m = psp.m.set_noise_density(psp.mag_gaussian_noise);
            psp.m = psp.m.set_random_walk(psp.mag_random_walk, psp.mag_rw_tau);
            psp.m = psp.m.set_gain(psp.mag_gain);

            psp.t = psp.t.set_noise_density(psp.t_gaussian_noise);
            psp.t = psp.t.set_random_walk(psp.t_random_walk, psp.t_rw_tau);

            psp.ap = psp.ap.set_noise_density(psp.ap_gaussian_noise);
            psp.ap = psp.ap.set_random_walk(psp.ap_random_walk, psp.ap_rw_tau);
        end
        function [a, m, av, t, ap, opd] = get_samples(psp, i)
            zero = zeros(3,1);
            temperature = psp.T.Data(i);
            time = psp.A.Time(i);
            [a, ~]    = psp.a.corrupt(temperature, time, psp.A.Data(i,:)', zero);
            [m, ~]    = psp.m.corrupt(temperature, time, psp.M.Data(i,:)', zero);
            [av, opd] = psp.g.corrupt(temperature, time, psp.AV.Data(i,:)', zero);            
            t         = psp.t.corrupt(temperature, time, psp.T.Data(i)');            
            ap        = psp.ap.corrupt(temperature, time, psp.AP.Data(i)');            
        end
        function [a] = get_acc_sample(psp, i)
            zero = zeros(3,1);
            temperature = psp.T.Data(i);
            time = psp.A.Time(i);
            [a, ~] = psp.a.corrupt(temperature, time, psp.A.Data(i,:)', zero);
        end
        function [m] = get_mag_sample(psp, i)
            zero = zeros(3,1);
            temperature = psp.T.Data(i);
            time = psp.A.Time(i);
            [m, ~] = psp.m.corrupt(temperature, time, psp.M.Data(i,:)', zero);
        end
        function [g] = get_gyro_sample(psp, i)
            zero = zeros(3,1);
            temperature = psp.T.Data(i);
            time = psp.A.Time(i);
            [g, ~] = psp.g.corrupt(temperature, time, psp.AV.Data(i,:)', zero);
        end
        function [t] = get_temperature_sample(psp, i)
            zero = zeros(3,1);
            temperature = psp.T.Data(i);
            time = psp.A.Time(i);
            t = psp.t.corrupt(temperature, time, psp.T.Data(i,:)');
        end
        function [ap] = get_air_pressure_sample(psp, i)
            zero = zeros(3,1);
            temperature = psp.T.Data(i);
            time = psp.A.Time(i);
            ap = psp.ap.corrupt(temperature, time, psp.AP.Data(i,:)');
        end
        function [psp] = corrupt(psp)
            %[r,c] = size(psp.A.Data);
            for i=1:psp.num_points()
                [a, m, av, t, ap, opd] = get_samples(psp, i);
                psp.A.Data(i,:)  = a';
                psp.M.Data(i,:)  = m';
                psp.AV.Data(i,:) = av';
                psp.T.Data(i,1)  = t;
                psp.AP.Data(i,1) = ap;
                psp.OPD(i,:) = opd;
            end %for
        end % function
        function [] = plot_gyro_offsetPlusDrift(psp, dirName)
            if (nargin==1)
                dirName='';
            end
            ax1 = figure;
            subplot(3,1,1);
            ts = psp.A;
            ts.data = (180/pi)*psp.OPD;
            plot(ts.Time, ts.Data(:,1));
            grid on;
            title('Sensor Plot: Gyro X offset + total drift');
            xlabel('Time in seconds');
            ylabel('degrees/second');
            subplot(3,1,2);
            plot(ts.Time, ts.Data(:,2));
            grid on;
            title('Sensor Plot: Gyro Y offset + total drift');
            xlabel('Time in seconds');
            ylabel('degrees/second');
            subplot(3,1,3);
            plot(ts.Time, ts.Data(:,3));
            grid on;
            title('Sensor Plot: Gyro Z offset + total drift');
            xlabel('Time in seconds');
            ylabel('degrees/second');

            fn = fullfile(dirName, '3-0_OPD');
            process_plot(ax1, fn);

            ax2 = figure;
            subplot(3,1,1);
            histogram(ts.data(:,1), 128);
            grid on;
            title('Sensor Plot: Gyro X axis offset + total drift histogram');
            xlabel('degrees/second');
            ylabel('counts');
            
            subplot(3,1,2);
            histogram(ts.data(:,2), 128);
            grid on;
            title('Sensor Plot: Gyro Y axis offset + total drift histogram');
            xlabel('degrees/second');
            ylabel('counts');
            
            subplot(3,1,3);
            histogram(ts.data(:,3), 128);
            grid on;
            title('Sensor Plot: Gyro Z axis offset + total drift histogram');
            xlabel('degrees/second');
            ylabel('counts');  
            
            fn = fullfile(dirName, '3-1_OPD_histogram');
            process_plot(ax2, fn);
        end
        function [] = report(psp, fn, topscript, mode)
            fid = fopen(fn, mode);
            if (fid==-1)
                printf('Error, could not open %s\n', fn);
                return;
            else
                fprintf(fid, '----------------------------------------------------\n');
                fprintf(fid, 'TSIM Model Snapshot\n');
                fprintf(fid, 'Top level script: %s\n', topscript);
                fprintf(fid, 'Useful constants: \n')
                fprintf(fid, '* %f = degrees/radian\n', 180/pi);
                fprintf(fid, '* %f = radians/degree\n', pi/180);
                fprintf(fid, '* 1 Gauss = 100 microTeslas\n');
                fclose(fid);
            end
            psp.env.report(fn, 'a');
            psp.a.report(fn, 'a', 'Accelerometer Model:', 'gravities');
            psp.g.report(fn, 'a', 'Gyroscope Model:', 'degrees/second');
            psp.m.report(fn, 'a', 'Magnetometer Model:', 'microTeslas');
        end
    end % methods
    
end %class

