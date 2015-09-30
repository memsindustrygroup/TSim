% Copyright (c) 2012, Freescale Semiconductor
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

