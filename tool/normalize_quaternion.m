% © 2012-2016 NXP Semiconductor N.V..  All rights reserved.
% SPDX-License-Identifier: BSD-3-Clause
% The BSD 3-clause license for this file can be found in the license.pdf file included with this 
% distribution or at https://spdx.org/licenses/BSD-3-Clause.html

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

