% Copyright (c) 2012, Freescale Semiconductor
function [ sts, writerObj ] = startAVI( dirName, fileName )
% Initiate creation of an AVI movie file
writerObj=0;
if (isa(dirName, 'char'))
    if (strcmp(dirName, ''))
        sts=0;
    else
        if ((7==exist(dirName)) || mkdir(dirName))
            fn=fullfile(dirName, fileName);
            writerObj=VideoWriter(fn);
            open(writerObj)
            %aviobj = avifile(fn, 'compression', 'None');
            sts=1;
        else
            sts=0;
        end
    end
else
    sts=0;
end

end

