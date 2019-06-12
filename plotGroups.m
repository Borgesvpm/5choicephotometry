function plotGroups(trtMeans,rspMeans, allrspT, sortedData)

plotcol = [0.47 0.67 0.19; 0.85 0.33 0.1; 0 0.45 0.74; 0.64 0.08 0.18];
% plotcol = jet(6);

syncs = fieldnames(sortedData);
condNames = fieldnames(sortedData.(syncs{1}));
ratNames = fieldnames(sortedData.(syncs{1}).(condNames{1}));
groupNames = fieldnames(trtMeans);
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

%% Compare conditions
for sync = 1:2
    figure
    for cond = 1:3
        
        for rsp = 1:2
            %% Subplot row 1 + 2
            resp = rsp^2; %Careful, this is now only for Cor+prem
            ax(cond) = subplot(3,3, resp-1+cond);
            %             ax(resp) = subplot(1,4,1+2*(resp-1):1+(1+2*(resp-1)));
            xVal = (1:size(trtMeans.(groupNames{1}){resp,cond},2))/101.73; % convert frames to seconds
            
            for grp = 1:size(groupNames,1)
                hold on
                if sync == 1
                    mplot(grp) = plot(xVal,movmean(nanmean(trtMeans.(groupNames{grp}){resp,cond}),...
                        50), 'LineWidth', 2,'Color',plotcol(grp,:));
                    sU = movmean(nanmean(trtMeans.(groupNames{grp}){resp,cond}),50) ...
                        + movmean(nanstd(trtMeans.(groupNames{grp}){resp,cond}),50)/...
                        size(trtMeans.(groupNames{grp}){resp,cond},1);
                    sD = movmean(nanmean(trtMeans.(groupNames{grp}){resp,cond}),50) ...
                        - movmean(nanstd(trtMeans.(groupNames{grp}){resp,cond}),50)/...
                        size(trtMeans.(groupNames{grp}){resp,cond},1);
                    sumzero = sum(sU==0);
                    sumnan = sum(isnan(sU));
                    jbfill(xVal(1:(end-sumzero-sumnan-1)),  sU(1:(end-sumzero-sumnan-1)), sD(1:(end-sumzero-sumnan-1)),plotcol(grp,:),plotcol(grp,:));

%                     jbfill(xVal(1:sumnan-1),  sU(sU~=0), sD(sD~=0),plotcol(grp,:),plotcol(grp,:));
                    
                else
                    mplot(grp) = plot(xVal,movmean(nanmean(rspMeans.(groupNames{grp}){resp,cond}),...
                        50), 'LineWidth', 2,'Color',plotcol(grp,:));
                    sU = movmean(nanmean(rspMeans.(groupNames{grp}){resp,cond}),50) ...
                        + movmean(nanstd(rspMeans.(groupNames{grp}){resp,cond}),50)/...
                        size(rspMeans.(groupNames{grp}){resp,cond},1);
                    sD = movmean(nanmean(rspMeans.(groupNames{grp}){resp,cond}),50) ...
                        - movmean(nanstd(rspMeans.(groupNames{grp}){resp,cond}),50)/...
                        size(rspMeans.(groupNames{grp}){resp,cond},1);
                    sumzero = sum(sU==0);
                    sumnan = sum(isnan(sU));
                    jbfill(xVal(sumnan+sumzero+1:end),  sU(sumnan+sumzero+1:end), sD(sumnan+sumzero+1:end),plotcol(grp,:),plotcol(grp,:));
                end
            end
            xticks(0:5:25); % tick marks on x-axis
            xticklabels({'0','5','10','15','20','25'}); % tick labels on x-axis
            xlabel('Time (s)'); % x-axis label
            ylabel('dF/F'); % y-axis label'
            
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
            if cond == 3
                subplot(3,3,cond*rsp)
                legend(mplot(1:numel(groupNames)),groupNames);
            end
            hold on
            
            
           
        end
        %% Premature response times
        for grp = 1:size(groupNames,1)
            hold on
            subplot(3,3, 6+cond)
            binEdges = 0:xLine(cond)/(xLine(cond)*2):xLine(cond);
            h = histogram(allrspT.(groupNames{grp}){4,cond},binEdges, 'EdgeColor', 'none', ...
                'FaceColor', plotcol(grp,:), 'FaceAlpha', 0.2,'Normalization','probability');
            hold on
            plot(binEdges(2:end)-(binEdges(2)-binEdges(1))/2, movmean(h.Values,2),...
                'LineWidth', 2, 'Color', plotcol(grp,:))
