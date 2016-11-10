% © 2012-2016 NXP Semiconductor N.V..  All rights reserved.
% SPDX-License-Identifier: BSD-3-Clause
% The BSD 3-clause license for this file can be found in the license.pdf file included with this 
% distribution or at https://spdx.org/licenses/BSD-3-Clause.html

% process_plot will print a figure into a .png output file
% ax1 = figure handle
% fn = output filename
function [] = process_plot(ax1, fn)
    x0=10;
    y0=10;
    width=600;
    height=600;
    set(ax1,'units','points','position',[x0,y0,width,height]);
    saveas(ax1, [fn, '.pdf'], 'pdf');
    close all;
end

