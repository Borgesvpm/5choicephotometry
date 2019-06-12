%% single session data trace fig
plotcol = [0.47 0.67 0.19; 0.85 0.33 0.1; 0 0.45 0.74; 0.64 0.08 0.18];
figure
for i = 1:size(sessionData.trialstart,1)
    line([sessionData.trialstart(i,1)*101.73 sessionData.trialstart(i,1)*101.73],[-15 30],...
        'Color', 'k', 'LineWidth', 1, 'LineStyle', '--')
    patch([sessionData.trialstart(i,1)*101.73 (sessionData.trialstart(i,1)+5)*101.73...
        (sessionData.trialstart(i,1)+5)*101.73 sessionData.trialstart(i,1)*101.73],...
        [-15 -15 30 30],'y', 'EdgeColor', 'none', 'FaceAlpha', 0.2)
end
hold on
plot(movmean(sessionData.adjCaSig,25), 'Color', plotcol(1,:), 'LineWidth', 3)
line([0 numel(sessionData.adjCaSig)], [0 0], 'Color', 'k', 'LineStyle', ':')
xlim([110000 110000+180*101.73])
ylim([-15 30])
ylabel('dF/F','FontSize', 14, 'FontWeight', 'bold')
set(gca,'FontWeight','bold');
set(gca,'YTickLabel',a,'FontSize',18)
set(gca,'box','off','xcolor','w')
title('3 minute example','FontSize', 18)

%% single trial data trace fig
plotcol = [0.47 0.67 0.19; 0.85 0.33 0.1; 0 0.45 0.74; 0.64 0.08 0.18];
figure
for i = 1:size(sessionData.trialstart,1)
    line([sessionData.trialstart(i,1)*101.73 sessionData.trialstart(i,1)*101.73],[-15 30],...
        'Color', 'k', 'LineWidth', 1, 'LineStyle', '--')
    patch([sessionData.trialstart(i,1)*101.73 (sessionData.trialstart(i,1)+5)*101.73...
        (sessionData.trialstart(i,1)+5)*101.73 sessionData.trialstart(i,1)*101.73],...
        [-15 -15 30 30],'y', 'EdgeColor', 'none', 'FaceAlpha', 0.2)
end
hold on
plot(movmean(sessionData.adjCaSig,25), 'Color', plotcol(1,:), 'LineWidth', 3)
line([0 numel(sessionData.adjCaSig)], [0 0], 'Color', 'k', 'LineStyle', ':')
    line([sessionData.trialstart(40,2)*101.73 sessionData.trialstart(40,2)*101.73],[-15 30],...
        'Color', 'b', 'LineWidth', 1, 'LineStyle', '--')
    line([(sessionData.trialstart(40,1)+5)*101.73 (sessionData.trialstart(40,1)+5)*101.73],[-15 30],...
        'Color', 'k', 'LineWidth', 1, 'LineStyle', '--')
xlim([sessionData.trialstart(40,1)*101.73-5*101.73 sessionData.trialstart(40,1)*101.73+10*101.73])
ylim([-15 30])
ylabel('dF/F','FontSize', 14, 'FontWeight', 'bold')
set(gca,'FontWeight','bold');
set(gca,'YTickLabel',a,'FontSize',18)
set(gca,'box','off','xcolor','w')
title('Single trial example','FontSize', 18)

%% single session trials fig
figure
colormap(jet)
subplot(2,2,1)
imagesc(sessionData.startSync(sessionData.trialstart(:,3)==1,:))
ylabel('trials','FontSize', 14, 'FontWeight', 'bold')
subplot(2,2,2)
imagesc(sessionData.respSync(sessionData.trialstart(:,3)==1,:))
ylabel('trials','FontSize', 14, 'FontWeight', 'bold')

subplot(2,2,3)
plot(movmean(nanmean(sessionData.startSync(sessionData.trialstart(:,3)==1,:)),25), 'LineWidth', 2)
X = sessionData.startSync(sessionData.trialstart(:,3)==1,:);
hold on
su = movmean(nanmean(X),25) + movmean(nanstd(X),5)/sqrt(size(X,1));
sd = movmean(nanmean(X),25) - movmean(nanstd(X),5)/sqrt(size(X,1));
jbfill(1:numel(su), su, sd)
ylabel('dF/F','FontSize', 14, 'FontWeight', 'bold')
% xlabel('Time (s)')
set(gca,'box','off','xcolor','w')
ylim([-6 6])
line([0 2545], [0 0], 'LineStyle', ':', 'Color', 'k')


