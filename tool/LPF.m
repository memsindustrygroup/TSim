% © 2012-2016 NXP Semiconductor N.V..  All rights reserved.
% SPDX-License-Identifier: BSD-3-Clause
% The BSD 3-clause license for this file can be found in the license.pdf file included with this 
% distribution or at https://spdx.org/licenses/BSD-3-Clause.html

function [ Num, Denom ] = LPF( Fc, Fs, N )
% calculate filter coefficients for a low pass filter
% Fc = cutoff frequency
% Fs = sample frequency
% N = filter order
Hf = fdesign.lowpass('N,Fc', N, Fc, Fs);
Hd = design(Hf);
s = coeffs(Hd);
Num = s.Numerator;
Denom = [1];
end

