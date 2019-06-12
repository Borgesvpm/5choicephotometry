%% Create some plots for stage progressions

% generate relevant fields
stageNames = fieldnames(stageData);
allTraces = [];allTrials=[];

for stage = 1:size(stageNames,1)
    % Compile all data from 1 rat 
    nTrials = size(stageData.(stageNames{stage}).startSync,1);
    
    allTraces = [allTraces; stageData.(stageNames{stage}).startSync];
    allTrials = [allTrials; stageData.(stageNames{stage}).trialstart];

end

%% Figure 1
% Heat plot of all stages
subplotdiv = {[1 4] [2 3 5 6]};
xVal = ceil(1:2545)/101.73;

f1 = figure;
subplot(2,3,subplotdiv{1})
imagesc([0 ceil(2500/101.73)], [0 size(allTraces(allTrials(:,3)==1,:),1)], allTraces(allTrials(:,3)==1,:))
caxis([-5 10])
colorbar
title('All trials')
xlim([0 15])
yL = get(gca, 'YLim');
line([5 5],yL,'Color','m', 'LineWidth', 2, 'LineStyle', '-');
line([10 10],yL,'Color','m', 'LineWidth', 2, 'LineStyle', '-');

subplot(2,3,subplotdiv{2})
title('Mean signal per stage')
for stage = 1:numel(stageNames)
    stageMean = nanmean(stageData.(stageNames{stage}).startSync(stageData.(stageNames{stage}).trialstart(:,3)==1,:));
    
    normStageMean = (stageMean - prctile(stageMean, 0.5)) / (prctile(stageMean,99.5) - prctile(stageMean, 0.5));
    
    plot(xVal, normStageMean,...
        'Color', [1-stage/numel(stageNames) stage/numel(stageNames) 0], 'LineWidth', 2)
    hold on
end
xlim([0 15])
yL = get(gca, 'YLim');
line([5 5],yL,'Color','m', 'LineWidth', 2, 'LineStyle', '-');
line([10 10],yL,'Color','m', 'LineWidth', 2, 'LineStyle', '-');

supertitle('Summary of learning stage activity')