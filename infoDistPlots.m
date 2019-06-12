function infoDistPlots(infoDist, infoDistRsp, sortedData)

% plotcol = jet(6);

syncs = fieldnames(sortedData);
condNames = fieldnames(sortedData.(syncs{1}));
ratNames = fieldnames(sortedData.(syncs{1}).(condNames{1}));
groupNames = fieldnames(infoDist);
if condNames{1}(end-2:end) == 'ITI'
    % this is also for the figure title
    cN = 'var iti';
    xLine = [12.5  7.5  5 12.5 7.5 5];
elseif condNames{1}(end-1:end) == 'SD'
    cN = 'var sd';
    xLine = 5;
else
    cN = 'fixed iti';
    xLine = 5;
end
resps = {'correct' 'incorrect' 'omission' 'premature'};



% Plots
for sync = 1:2
    figure
    plotcol = [1 0.6 0.6; 0.7 0.9 0.6; 0.64 0.08 0.18; 0.15 0.3 0.15];
    for cond = 1:3
        
        for resp = 1:2
            %% Subplot row 1 + 2
            resp = resp^2; %Careful, this is now only for Cor+prem
%             ax(resp-1+cond) = 
            subplot(2,3, resp-1+cond);
            xVal = (1:size(infoDist.(groupNames{1}){resp,cond},2))/5; % convert frames to seconds
            
            for grp = 1:size(groupNames,1)
                hold on
                if sync == 1
                    mplot = plot(xVal,infoDist.(groupNames{grp}){resp,cond}(:,1:end)',...
                         'LineWidth', 1,'Color',plotcol(grp,:));
                     plot(xVal,nanmean(infoDist.(groupNames{grp}){resp,cond}),...
                         'LineWidth', 3,'Color',plotcol(grp+2,:));
%                     sU = movmean(nanmean(infoDist.(groupNames{grp}){resp,cond}),50) ...
%                         + movmean(nanstd(infoDist.(groupNames{grp}){resp,cond}),50)/...
%                         size(trtMeans.(groupNames{grp}){resp,cond},1);
%                     sD = movmean(nanmean(infoDist.(groupNames{grp}){resp,cond}),50) ...
%                         - movmean(nanstd(infoDist.(groupNames{grp}){resp,cond}),50)/...
%                         size(trtMeans.(groupNames{grp}){resp,cond},1);
%                     sumzero = sum(sU==0);
%                     sumnan = sum(isnan(sU));
%                     jbfill(xVal(1:(end-sumzero-sumnan-1)),  sU(1:(end-sumzero-sumnan-1)), sD(1:(end-sumzero-sumnan-1)),plotcol(grp,:),plotcol(grp,:));

                    
                else
                    mplot = plot(xVal,infoDistRsp.(groupNames{grp}){resp,cond}(:,1:end)',...
                         'LineWidth', 1,'Color',plotcol(grp,:));
                     plot(xVal,nanmean(infoDistRsp.(groupNames{grp}){resp,cond}),...
                         'LineWidth', 3,'Color',plotcol(grp+2,:));
