% Quick script for isoflurane recorings (i.e. expression checks)
% Will make a small plot with baseline and iso traces for same-day
% experiments

% First always account for patch cord autofluorescence, makes huge
% difference
dat2a=rawData.dat2(:,2)-84;
dat1a=rawData.dat1(:,2)-25;

figure
subplot(2,1,1)
plot(rawData.dat2(:,2))
hold on
plot(rawData.dat1(:,2))
shg

title('Baseline recording')
xlabel('Time')
ylabel('Photodetector signal (AU)')

baselineGFP=rawData.dat2(:,2);
baselineControl=rawData.dat1(:,2);
yL = ylim;


subplot(2,1,2)
plot(rawData.dat2(1:numel(baselineGFP),2))
hold on
plot(rawData.dat1(1:numel(baselineGFP),2))
shg

title('Isoflurane recording')
xlabel('Time')
ylabel('Photodetector signal (AU)')
ylim([yL(1) yL(2)])

% Another plot to look at iso session more closely
figure
plot(rawData.dat2(:,1),rawData.dat2(:,2))
title('Isoflurane recording')
xlabel('Time (m)')
ylabel('Photodetector signal (AU)')
xt=0:60:max(rawData.dat2(:,1));
set(gca, 'XTick', xt, 'XTickLabel', xt/60)


%% close up of start expt

dat2a=rawData.dat2(100:end,2);
dat1a=rawData.dat1(100:end,2);

dat2samp = downsample(dat2a,10);
dat1samp = downsample(dat1a,10);
% 
% % polyfit
% reg = polyfit(dat1samp, dat2samp, 1);
% 
% a = reg(1);
% b = reg(2);
% 
% tempFit = a.*dat1samp + b;

% expfit
x=1:numel(dat2samp);
f0cf=fit((1:numel(dat1samp))',dat1samp,'exp1');
f0dat2=fit((1:numel(dat2samp))',dat2samp,'exp1');

cfFit=(f0cf.a*exp(f0cf.b*x))';
dat2Fit=(f0dat2.a*exp(f0dat2.b*x))';

cfFinal=dat1samp./cfFit;
dat2Final=dat2samp./dat2Fit;


dat2sampdff = (dat2Final-median(dat2Final))/median(dat2Final);
dat1sampdff = (cfFinal-median(cfFinal))/median(cfFinal);


fdat2 = dat2sampdff(100:3000);
fdat1 = dat1sampdff(100:3000);

fdat2c=fdat2-min(fdat2);
fdat1c=fdat1-min(fdat1);

%% plot
figure
sig1=plot(fdat2c*100, 'LineWidth', 2);
hold on
sig2=plot(fdat1c*100, 'LineWidth', 2);

xlabel('Time (s)')
ylabel('Fluorescence (AU)')
title('Baseline GCaMP recording', 'FontSize', 48);

xl = get(gca,'XLabel');
xlFontSize = get(xl,'FontSize');
xAX = get(gca,'XAxis');
set(xAX,'FontSize', 30)
set(xl, 'FontSize', 36);

yl = get(gca,'YLabel');
ylFontSize = get(yl,'FontSize');
yAX = get(gca,'YAxis');
set(yAX,'FontSize', 30)
set(yl, 'FontSize', 36);

hleg = [sig1 sig2];
leg=legend(hleg, 'GCaMP', 'GFP');
leg.FontSize=30;
shg

%% Add another module for multi-day experiments to determine time needed for
% expression and see if there are some general trends/patterns in rats with
% either high or low expression




