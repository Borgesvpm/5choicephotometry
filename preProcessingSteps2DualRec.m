function [sessionData, rawData] = preProcessingSteps2DualRec(rawData)

%% preprocessing (1)
rN1 = strfind(rawData.path_to_data, '\'); rN2 = strfind(rawData.path_to_data, '-');
rN3 = rawData.path_to_data(rN1(end)+1:rN2(1)-1);

rN4 = strfind(rN3, '_'); 
ratName{1} = rN3(1:rN4-1); ratName{2}=rN3(rN4+1:end);

fld = {'rat_one' 'rat_two'};

for rat = 1:2
    % Define and downsample 405 (dat2a) and 470 (dat1a) traces
    currData = rawData.(fld{rat});
    dat1a = currData.dat1(:,2); dat2a = currData.dat2(:,2);
    dat1a = downsample(dat1a, 10); dat2a = downsample(dat2a, 10);
    rawData.adjConversion=rawData.conversion * 0.1;
%     
%     % % Linear fit
%     if numel(dat2a)>250000
%         winSize = ceil(numel(dat2a)/(rawData.adjConversion*60))
%     else
%         winSize = ceil(numel(dat2a)/(rawData.adjConversion*60))
%     end
% 
% reg = polyfit(dat2a, dat1a, 1);
% a = reg(1); b = reg(2);
% controlFit = a.*dat2a + b;
% 
%     
    % % Exponential fit to correct for bleaching or LED decay
    x=1:numel(dat2a);
    f0dat2=fit((1:numel(dat2a))',dat2a,'exp1');
    dat2Fit=(f0dat2.a*exp(f0dat2.b*x))';    
    
    x=1:numel(dat1a);
    f0dat1=fit((1:numel(dat1a))',dat1a,'exp1');
    dat1Fit=(f0dat1.a*exp(f0dat1.b*x))';
    
    % Scale control channel to 470nm channel and take dF/F
    cfFinal = dat2a.*(dat1Fit./dat2Fit);
    sessionData.(ratName{rat}).adjCaSig=100*(dat1a-cfFinal)./cfFinal;
    
end

end