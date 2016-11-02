% Copyright (c) 2012, Freescale Semiconductor
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

