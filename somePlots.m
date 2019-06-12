function somePlots(sortedData)
% ratNames = fieldnames(sortedData.respSync.longITI);
% 
% for i = 1:4
%     figure
%     for j = 1:size(ratNames,1)
%         subplot(2,size(ratNames,1),j)
%         imagesc(sortedData.respSync.longITI.(ratNames{j}){1,i})
% %         caxis([-5 10])
%         
%         subplot(2,size(ratNames,1),size(ratNames,1)+1:size(ratNames,1)*2)
%         plot(mean(sortedData.respSync.longITI.(ratNames{j}){1,i}))
%         hold on
%         xlim([0 2500])
%     end
% end
% 
% 
% % Aligned?
% 
% for i = 1:4
%     figure
%     for j = 1:size(ratNames,1)
%         
%         plotDat = sortedData.startSync.longITI.(ratNames{j}){1,i};
%         
%         plotDat = plotDat(1:end,:)-plotDat(:,500);
%         
%         subplot(2,size(ratNames,1),j)
%         imagesc(plotDat)
% %         caxis([-5 10])
%         
%         subplot(2,size(ratNames,1),size(ratNames,1)+1:size(ratNames,1)*2)
%         plot(mean(plotDat))
%         hold on
%         xlim([0 2500])
%     end
% end


%% Sort prematures
% This will sort trials based on their response times (either premature
% responses or correct/incorrect latencies)

syncs = fieldnames(sortedData);
condNames = fieldnames(sortedData.(syncs{1}));
ratNames = fieldnames(sortedData.(syncs{1}).(condNames{1}));
resps = {'correct' 'incorrect' 'omission' 'premature'};


for sync = 1:2
    for cond = 1:3
            allrspT=[];
        for i = 1:4
%             figure
            for j = 1:size(ratNames,1)
                
                % calculations 
                
                plotDat = sortedData.(syncs{sync}).(condNames{cond}).(ratNames{j}){1,i};
                if sync == 1
                    plotDat = plotDat(1:end,:)-median(plotDat(:,1:508),2);
                else
                    plotDat = plotDat(1:end,:)-median(plotDat(:,1500:1555),2);
                end
                
                respTime = sortedData.(syncs{sync}).(condNames{cond}).(ratNames{j}){1,5};
                respTime = respTime(respTime(:,3)==i,:);
                respTime = sortrows([respTime, respTime(:,2)-respTime(:,1),plotDat],5);
                
                
                if sync == 1
                    rspTplot = 508+ceil(respTime(:,5)*101.73);
                    allrspT = [allrspT; respTime(:,5)];
                    if size(plotDat,1)> 1
                        trtMeans{i,cond}(j,:) = mean(plotDat);
                    else
                        trtMeans{i,cond}(j,:) = nan(1,2545);
                    end
                else
                    rspTplot = 1526-ceil(respTime(:,5)*101.73);
                    allrspT = [allrspT; respTime(:,5)];
                    if size(plotDat,1)> 1
                        rspMeans{i,cond}(j,:) = mean(plotDat);
                    else
                        rspMeans{i,cond}(j,:) = nan(1,2545);
                    end
                end
                
                
                % plots
                subplot(2,8,j)
                if size(rspTplot,1)>0
                    imagesc(respTime(:,6:end))
                    caxis([-3 6])
                    colormap(hot)
                    hold on
                    stairs(rspTplot,1:numel(rspTplot),'g','LineWidth',2)
                    if sync ==1
                        line([508 508], get(gca, 'YLim'), 'Color', 'g', 'LineWidth',2);
                    else
                        line([1526 1526], get(gca, 'YLim'), 'Color', 'g', 'LineWidth',2);
                    end
                end
                
                subplot(2,8,9:14)
                plot(mean(respTime(:,6:end)))
                semUp = mean(respTime(:,6:end)) + std(respTime(:,6:end)) /...
                    sqrt(size(respTime(:,6:end),1));
                semDown = mean(respTime(:,6:end)) - std(respTime(:,6:end)) /...
                    sqrt(size(respTime(:,6:end),1));
                hold on
                jbfill(1:numel(semUp), semUp, semDown);
                hold on
                
                if j == 8
                    subplot(2,8,15:16)
                    histogram(allrspT,25)
                end
            end
%             suptitle(strcat(condNames{cond}, syncs{sync}, resps{i}))
        end
    end
end


