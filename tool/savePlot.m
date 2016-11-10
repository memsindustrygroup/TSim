% © 2012-2016 NXP Semiconductor N.V..  All rights reserved.
% SPDX-License-Identifier: BSD-3-Clause
% The BSD 3-clause license for this file can be found in the license.pdf file included with this 
% distribution or at https://spdx.org/licenses/BSD-3-Clause.html

function [ sts ] = savePlot( dirName, fileName )
% Save current plot into directory dirName as fileName
if (isa(dirName, 'char'))
    if (strcmp(dirName, ''))
        sts=0;
    else
        if ((7==exist(dirName)) || mkdir(dirName))
            fn=fullfile(dirName, fileName);
            process_plot(gcf, fn);
            sts=1;
        else
            sts=0;
        end
    end
else
    sts=0;
end

end

