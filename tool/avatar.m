% © 2012-2016 NXP Semiconductor N.V..  All rights reserved.
% SPDX-License-Identifier: BSD-3-Clause
% The BSD 3-clause license for this file can be found in the license.pdf file included with this 
% distribution or at https://spdx.org/licenses/BSD-3-Clause.html

classdef avatar
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        vertices;
        faces;
        cdata;
    end
    
    methods
        function [a] = avatar()
        end
        function [h] = draw(a, q, scale, offset)
            [r, c] = size(a.vertices);
            for i=1:r
                [ v ] = quaternion_point_rotation( q, a.vertices(i,:)' );
                newV(i,:) = (scale*v + offset)';
            end
            h = patch('Vertices', newV,'Faces',a.faces,'FaceVertexCData',a.cdata, ...
                    'FaceColor','flat');
        end
    end    
end