%% means
% This will show comparison plots of means per experimental group. This
% compares means per response type. Will return 4 plots containing all
% ITIs or SDs in that plot.
%
% Will do this for traces synced at trialstart and at nosepoke response.
%
% To do:
% - Lines indicating trial start and nose poke response times
% - Subplot titles
% - Figure title
% - Xlim to fit trace properly
% - axis labels
% - X axis in seconds rather than ms
% - Legend

plotcol ={[0,0.4470,0.7410];[0.8500,0.3250,0.0980];[0.9290,0.6940,0.1250];[0.4940,0.1840,0.5560]};

syncs = fieldnames(sortedData);
condNames = fieldnames(sortedData.(syncs{1}));
ratNames = fieldnames(sortedData.(syncs{1}).(condNames{1}));
if ratNames{1}(1:4) == 'gmd*'
    % this is for the figure title
    rN = ratNames{1}(2:4);
else
    rN = ratNames{1}(2:3);
end

if condNames{1}(end-2:end) == 'ITI'
    % this is also for the figure title
    cN = 'var iti';
    xLine = [12.5 7.5 5];
elseif condNames{1}(end-1:end) == 'SD'
    cN = 'var sd';
    xLine = [5 5 5];
else
    cN = 'fixed iti';
    xLine = [5 5 5];
end
resps = {'correct' 'incorrect' 'omission' 'premature'};

% Compare conditions
for sync = 1:2
    figure
    for cond = 1:3
        
        for resp = 1:4
            ax(resp) = subplot(1,8,1+2*(resp-1):1+(1+2*(resp-1)));
            xVal = (1:size(trtMeans{resp,cond},2))/101.73; % convert frames to seconds
            if sync == 1
                plot(xVal,movmean(nanmean(trtMeans{resp,cond}),50,'omitnan'), 'LineWidth', 2)
                sU = movmean(nanmean(trtMeans{resp,cond}),50) + movmean(nanstd(trtMeans{resp,cond}),50)/...
                    size(trtMeans{resp,cond},1);
                sD = movmean(nanmean(trtMeans{resp,cond}),50) - movmean(nanstd(trtMeans{resp,cond}),50)/...
                    size(trtMeans{resp,cond},1);
                jbfill(xVal, sU, sD,plotcol{cond}, plotcol{cond});
                
            else
                plot(xVal,movmean(nanmean(rspMeans{resp,cond}),50,'omitnan'), 'LineWidth', 2)
                sU = movmean(nanmean(rspMeans{resp,cond}),50) + movmean(nanstd(rspMeans{resp,cond}),50)/...
                    size(rspMeans{resp,cond},1);
                sD = movmean(nanmean(rspMeans{resp,cond}),50) - movmean(nanstd(rspMeans{resp,cond}),50)/...
                    size(rspMeans{resp,cond},1);
                jbfill(xVal, sU, sD,plotcol{cond}, plotcol{cond});
            end

            xticks(0:5:25); % tick marks on x-axis
            xticklabels({'0','5','10','15','20','25'}); % tick labels on x-axis
            xlabel('Time (s)'); % x-axis label
            if resp == 1
                ylabel('dF/F'); % y-axis label'
            end
            title(resps{resp}); % subplot title
            
            % x-axis limits. Test if it's a vSD or vITI session to decide
            % what the limits should be
            if strcmp(cN,'var iti')
                xlim([0 25]); % x limit according fit to trace
            else
                if sync == 1
                    xlim([0 15])
                else
                    xlim([5 20])
                end
            end
            hold on
            
        end
        
    end
    
    % Makes sure axes are same size
    linkaxes(ax,'y');
    
    % Lines indicating trial start/nose poke response, and/or cue lights
    for i = 1:4
        subplot(1,8,1+2*(i-1):1+(1+2*(i-1)));
    if sync == 1
        line([5 5], get(gca, 'YLim'), 'Color', 'k', 'LineStyle', '--')
        for lin = 1: size(condNames,1)
            line([5+xLine(lin) 5+xLine(lin)], get(gca, 'YLim'), 'Color', plotcol{lin}, 'LineStyle', '--')
        end
    else
        line([15 15], get(gca, 'YLim'), 'Color', 'k', 'LineStyle', '--')
    end
    end

    % Plot title
    suptitle(strcat(rN, {' - '}, cN, {' - means per response type'}));

end

        

