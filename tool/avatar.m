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
                    'FaceColor','flat','EraseMode','normal');
        end
    end    
end

