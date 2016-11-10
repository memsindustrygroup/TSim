% © 2016 NXP Semiconductor N.V..  All rights reserved.
% SPDX-License-Identifier: BSD-3-Clause
% The BSD 3-clause license for this file can be found in the license.pdf file included with this 
% distribution or at https://spdx.org/licenses/BSD-3-Clause.html

function [ dX ] = differentiate( X, dT, option )
% X = column array to be differentiated
% option = 3 or 5
	[r, c] = size(X);
	dTx2 = 2*dT;
    dTx12 = 12*dT;
    dX(1,:) = (X(2,:)-X(1,:))/dT;
	dX(r,:) = (X(r,:)-X(r-1,:))/dT;
    switch option
        case 3
            for i=2:r-1
                dX(i,:) = (X(i+1,:)-X(i-1,:))/dTx2;
            end
        case 5
            dX(2,:) = (X(3,:)-X(1,:))/dTx2;
            dX(r-1,:) = (X(r,:)-X(r-2,:))/dTx2;
            for i=3:r-2
                % see https://en.wikipedia.org/wiki/Five-point_stencil
                dX(i,:) = (-X(i+2,:) + 8*X(i+1,:) - 8*X(i-1,:) + X(i-2,:))/dTx12;
            end
        otherwise
            dX=[];  % will cause error downstream
    end
end