subplot(2,2,4)
plot(movmean(nanmean(sessionData.respSync(sessionData.trialstart(:,3)==1,:)),25), 'LineWidth', 2)
X = sessionData.respSync(sessionData.trialstart(:,3)==1,:);
hold on
su = movmean(nanmean(X),25) + movmean(nanstd(X),5)/sqrt(size(X,1));
sd = movmean(nanmean(X),25) - movmean(nanstd(X),5)/sqrt(size(X,1));
jbfill(1:numel(su), su, sd)
ylabel('dF/F')
ylim([-6 6])
% xlabel('Time (s)')
set(gca,'box','off','xcolor','w')
line([0 2545], [0 0], 'LineStyle', ':', 'Color', 'k')

for i = 1:4
    subplot(2,2,i) 
    xticks(0:5*101.73:25*101.73);
    set(gca, 'FontSize', 18)
    if i == 1 || i == 3
        xlim([0 1500])
        title('Synced at trialstart', 'FontSize', 18)
        line([5*101.73 5*101.73], get(gca, 'YLim'), 'Color', 'k', 'LineStyle', '--','HandleVisibility','off')
        line([10*101.73 10*101.73], get(gca, 'YLim'), 'Color', 'k', 'LineStyle', '--','HandleVisibility','off')
    xticklabels({'-5', '0','5','10','15','20'}); % tick labels on x-axis
        
    else
        xlim([500 2000])
        title('Synced at response', 'FontSize', 18)
        line([15*101.73 15*101.73], get(gca, 'YLim'), 'Color', 'k', 'LineStyle', '--','HandleVisibility','off')
        xticklabels({'-15', '-10', '-5', '0','5','10'}); % tick labels on x-axis
    end
    
end
    


%% single session trials fig
figure
subplot(2,2,1)
imagesc(sessionData.startSync(sessionData.trialstart(:,3)==1,:))
subplot(2,2,2)
imagesc(sessionData.respSync(sessionData.trialstart(:,3)==1,:))
for i = 1:4
subplot(2,2,3)
plot(movmean(nanmean(sessionData.startSync(sessionData.trialstart(:,3)==i,:)),50), 'LineWidth', 2)
X = sessionData.startSync(sessionData.trialstart(:,3)==i,:);
su = movmean(nanmean(X),50) + movmean(nanmean(X),50)/size(X,1);
sd = movmean(nanmean(X),50) - movmean(nanmean(X),50)/size(X,1);
jbfill(1:numel(su), su, sd, plotcol(i,:), plotcol(i,:))
hold on
subplot(2,2,4)
plot(movmean(nanmean(sessionData.respSync(sessionData.trialstart(:,3)==i,:)),50), 'LineWidth', 2)
X = sessionData.respSync(sessionData.trialstart(:,3)==i,:);
su = movmean(nanmean(X),50) + movmean(nanmean(X),50)/size(X,1);
sd = movmean(nanmean(X),50) - movmean(nanmean(X),50)/size(X,1);
jbfill(1:numel(su), su, sd, plotcol(i,:), plotcol(i,:))
hold on
end

for i = 1:4
    subplot(2,2,i) 
    if i == 1 || i == 3
        xlim([0 1500])
        title('Synced at trialstart')
        line([5*101.73 5*101.73], get(gca, 'YLim'), 'Color', 'k', 'LineStyle', '--','HandleVisibility','off')
        line([10*101.73 10*101.73], get(gca, 'YLim'), 'Color', 'k', 'LineStyle', '--','HandleVisibility','off')
    else
        xlim([500 2000])
        title('Synced at response')
        line([15*101.73 15*101.73], get(gca, 'YLim'), 'Color', 'k', 'LineStyle', '--','HandleVisibility','off')
    end
    
end

%% trials in heat plot
rsptypes={'correct', 'incorrect', 'omission', 'premature'};

