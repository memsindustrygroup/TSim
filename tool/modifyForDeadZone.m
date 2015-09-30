function [ result ] = modifyForDeadZone( input, gamma )
    % modify input to account for dead zone that can occur at the zero
    % crossing of some sensors.
    if (input<0)&&(input > (-gamma))
        result = -gamma;
    elseif (input>=0)&&(input < gamma)
        result = gamma;
    else
        result = input;
    end
end

