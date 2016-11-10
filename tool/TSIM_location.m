% © 2012-2016 NXP Semiconductor N.V..  All rights reserved.
% SPDX-License-Identifier: BSD-3-Clause
% The BSD 3-clause license for this file can be found in the license.pdf file included with this 
% distribution or at https://spdx.org/licenses/BSD-3-Clause.html

function [ dirName ] = TSIM_location(  )
% Return the value of the TSIM_DIR environmental variable.
% also, check that it exists.
    dirName = getenv('TSIM_DIR');
    if strcmp(dirName, '')
        error('ERROR: Please set environmental variable TSIM_DIR to the location of your TSIM directory.\n');
    end
    if (7 ~= exist(dirName))
        error('ERROR: %s does not exist.\n', dirName);
    end
end

