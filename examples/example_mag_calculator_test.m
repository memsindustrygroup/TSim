function [ output_args ] = example_mag_calculator_test( input_args )
close all;
for t=0:30;
    M(t+1,:) = example_mag_calculator(t, [0;0;0], 25)';
    time(t+1)=t;
end
plot(time, M(:,1), time, M(:,2), time, M(:,3));

end

