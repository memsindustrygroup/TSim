% © 2012-2016 NXP Semiconductor N.V..  All rights reserved.
% SPDX-License-Identifier: BSD-3-Clause
% The BSD 3-clause license for this file can be found in the license.pdf file included with this 
% distribution or at https://spdx.org/licenses/BSD-3-Clause.html

classdef avatar1 < avatar
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function [a] = avatar1()
            %    1 2 3 4 5 6 7 8 9
            x = [0;1;1;0;0;1;1;0;.5];
            y = [0;0;1;1;0;0;1;1;.5];
            z = [0;0;0;0;1;1;1;1;1.25];
            x = (x - 0.5)/4;
            y = (y - 0.5)/4;
            z = z - 0.5;
            
            a.vertices = [ x y z];
            a.faces = [1 2 3 4; ...
                5 6 7 8; ...
                1 5 8 4; ...
                2 6 7 3; ...
                1 5 6 2; ...
                4 8 7 3; ...
                5 6 9 NaN; ...
                6 7 9 NaN; ...
                7 8 9 NaN; ...
                5 8 9 NaN];            
            a.cdata = [
                0 0 0;    % black
                1 0 0;    % red
                0 1 0;    % green
                0 1 1;    % turquoise
                .5 .5 .5; % gray
                1 0 0;    % red
                .5 .5 .5; % gray
                0 1 1;    % turquoise
                1 0 0;    % red
                0 1 0];   % green
        end
    end
    
end

