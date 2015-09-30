% Copyright (c) 2012, Freescale Semiconductor
classdef ExampleSensorPod < IdealSensorPod & PhysicalSensorPodInterface
    % This class provides the ability to "corrupt" sensor outputs
    
    properties
        a;     % accelerometer model
        g;     % gyro model
        m;     % magnetometer model
        t;     % temperature model
        ap;    % air pressure model
        
        accelerometer_range = 4;    % +/-8 g's
        accelerometer_NB = 14;       % 14 bits ADC resolution for accelerometer
        accelerometer_gaussian_noise = 0*[1;1;1]; % units are g's
        accelerometer_random_walk = 0*[1;1;1];
        acc_rw_tau = 100;           % seconds
        
        gyro_range = 3*pi;          % 1.5 RPM =  540 degrees/sec
        gyro_NB = 14;               % 14 bits ADC resolution for gyro
        gyro_gaussian_noise = 0*[1;1;1]; % units are radians/sec
        gyro_random_walk = 0*[1;1;1];        
        gyro_rw_tau = 100;          % seconds
        
        mag_range = 1000;           % +/- 1000 microTeslas
        mag_NB = 12;
        mag_gaussian_noise = 0*[1;1;1]; % units are microTeslas
        mag_random_walk = 0*[1;1;1];
        mag_rw_tau = 100;           % seconds

        t_range = 200;              % +/- 150C
        t_NB = 12;
        t_gaussian_noise = 0;     % Celcius
        t_random_walk = 0;
        t_rw_tau = 100;             % seconds
        
        ap_range = 131072;          % +/- 2^17 pascals
        ap_NB = 16;
        ap_gaussian_noise = 0;      % Celcius
        ap_random_walk = 0;
        ap_rw_tau = 20;             % seconds
    end
    
    methods
        function [psp] = ExampleSensorPod(environment, trajectory, ts)
            psp = psp@IdealSensorPod(environment, trajectory, ts);
            psp.a = three_axis_sensor_model_1(   psp.accelerometer_range, psp.accelerometer_NB, ts);
            psp.g = three_axis_sensor_model_1(   psp.gyro_range         , psp.gyro_NB,          ts);
            psp.m = three_axis_sensor_model_1(   psp.mag_range          , psp.mag_NB, ts);
            psp.t = single_axis_sensor_model_2(  psp.t_range            , psp.t_NB, ts);
            psp.ap = single_axis_sensor_model_2( psp.ap_range           , psp.ap_NB, ts);            
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
            psp.a = psp.a.set_noise_density(psp.accelerometer_gaussian_noise);
            psp.a = psp.a.set_random_walk(psp.accelerometer_random_walk, psp.acc_rw_tau);
            psp.g = psp.g.set_noise_density(psp.gyro_gaussian_noise);
            psp.g = psp.g.set_random_walk(psp.gyro_random_walk, psp.gyro_rw_tau);
            psp.m = psp.m.set_noise_density(psp.mag_gaussian_noise);
            psp.m = psp.m.set_random_walk(psp.mag_random_walk, psp.gyro_rw_tau);
            psp.t = psp.t.set_noise_density(psp.t_gaussian_noise);
            psp.t = psp.t.set_random_walk(psp.t_random_walk, psp.t_rw_tau);
            psp.ap = psp.ap.set_noise_density(psp.ap_gaussian_noise);
            psp.ap = psp.ap.set_random_walk(psp.ap_random_walk, psp.ap_rw_tau);
        end
        function [a, m, av, t, ap] = get_samples(psp, i)
            zero = zeros(3,1);
            temperature = psp.T.Data(i);
            time = psp.A.Time(i);
            a = psp.a.corrupt(temperature, time, psp.A.Data(i,:)', zero);
            m = psp.m.corrupt(temperature, time, psp.M.Data(i,:)', zero);
            av = psp.g.corrupt(temperature, time, psp.AV.Data(i,:)', zero);            
            t = psp.t.corrupt(temperature, time, psp.T.Data(i)');            
            ap = psp.ap.corrupt(temperature, time, psp.AP.Data(i)');            
        end
        function [a] = get_acc_sample(psp, i)
            zero = zeros(3,1);
            temperature = psp.T.Data(i);
            time = psp.A.Time(i);
            a = psp.a.corrupt(temperature, time, psp.A.Data(i,:)', zero);
        end
        function [m] = get_mag_sample(psp, i)
            zero = zeros(3,1);
            temperature = psp.T.Data(i);
            time = psp.A.Time(i);
            m = psp.m.corrupt(temperature, time, psp.M.Data(i,:)', zero);
        end
        function [g] = get_gyro_sample(psp, i)
            zero = zeros(3,1);
            temperature = psp.T.Data(i);
            time = psp.A.Time(i);
            g = psp.g.corrupt(temperature, time, psp.AV.Data(i,:)', zero);
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
            psp = psp.initialize_models();
            %[r,c] = size(psp.A.Data);
            for i=1:psp.num_points()
                [a, m, av, t, ap] = get_samples(psp, i);
                psp.A.Data(i,:) = a';
                psp.M.Data(i,:) = m';
                psp.AV.Data(i,:) = av';
                psp.T.Data(i,1) = t;
                psp.AP.Data(i,1) = ap;
            end
        end
    end
    
end

