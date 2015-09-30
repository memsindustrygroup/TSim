clc;
N=20; % filter order
Fc = 10; % Cutoff Frequency
Fs = 200; % Sampling Frequency
Hf = fdesign.lowpass('N,Fc', N, Fc, Fs)
Hd = design(Hf)
s = coeffs(Hd)