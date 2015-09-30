
function [ output_args ] = MarkovTest( input_args )
% Generate plot for example of random walk using 1st order Markov process.
close all;
clc;
sigmaB=1;
Ts = 0.01;
tau = 10000;
sigma_omega = sqrt(2*sigmaB^2/(Ts*tau));
lastB=0;
for i=1:1000000
    wk(i) = sigma_omega*randn(1);
    B(i) = wk(i)*Ts + lastB - (Ts/tau)*lastB;
    lastB = B(i);
    time(i)=Ts*i;
end
plot(time, B);
xlabel('seconds');
ylabel('b(k)');
title('1st Order Markov Process');
sb=std(B);
fprintf('Sigma(omega)=%f\n', sigma_omega);
fprintf('The standard deviation of the generated waveform is %f.\n', sb);
end