%% Compare response types
% This will show comparison plots of means per experimental group. This
% compares means per experimental condition. Will return 3 plots containing all
% response types for a given condition (e.g. long ITI or mid SD).
%
% Will do this for traces synced at trialstart and at nosepoke response.
%
% To do:
% - Lines indicating trial start and nose poke response times
% - Subplot titles
% - Figure title
% - Xlim to fit trace properly
% - axis labels
% - X axis in seconds rather than ms
% - Legend


plotcol ={[0,0.4470,0.7410];[0.8500,0.3250,0.0980];[0.9290,0.6940,0.1250];[0.4940,0.1840,0.5560]};

syncs = fieldnames(sortedData);
condNames = fieldnames(sortedData.(syncs{1}));
ratNames = fieldnames(sortedData.(syncs{1}).(condNames{1}));
if ratNames{1}(1:4) == 'gmd*'
    % this is for the figure title
    rN = ratNames{1}(2:4);
else
    rN = ratNames{1}(2:3);
end

if condNames{1}(end-2:end) == 'ITI'
    % this is also for the figure title
    cN = 'var iti';
    xLine = [12.5 7.5 5];
elseif condNames{1}(end-1:end) == 'SD'
    cN = 'var sd';
    xLine = [5 5 5];
else
    cN = 'fixed iti';
    xLine = [5 5 5];
end
resps = {'correct' 'incorrect' 'omission' 'premature'};

for sync = 1:2
    figure
    for resp = 1:4
        for cond = 1:3
            ax(cond) = subplot(1,6,1+2*(cond-1):1+(1+2*(cond-1)));

            xVal = (1:size(trtMeans{resp,cond},2))/101.73; % convert frames to seconds
            if sync == 1
                plot(xVal,movmean(nanmean(trtMeans{resp,cond}),50,'omitnan'), 'LineWidth', 2)
                sU = movmean(nanmean(trtMeans{resp,cond}),50) + movmean(nanstd(trtMeans{resp,cond}),50)/...
                    size(trtMeans{resp,cond},1);
                 sD = movmean(nanmean(trtMeans{resp,cond}),50) - movmean(nanstd(trtMeans{resp,cond}),50)/...
                    size(trtMeans{resp,cond},1);    
                jbfill(xVal, sU, sD,plotcol{resp}, plotcol{resp});
                
            else
                plot(xVal,movmean(nanmean(rspMeans{resp,cond}),50,'omitnan'), 'LineWidth', 2)
                sU = movmean(nanmean(rspMeans{resp,cond}),50) + movmean(nanstd(rspMeans{resp,cond}),50)/...
                    size(rspMeans{resp,cond},1);
                 sD = movmean(nanmean(rspMeans{resp,cond}),50) - movmean(nanstd(rspMeans{resp,cond}),50)/...
                    size(rspMeans{resp,cond},1);    
                jbfill(xVal, sU, sD,plotcol{resp}, plotcol{resp});
            end

            
            
            xticks(0:5:25); % tick marks on x-axis
            xticklabels({'0','5','10','15','20','25'}); % tick labels on x-axis
            xlabel('Time (s)'); % x-axis label
            if resp == 1
                ylabel('dF/F'); % y-axis label'
            end
            title(resps{resp}); % subplot title
            
            % x-axis limits. Test if it's a vSD or vITI session to decide
            % what the limits should be
            if strcmp(cN,'var iti')
                xlim([0 25]); % x limit according fit to trace
            else
                if sync == 1
                    xlim([0 15])
                else
                    xlim([5 20])
                end
            end
            hold on            
        end
    end
    % Makes sure axes are same size
    linkaxes(ax,'y');
    
    % Lines indicating trial start/nose poke response, and/or cue lights
    for i = 1:3
        subplot(1,6,1+2*(i-1):1+(1+2*(i-1)));
    if sync == 1
        line([5 5], get(gca, 'YLim'), 'Color', 'k', 'LineStyle', '--')
        for lin = 1: size(condNames,1)
            line([5+xLine(lin) 5+xLine(lin)], get(gca, 'YLim'), 'Color', plotcol{lin}, 'LineStyle', '--')
        end
    else
        line([15 15], get(gca, 'YLim'), 'Color', 'k', 'LineStyle', '--')
    end
    end

    % Plot title
    suptitle(strcat(rN, {' - '}, cN, {' - means per condition'}));
% 
end

end
            