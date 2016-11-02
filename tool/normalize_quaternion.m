% Normalize an array of quaternions
% qs = input nX4 array of quaternion coefficients
% normalized  = output nX4 normalized to length 1
% normalization is routinely done in the quaternion world to negate
% roundoff errors.
function [normalized] = normalize_quaternion(qs)
    [r,c] = size(qs);
    for i=1:r
        normalized(i,:) = qs(i,:)/norm(qs(i,:));
    end
end

