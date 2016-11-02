% Convert an Nx4 array of quaternion coefficients into an Nx3 array of
% Euler angles.
function [eulers] = quaternions_to_eulers(quaternions, refFrame)
    [r1, c1] = size(quaternions);
    for i=1:r1
        switch refFrame
            case Env.NED
                eulers(i,:) = quaternion_to_eulers_NED(quaternions(i,:));
            case Env.Win8
                eulers(i,:) = quaternion_to_eulers_Win8(quaternions(i,:));
            case Env.Android
                eulers(i,:) = quaternion_to_eulers_AndrENU(quaternions(i,:));
        end
    end
end