%                      sU = movmean(nanmean(infoDistRsp.(groupNames{grp}){resp,cond}),50) ...
%                         + movmean(nanstd(infoDistRsp.(groupNames{grp}){resp,cond}),50)/...
%                         size(rspMeans.(groupNames{grp}){resp,cond},1);
%                     sD = movmean(nanmean(infoDistRsp.(groupNames{grp}){resp,cond}),50) ...
%                         - movmean(nanstd(infoDistRsp.(groupNames{grp}){resp,cond}),50)/...
%                         size(rspMeans.(groupNames{grp}){resp,cond},1);
%                     sumzero = sum(sU==0);
%                     sumnan = sum(isnan(sU));
%                     jbfill(xVal(sumnan+sumzero+1:end),  sU(sumnan+sumzero+1:end), sD(sumnan+sumzero+1:end),plotcol(grp,:),plotcol(grp,:));
                end
            end
            
            xticks(0:5:25); % tick marks on x-axis
            xticklabels({'0','5','10','15','20','25'}); % tick labels on x-axis
            xlabel('Time (s)'); % x-axis label
            if resp == 1
                ylabel('dF/F'); % y-axis label'
            end
            title(strcat(resps{resp}, {' - '}, condNames{cond})); % subplot title
            
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
            
        end
    end
    
    for i = 1:6
        subplot(2,3, i);
        if sync == 1
            line([5 5], get(gca, 'YLim'), 'Color', 'k', 'LineStyle', '--','HandleVisibility','off')
            for j = 1:ceil(numel(xLine)/2)
                line([5+xLine(j) 5+xLine(j)], get(gca, 'YLim'), ...
                    'Color', plotcol(j,:), 'LineStyle', '--','HandleVisibility','off')
            end
        else
            line([15 15], get(gca, 'YLim'), 'Color', 'k', 'LineStyle', '--','HandleVisibility','off')
        end
        
    end
     
    supertitle(strcat('information content - per resp - ', syncs{sync}))    
end
% 
%             xticks(0:5:25); % tick marks on x-axis
%             xticklabels({'0','5','10','15','20','25'}); % tick labels on x-axis
%             xlabel('Time (s)'); % x-axis label
%             if resp == 1
%                 ylabel('dF/F'); % y-axis label'
%             end
%             title(resps{resp}); % subplot title
%             
%             % x-axis limits. Test if it's a vSD or vITI session to decide
%             % what the limits should be
%             if strcmp(cN,'var iti')
%                 xlim([0 25]); % x limit according fit to trace
%             else
%                 if sync == 1
%                     xlim([0 15])
%                 else
%                     xlim([5 20])
%                 end
%             end
%             if cond == 3
%                 subplot(3,3,resp-1+cond)
%                 legend(mplot(1:numel(groupNames)),groupNames);
%             end
%             hold on
%             
%             
%            
%% Compare response types
plotcol = [0.47 0.67 0.19; 0.85 0.33 0.1; 0 0.45 0.74; 0.64 0.08 0.18];
for sync = 1:2
    figure
    % Figure: 
    % rows - response types 
    % columns - groups
    % 
    % frames - all ITIs x response type x group
    %
    for grp = 1:size(groupNames,1)
        for resp = 1:4
           
            
