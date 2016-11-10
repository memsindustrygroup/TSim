% © 2012-2016 NXP Semiconductor N.V..  All rights reserved.
% SPDX-License-Identifier: BSD-3-Clause
% The BSD 3-clause license for this file can be found in the license.pdf file included with this 
% distribution or at https://spdx.org/licenses/BSD-3-Clause.html

classdef three_axis_sensor_model_1
    % 3-Axis sensor model.  See Section 9.6 of the TSIM manual.
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
        N = [0;0;0];    % Random Drift N = ND * sqrt(BW)
        B = [0;0;0];    % Random Drift B attributable to Bias Instability
        DRK = [0;0;0];  % Random Drift rate attributable to Rate Random Walk
        R = [0;0;0];    % Random Drift R attributable to ramp
        DT  = [0;0;0];  % DT*deltaT = Drift rate attributable to change in temperature
        %                 deltaT = (T-25);
        Da = zeros(3);  % Da*a = drift rate due to accelerations.  This is expressed in
        %                 gyro terms, but parameter and input can be reused
        %                 for other sensor types.
        O = [0;0;0];    % zero rate offset values
        G = [1,0,0;0,1,0;0,0,1];
        % gain matrix for the bulk model
        EPSt = [0;0;0]; % scale factor temperature sensitivity coefficient in units of 1e-6/C
    end
    properties (SetAccess = 'private')
        sigma_sub_omega = [0;0;0];
        % sigma_sub_omega is the input to the rate random walk integrator.  It
        % is derived from DRK and initialized using set_noise_density().
        Tau = [100;100;100];
        % The following are overwritten by the constructor
        Ts=0.01;        % Sampling interval
        Fs=100;         % Sampling Frequency
        BW=50;          % Bandwidth in hertz.  Need ODRX2 for BW.
        resolution = 4/2^12;
    end  
    methods
        function s = three_axis_sensor_model_1(type, range, NB, Ts)
            % range = upper edge of input range (ex: "2" for +/-2 g)
            % NB = number of bits resolution
            % Ts = sampling interval in seconds
            if nargin > 3
                s = s.set_range_and_resolution(range, NB);
                s.type = type;
                s.Fs     = 1/Ts;    % Compute sampling frequency
                s.BW     = s.Fs/2;  % Compute bandwidth
                s.Ts     = Ts;      % Save sampling interval
            end
        end
        function s = set_range_and_resolution(s, range, NB)
                % range = +/- sensor input range
                % NB = number of bits in the ADC
                s.NB     = NB;
                s.range  = range;
                s.resolution = 2*range/2^NB;
        end
        function s = set_noise_density(s, ND)
            % ND = 3x1 vector of noise density numbers in per root-Hertz units
            % BW = system bandwidth in Hertz
            s.ND = ND;
            s.N = ND*sqrt(s.BW);  % This value is now RMS
        end
        function s = add_scale_factor(s, S)
            % S is a 3X1 vector of the form [sx; sy; sz].
            
            s.G = [S(1), 0, 0; 0, S(2), 0; 0, 0, S(3)]*s.G;
        end
        function s = set_gain(s, G)
            % G = 3x1 vector or 3x3 matrix
            [r, c] = size(G);
            assert(r==3);
            assert((c==1)||(c==3));
            if (r==3)&&(c==1)
                s.G = [G(1),0   ,0;...
                       0   ,G(2),0;...
                       0   ,0   ,G(3)];
            elseif (r==3)&&(c==3)
                s.G = G;
            else
                % default value is to use unity.  We should never hit this.
                s.G = [1,0,0;0,1,0;0,0,1];
            end
        end
        function s = clear_random_walk(s)
            s.DRK = [0;0;0];
        end
        function s = set_random_walk(s, DRK, tau)
            % DRK = 3x1 vector of desired rate random walk std deviations
            % Ts = sample rate in sections
            s.DRK = DRK;
            % sigma_sub_omega is the input to the leaky integrator.
            % See Eqn. 9.6.16 in the TSim manual.
            s.sigma_sub_omega = [   sqrt(2*DRK(1)^2/(s.Ts*tau)); ...
                                    sqrt(2*DRK(2)^2/(s.Ts*tau)); ...
                                    sqrt(2*DRK(3)^2/(s.Ts*tau))];
            s.Tau = tau;
        end
        function s = add_misalignment_in_radians(s, M)
            % M is a 3X1 vector of the form
            % [roll angle; pitch angle; yaw angle].
            s.G = rotate_x_radians(M(1))*rotate_y_radians(M(2))*rotate_z_radians(M(3))*s.G;
        end
        function s = set_offset(s, offset)
            s.O = offset;
        end
        function s = add_misalignment_in_degrees(s, M)
            % M is a 3X1 vector of the form
            % [roll angle; pitch angle; yaw angle].
            s.G = rotate_x_degrees(M(1))*rotate_y_degrees(M(2))*rotate_z_degrees(M(3))*s.G;
        end
        function [vectorOut, OPD] = corrupt(s, temperature, time, vectorIn, otherVectorIn)
            % Bulk Model
            B = s.G*vectorIn + s.O;
            % Drift Model
            % First calculate drift due to rate random walk
            wk = s.sigma_sub_omega.*randn(3,1); % Eqn 9.6.16
            s.DRK = s.Ts*wk + s.DRK - (s.Ts/s.Tau)*s.DRK; % See Section 9.6.5 of the TSIM manual
            DRR = s.R * time;         % Random drift attributable to ramp
            DRN = s.N .* randn(3,1);  % Random drift attributable to angle random walk
            DRB = s.B .* randn(3,1);  % Random drift attributable to bias
            DaA = s.Da*otherVectorIn;   % Random drift due to acceleration (when working with gyros)
            DtDT = s.DT*(temperature-25); % Random drift attributable to temperature
            D = s.DRK + DRR + DRN + DRB + DaA + DtDT;  % total drift
            OPD = s.O + D;
            scale_factor = [1;1;1] + (temperature-25)*(1e-6)*s.EPSt; % scale factor model
            continuous_output = (B+D).*scale_factor;
            % Now let's throw in effects of quantizing
            continuous_output = clamp3(continuous_output, s.range);
            vectorOut = s.resolution*(round(continuous_output/s.resolution));
        end        % function
        function [] = report(s, fn, mode, T, units)
            % s = self pointer
            % fn = filename to write to
            % mode = 'w' or 'w+'
            dgr = 180/pi;
            if strcmp(units, 'degrees/second')
                % we need to convert from radians/second to degrees/second
                range = dgr * s.range;
                ND   = dgr * s.ND;
                N  = dgr * s.N;
                B  = dgr * s.B;
                sigma_sub_omega  = dgr * s.sigma_sub_omega;
                R  = dgr * s.R;
                DT   = dgr * s.DT;
                DRK  = dgr * s.DRK;
                Da   = dgr * s.Da;
                O    = dgr * s.O;
                EPSt = dgr * s.EPSt;
            else
                range = s.range;
                ND   = s.ND;
                N  = s.N;
                B  = s.B;
                sigma_sub_omega  = s.sigma_sub_omega;
                R  = s.R;
                DT   = s.DT;
                DRK  = s.DRK;
                Da   = s.Da;
                O    = s.O;
                EPSt = s.EPSt;
            end
            fid = fopen(fn, mode);
            if (fid==-1)
                printf('Error, could not open %s\n', fn);
                return;
            else
                fprintf(fid, '----------------------------------------------------\n');
                fprintf(fid, '%s\n', T);
                fprintf(fid, '* Model file: %s (based on IEEE 1431)\n', mfilename);
                fprintf(fid, '* Range: +/-%d %s\n', range, units);
                fprintf(fid, '* Number of bits: %d\n', s.NB);
                n = length(ND);
                switch (n)
                    case 1
                        fprintf(fid, '* Noise density: %f (%s/root-Hz)\n', ND, units);
                    case 3
                        fprintf(fid, '* Noise density:                                               [%f %f %f] (%s/root-Hz)\n', ND(1), ND(2), ND(3), units);
                end
                fprintf(fid, '* N  - Random drift attributable to Angle Random Walk:         [%f %f %f] (%s)\n', ...
                    N(1), N(2), N(3), units);
                fprintf(fid, '* B  - Random drift attributable to bias instability:          [%f %f %f] (%s)\n', ...
                    B(1), B(2), B(3), units);
                fprintf(fid, '* So - (sigma_sub_omega) Input to leaky integrator modeling\n');
                fprintf(fid, '       random drift attributable to rate random walk:          [%f %f %f] (%s)\n', ...
                    sigma_sub_omega(1), sigma_sub_omega(2), sigma_sub_omega(3), units);
                fprintf(fid, '* DRK- Nominal output of leaky integrator modeling\n');
                fprintf(fid, '       random drift attributable to rate random walk:          [%f %f %f] (%s)\n', ...
                    DRK(1), DRK(2), DRK(3), units);
                fprintf(fid, '* R  - Random drift attributable to RAMP:                      [%f %f %f] (%s)\n', ...
                    R(1), R(2), R(3), units);
                fprintf(fid, '* DT - Random drift attributable to a change in temperature:   [%f %f %f] (%s)\n', ...
                    DT(1), DT(2), DT(3), units);
                fprintf(fid, '* Da - Random drift attributable to acceleration:              [%f %f %f] (%s)\n', ...
                    Da(1), Da(2), Da(3), units);
                fprintf(fid, '* O  - Zero Rate Offsets:                                      [%f %f %f] (%s)\n', O(1), O(2), O(3), units);
                fprintf(fid, '* G  - Gain Matrix:                                            [%5f %5f %5f] (unitless)\n', s.G(1,1), s.G(1,2), s.G(1,3));
                fprintf(fid, '*                                                              [%5f %5f %5f]\n', s.G(2,1), s.G(2,2), s.G(2,3));
                fprintf(fid, '*                                                              [%5f %5f %5f]\n', s.G(3,1), s.G(3,2), s.G(3,3));
                invG = inv(s.G);
                fprintf(fid, '* invG  - Inverse Gain Matrix:                                 [%5f %5f %5f] (unitless)\n', invG(1,1), invG(1,2), invG(1,3));
                fprintf(fid, '*                                                              [%5f %5f %5f]\n', invG(2,1), invG(2,2), invG(2,3));
                fprintf(fid, '*                                                              [%5f %5f %5f]\n', invG(3,1), invG(3,2), invG(3,3));
                fprintf(fid, '* EPSt - Scale factor temp sensitivity coefficient:            [%f %f %f] (%s/C)\n', ...
                    EPSt(1), EPSt(2), EPSt(3), units);
                fclose(fid)
            end
        end
    end  % methods
    
end %class