figure
colormap(jet)
subplot(3,4,1:4)
imagesc(movmean(sessionData.startSync,10,2))
xlim([5*101.73 20*101.73])
caxis([-3 8])
ylabel('Trials')
xt=get(gca, 'XTick');
set(gca, 'XTick', xt, 'XTickLabel', xt/100-10);
xlabel('Time (s)')
yL = get(gca, 'YLim');
line([10*101.73 10*101.73],yL,'Color','m', 'LineWidth', 2);
line([15*101.73 15*101.73],yL,'Color','m', 'LineWidth', 2);
colorbar
for i = 1:4
    subplot(3,4,i+4)
    imagesc(movmean(sessionData.startSync(sessionData.trialstart(:,3)==i,:),10,2))
    xlim([5*101.73 20*101.73])
    caxis([-3 8])
    ylabel('Trials')
    xt=get(gca, 'XTick');
    set(gca, 'XTick', xt, 'XTickLabel', xt/100-10);
    xlabel('Time (s)')
    yL = get(gca, 'YLim');
    line([10*101.73 10*101.73],yL,'Color','m', 'LineWidth', 2);
    line([15*101.73 15*101.73],yL,'Color','m', 'LineWidth', 2);
    title(rsptypes{i})
    
    subplot(3,4,i+8)
    plot(nanmean(sessionData.startSync(sessionData.trialstart(:,3)==i,:)), 'LineWidth',2)
    if i>1
        hold on
        plot(nanmean(sessionData.startSync(sessionData.trialstart(:,3)==1,:)),'k', 'LineWidth',2)
    end
    xlim([5*101.73 20*101.73])
    ylabel('avg Z-score')
    xt=get(gca, 'XTick');
    set(gca, 'XTick', xt, 'XTickLabel', xt/100-10);
    xlabel('Time (s)')
    line([10*101.73 10*101.73],[-20 20],'Color','m', 'LineWidth', 2);
    line([15*101.73 15*101.73],[-20 20],'Color','m', 'LineWidth', 2);
    ylim([-6 6])

end

supertitle('Single session activity - DS-projecting neurons', 'FontSize', 28);

% %% proportion of trials > certain threshold
% figure
% colormap(hot)
% thresholdZ=2;
% for  i = 1:4
%     subplot(2,4,i)
%     imagesc(sessionData.startSync(>thresholdZ)
%     line([1000 1000], [-1 1], 'Color', 'm')
%     line([1500 1500], [-1 1], 'Color', 'm')
%     xlim([500 2000])
%     ylabel('Trials')
%     xt=get(gca, 'XTick');
%     set(gca, 'XTick', xt, 'XTickLabel', xt/100-10);
%     xlabel('Time (s)')
%     yL = get(gca, 'YLim');
%     line([1000 1000],yL,'Color','m', 'LineWidth', 2);
%     line([1500 1500],yL,'Color','m', 'LineWidth', 2); 
%     
%     subplot(2,4,i+4)
%     hold on 
% %     if i>1
% %         plot(sum(sessionData.traces.responseTypes{1}>1)/...
% %         size(sessionData.traces.responseTypes{1},1),'.k',...
% %     'MarkerSize', 0.2)
% %     plot((-1*sum(sessionData.traces.responseTypes{1}<-1))/...
% %         size(sessionData.traces.responseTypes{1},1),'.k',...
% %     'MarkerSize', 0.2)
% %     end
%     plot(sum(sessionData.traces.responseTypes{i}>thresholdZ)/...
%         size(sessionData.traces.responseTypes{i},1))
%     plot((-1*sum(sessionData.traces.responseTypes{i}<-thresholdZ))/...
%         size(sessionData.traces.responseTypes{i},1))
%     line([500 2500], [0 0], 'Color', 'k')
% 
%     line([1000 1000], [-1 1], 'Color', 'm')
%     line([1500 1500], [-1 1], 'Color', 'm')
%         ylabel({'Proportion of trials';'>2STD above baseline'})
%     xt=get(gca, 'XTick');
%     set(gca, 'XTick', xt, 'XTickLabel', xt/100-10);
%     xlabel('Time (s)')
%     yL = get(gca, 'YLim');
%     line([1000 1000],yL,'Color','m', 'LineWidth', 2);
%     line([1500 1500],yL,'Color','m', 'LineWidth', 2); 
% 
%     xlim([500 2000])
%     ylim([-1 1])
%     title(rsptypes{i}, 'FontSize', 16)
%     
% end
% shg
% 
% supertitle('Single session activity - MDL-projecting neurons', 'FontSize', 28);
% 
% %%
% figure
% colormap(hot)
% Z=10+sessionData.traces.responseTypes{1}*5;
% s=surf(Z);
% s.EdgeColor='none';
% hold on
% imagesc(Z)
% xlim([500 2000])
% 
% 
% %%
% figure
% colormap(hot)
% subplot(1,2,1)
% Z=10+movmean(sessionData.errCor,100,2);
% s=surf(Z);
% s.EdgeColor='none';
% hold on
% imagesc(Z)
% xlim([500 2000])
% 
% subplot(1,2,2)
% Z=10+movmean(sessionData.corCor,100,2);
% s=surf(Z);
% s.EdgeColor='none';
% hold on
% imagesc(Z)
% xlim([500 2000])
