% © 2012-2016 NXP Semiconductor N.V..  All rights reserved.
% SPDX-License-Identifier: BSD-3-Clause
% The BSD 3-clause license for this file can be found in the license.pdf file included with this 
% distribution or at https://spdx.org/licenses/BSD-3-Clause.html

classdef single_axis_sensor_model_2
    % 1-Axis sensor model
    % This model is an adaptation the IEEE 1431-2004 gyro
    % model.  It is general enough to be used for accelerometers and magnetometers
    % (although not all terms apply across the board).  I prefer the form of
    % these equations over that suggested by IEEE 1293-1998 for accelerometers.
    
    properties (SetAccess = 'public')
        type = '';      % string identifier for this sensor type
        range = 2;      % +/- sensor range, in whatever units apply
        NB = 12;        % Number of bits resolution for the sensor
        ND = 0.0;       % Noise density in: micro-gs/root hertz
        %                 micro-radians/root hertz
        %                 micro-teslas/root hertz
        DRN = 0;        % Random Drift = ND * sqrt(BW)
        DRB = 0;        % Random Drift attributable to Bias
        DRK = 0;        % Random Drift rate attributable to Rate Random Walk
        DRR = 0;        % Random Drift attributable to ramp
        DT  = 0;        % DT*deltaT = Drift rate attributable to change in temperature
        %                 deltaT = (T-25);
        Da = 0;         % Da*a = drift rate due to accelerations.  This is expressed in
        %                 gyro terms, but parameter and input can be reused
        %                 for other sensor types.
        O = 0;          % zero rate offset values
        G = 1;          % gain matrix for the bulk model
        EPSt = 0;       % scale factor temperature sensitivity coefficient in units of 1e-6/C
    end
    properties (SetAccess = 'private')
        DRK_input = 0;
        % This is the input to the rate random walk integrator.  It
        % is derived from DRK and initialized using
        % set_noise_density().
        Ts=0.01;
        Fs=100;
        BW = 50;       % Bandwidth in hertz.  Need ODRX2 for BW.
        Tau = 100;
        resolution= 4/2^12;
    end  
    methods
        function s = single_axis_sensor_model_2(type, range, NB, Ts)
            % range = upper edge of input range (ex: "2" for +/-2 g)
            % NB = number of bits resolution
            if nargin > 0
                s.type   = type;
                s.range  = range;
                s.NB     = NB;
                s.Fs     = 1/Ts;
                s.BW     = s.Fs/2;
                s.Ts     = Ts;
                s.resolution = 2*range/2^NB;
            end
        end
        function s = set_noise_density(s, ND)
            % ND = 3x1 vector of noise density numbers
            % BW = system bandwidth in Hertz
            s.ND = ND;
            s.DRN = ND*sqrt(s.BW);
        end
        function s = clear_random_walk(s)
            s.DRK = 0;
        end
        function s = set_random_walk(s, DRK, tau)
            % DRK = 3x1 vector of desired rate random walk std deviations
            % Ts = sample rate in sections
            s.DRK = DRK;
            s.DRK_input = sqrt(2*DRK^2/(s.Ts*tau)); 
            s.Tau = tau;
        end
        function s = add_scale_factor(s, S)
            s.G = S*s.G;
        end
        function [signalOut] = corrupt(s, temperature, time, signalIn)
            % Bulk Model
            B = s.G*signalIn + s.O;
            % Drift Model
            % First calculate drift due to rate random walk
            if (s.DRK_input>0)
                wk = s.DRK_input.*randn;
                s.DRK = s.Ts*wk + s.DRK - (s.Ts/s.Tau)*s.DRK;
            else
                s.DRK=0;
            end
            if (s.DRR>0)
                DRR = s.DRR * time;         % Random drift attributable to ramp
            else
                DRR = 0;
            end
            if (s.DRN>0)
                DRN = s.DRN .* randn;       % Random drift attributable to angle random walk
            else
                DRN = 0;
            end
            if (s.DRB>0)
                DRB = s.DRB .* randn;       % Random drift attributable to bias
            else
                DRB = 0;
            end
            DtDT = s.DT*(temperature-25); % Random drift attributable to temperature
            D = s.DRK + DRR + DRN + DRB + DtDT;  % total drift
            scale_factor = 1 + (temperature-25)*(1e-6)*s.EPSt; % scale factor model
            continuous_output = (B+D).*scale_factor;
            % Now let's throw in effects of quantizing
            continuous_output = clamp(continuous_output, s.range);
            signalOut = s.resolution*(round(continuous_output/s.resolution));
        end        
    end
    
end

