function [q] = fix_quaternion_polarity(qin)
    [r1, c1] = size(qin);
    for i=1:r1
        if (qin(i,1)<0) 
            q(i,:) = -qin(i,:);
        else
            q(i,:) = qin(i,:);
        end
    end
end