%             ax((grp-1)*4+resp) = 
            subplot(2,4, (grp-1)*4+resp);
            xVal = (1:size(infoDist.(groupNames{1}){resp,cond},2))/5; % convert frames to seconds
            
            for cond = 1:size(condNames,1)
                hold on
                if sync == 1
                    mplot = plot(xVal,infoDist.(groupNames{grp}){resp,cond}(:,1:end)',...
                         'LineWidth', 1,'Color',plotcol(cond,:));
                    sU = movmean(nanmean(trtMeans.(groupNames{grp}){resp,cond}),50) ...
                        + movmean(nanstd(trtMeans.(groupNames{grp}){resp,cond}),50)/...
                        size(trtMeans.(groupNames{grp}){resp,cond},1);
                    sD = movmean(nanmean(trtMeans.(groupNames{grp}){resp,cond}),50) ...
                        - movmean(nanstd(trtMeans.(groupNames{grp}){resp,cond}),50)/...
                        size(trtMeans.(groupNames{grp}){resp,cond},1);
                    sumzero = sum(sU==0);
                    sumnan = sum(isnan(sU));
                    jbfill(xVal(1:(end-sumzero-sumnan-1)),  sU(1:(end-sumzero-sumnan-1)),...
                        sD(1:(end-sumzero-sumnan-1)),plotcol(cond,:),plotcol(cond,:));
                    
                else
                    mplot = plot(xVal,infoDistRsp.(groupNames{grp}){resp,cond}(:,1:end)',...
                         'LineWidth', 1,'Color',plotcol(cond,:));
                    sU = movmean(nanmean(rspMeans.(groupNames{grp}){resp,cond}),50) ...
                        + movmean(nanstd(rspMeans.(groupNames{grp}){resp,cond}),50)/...
                        size(rspMeans.(groupNames{grp}){resp,cond},1);
                    sD = movmean(nanmean(rspMeans.(groupNames{grp}){resp,cond}),50) ...
                        - movmean(nanstd(rspMeans.(groupNames{grp}){resp,cond}),50)/...
                        size(rspMeans.(groupNames{grp}){resp,cond},1);
                    sumzero = sum(sU==0);
                    sumnan = sum(isnan(sU));
                    jbfill(xVal(sumnan+sumzero+1:end),  sU(sumnan+sumzero+1:end), ...
                        sD(sumnan+sumzero+1:end),plotcol(cond,:),plotcol(cond,:));
                end
            end
        end
    end
    for i = 1:8
        subplot(2,4, i);
        if sync == 1
            line([5 5], get(gca, 'YLim'), 'Color', 'k', 'LineStyle', '--','HandleVisibility','off')
            for j = 1:ceil(numel(xLine)/2)
                line([5+xLine(j) 5+xLine(j)], get(gca, 'YLim'), ...
                    'Color', 'k', 'LineStyle', '--','HandleVisibility','off')
            end
        else
            line([15 15], get(gca, 'YLim'), 'Color', 'k', 'LineStyle', '--','HandleVisibility','off')
        end
        
    end
    
    supertitle(strcat('information content - ', syncs{sync}))
end


Folder = pwd;   % Your destination folder
AllFigH = allchild(groot);
for iFig = 1:numel(AllFigH)
  fig = AllFigH(iFig);
  ax  = fig.CurrentAxes;
  ax.FontSize = 17;
  fig.PaperUnits = 'centimeter';
  fig.PaperPosition = [0 0 29.7 21];
  FileName = char(strcat(fig.Children(1).Title.String, '.png'));
  saveas(fig, fullfile(Folder, FileName));
end



%             xticks(0:5:25); % tick marks on x-axis
%             xticklabels({'0','5','10','15','20','25'}); % tick labels on x-axis
%             xlabel('Time (s)'); % x-axis label
%             if resp == 1
%                 ylabel('dF/F'); % y-axis label'
%             end
%             title(resps{resp}); % subplot title
%             
%             % x-axis limits. Test if it's a vSD or vITI session to decide
%             % what the limits should be
%             if strcmp(cN,'var iti')
%                 xlim([0 25]); % x limit according fit to trace
%             else
%                 if sync == 1
%                     xlim([0 15])
%                 else
%                     xlim([5 20])
%                 end
%             end
%             if resp == 4
%                 subplot(2,4, (grp-1)*4+resp)
%                 legend(mplot(1:numel(condNames)),condNames);
%             end
%             hold on
%             
%             
%            
%         end
% 
%     end
%     
%     % Makes sure axes are same size
%     linkaxes(ax,'y');
%     %     legend(mplot,groupNames)
%     
%     % Lines indicating trial start/nose poke response, and/or cue lights
%     for i = 1:size(ax,2)
%         subplot(2,4, i);
%         if sync == 1
%             line([5 5], get(gca, 'YLim'), 'Color', 'k', 'LineStyle', '--','HandleVisibility','off')
%             for j = 1:ceil(numel(xLine)/2)
%                 line([5+xLine(j) 5+xLine(j)], get(gca, 'YLim'), ...
%                     'Color', plotcol(j,:), 'LineStyle', '--','HandleVisibility','off')
%             end
%         else
%             line([15 15], get(gca, 'YLim'), 'Color', 'k', 'LineStyle', '--','HandleVisibility','off')
%         end
%         
%     end
%     
%     
% 
%     
%     
%     % Plot title
%         suptitle('Group Comparison - means per condition');
%     
%     
% end
