function [sessionData, rawData] = preProcessingSteps2(rawData)
%% preprocessing of the signal
% This will take a raw TDT data file and turn the entire trace into a dF/F
% First the data will be downsampled 10x to have a more usable size
%
% Then we apply an exponential fit to correct for bleaching in the signal.
% We use an exponential it because we expect it to be the best fit for
% bleaching.
% We only expfit the 470 channel.
%
% Finally, we apply a linear scaling fit to the 405nm channel to match and
% scale it to the 470nm channel. 
% This will also act as a motion-corrected baseline (or F) for our
% 470nm channel, allowing us to calculate dF/F for the entire trace. 
% 
% Output: sessionData.adjCaSig
% This is the dF/F for the session.

% Downsampling
dat1a = rawData.dat1(:,2); dat2a = rawData.dat2(:,2);
dat1a = downsample(dat1a, 10); dat2a = downsample(dat2a, 10);
rawData.adjConversion=rawData.conversion * 0.1;
% 
% % Linear fit
% reg = polyfit(dat1a, dat2a, 1);
% a = reg(1); b = reg(2);
% controlFit = a.*dat1a + b;

% % Exponential fit
x=1:numel(dat2a);
f0dat2=fit((1:numel(dat2a))',dat2a,'exp1');
dat2Fit=(f0dat2.a*exp(f0dat2.b*x))';
% dat2Final=(dat2a./dat2Fit);


x=1:numel(dat1a);
f0dat1=fit((1:numel(dat1a))',dat1a,'exp1');
dat1Fit=(f0dat1.a*exp(f0dat1.b*x))';
% dat2Final=(dat2a./dat2Fit).*dat2Fit;


% Take dF/F
cfFinal = dat1a.*(dat2Fit./dat1Fit);
sessionData.adjCaSig=100*(dat2a-cfFinal)./cfFinal;

end