function [normDat] = deltaFF (dat2Final, cfFinal)
    
normDat = (dat2Final - cfFinal)./ cfFinal; %this gives deltaF/F
normDat = normDat * 100; % get %


y=NaN(999,1);
normDat=[y;normDat];