%             plot(movmean(
            xlim([0 xLine(cond)])
            title('Premature response times')
            ylabel('Proportion prematures')
            xlabel('Time (s)')
        end
        
    end
    
    % Makes sure axes are same size
    linkaxes(ax,'y');
%         legend(mplot,groupNames)
    
    % Lines indicating trial start/nose poke response, and/or cue lights
    for i = 1:size(condNames,1)*2
        subplot(3,3, i);
%         if i <7
%             ylim([-5 5])
%         end
        %         subplot(1,4,1+2*(i-1):1+(1+2*(i-1)));
        if sync == 1
            line([5 5], get(gca, 'YLim'), 'Color', 'k', 'LineStyle', '--','HandleVisibility','off')
            line([5+xLine(i) 5+xLine(i)], get(gca, 'YLim'), ...
                'Color', plotcol(ceil(i/2),:), 'LineStyle', '--','HandleVisibility','off')
            %            for lin = 1: size(condNames,1)
            %             end
        else
            line([15 15], get(gca, 'YLim'), 'Color', 'k', 'LineStyle', '--','HandleVisibility','off')
        end
        
        
        
        
    end
    
    

    
    
    % Plot title
        supertitle(strcat('Group Comparison - means per resptype -', syncs{sync}));
    
    
end


%% Compare response types
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
           
            
            ax(resp) = subplot(3,4, (grp-1)*4+resp);
            xVal = (1:size(trtMeans.(groupNames{1}){resp,cond},2))/101.73; % convert frames to seconds
            
            for cond = 1:size(condNames,1)
                hold on
                if sync == 1
                    mplot(cond) = plot(xVal,movmean(nanmean(trtMeans.(groupNames{grp}){resp,cond}),...
                        50), 'LineWidth', 2,'Color',plotcol(cond,:));
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
                    mplot(cond) = plot(xVal,movmean(nanmean(rspMeans.(groupNames{grp}){resp,cond}),...
                        50), 'LineWidth', 2,'Color',plotcol(cond,:));
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
            xticks(0:5:25); % tick marks on x-axis
            xticklabels({'0','5','10','15','20','25'}); % tick labels on x-axis
            xlabel('Time (s)'); % x-axis label
            if resp == 1
                ylabel('norm dF/F'); % y-axis label'
            end
            title(strcat(groupNames{grp}, {' - '}, resps{resp})); % subplot title
            
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
            if resp == 4
                subplot(3,4, grp*resp)
                legend(mplot(1:numel(condNames)),condNames);
            end
            hold on
            
            
           
        end
        %% Response times
%         for grp = 1:size(groupNames,1)
%             hold on
%             subplot(3,4, 2*4+resp)
%             binEdges = 0:xLine(cond)/(xLine(cond)*2):xLine(cond);
%             h = histogram(allrspT.(groupNames{grp}){resp,cond},binEdges, 'EdgeColor', 'none', ...
%                 'FaceColor', plotcol(grp,:), 'FaceAlpha', 0.2,'Normalization','probability');
%             hold on
%             plot(binEdges(2:end)-(binEdges(2)-binEdges(1))/2, movmean(h.Values,2),...
%                 'LineWidth', 2, 'Color', plotcol(grp,:))
% %             plot(movmean(
%             xlim([0 xLine(cond)])
%         end
        
    linkaxes(ax,'y');
    end
    
    % Makes sure axes are same size
%         legend(mplot,groupNames)
    
    % Lines indicating trial start/nose poke response, and/or cue lights
    for i = 1:12
        subplot(3,4, i);
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
    
    

    
    
    % Plot title
    supertitle(strcat('Group Comparison - means per condition - ', syncs{sync}));
    
    
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


end
