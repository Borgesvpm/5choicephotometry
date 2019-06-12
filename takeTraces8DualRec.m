%% Alternative standardization of data
function sessionData = takeTraces8DualRec(rawData, sessionData)
%% cut out traces from the raw data file
% This will take traces from the original dF/F signal
% Traces are being cut around trialstart and response, leaving open a small
% window around either
% Window sizes can be defined here:

finalMedTraces = []; baseWin = [];

for rsp = 1:2
    for trial = 1:size(sessionData.trialstart,1)
        
        % Determine trial start timings
        Trt = ceil(sessionData.trialstart(trial,1)*rawData.adjConversion);
        Rsp = ceil(sessionData.trialstart(trial,2)*rawData.adjConversion);
        if rsp == 1
            trcStart = ceil(Trt)-ceil(5*rawData.adjConversion);
            trcEnd = ceil(Trt)+ceil(20*rawData.adjConversion);
        elseif rsp == 2
            trcStart = ceil(Rsp)-ceil(15*rawData.adjConversion);
            trcEnd = ceil(Rsp)+ceil(10*rawData.adjConversion);
        end
        
        % Take baseline windows
        bWin = ceil(Trt)-ceil(3*rawData.conversion):ceil(Trt)-ceil(2*rawData.conversion);
        if bWin(1) < 0
            try
                bWin = bWin(bWin>0);
            catch
                bWin = ceil(ceil(sessionData.trialstart(trial+1,1)*rawData.adjConversion))...
                    -ceil(3*rawData.conversion)...
                    :ceil(ceil(sessionData.trialstart(trial+1,1)*rawData.adjConversion))...
                    -ceil(2*rawData.conversion);
            end
        end
        baseWin(trial,1) = mean(sessionData.adjCaSig(bWin));
        baseWin(trial,2) = std(sessionData.adjCaSig(bWin));
        
        
        % Clear next trial from traces
        if trial < size(sessionData.trialstart,1)
            if trcEnd > ceil((sessionData.trialstart(trial+1,1)-2)*rawData.adjConversion)
                nanWindowE = trcEnd - ceil((sessionData.trialstart(trial+1,1)-2)*rawData.adjConversion);
                trcEnd = ceil((sessionData.trialstart(trial+1,1)-2)*rawData.adjConversion);
            else
                nanWindowE = 0;
            end
        else
            nanWindowE = 0;
        end
        
        if trial > 1
            if trcStart < ceil((sessionData.trialstart(trial-1,2)+3)*rawData.adjConversion)
                nanWindowS = trcStart - ceil((sessionData.trialstart(trial-1,2)+3)*rawData.adjConversion);
                trcStart = ceil((sessionData.trialstart(trial-1,2)+3)*rawData.adjConversion);
                
            else
                nanWindowS = 0;
            end
        else
            nanWindowS = 0;
        end
        
        % Take trace
        if trcStart<0
            finalMedTraces(trial,:) = [nan(abs(trcStart)+1,1); nan(nanWindowS,1); sessionData.adjCaSig(1:trcEnd); nan(nanWindowE,1)];
            
        elseif trcEnd>(numel(sessionData.adjCaSig))
            finalMedTraces(trial,:) = [nan(nanWindowS,1); sessionData.adjCaSig(trcStart:numel(sessionData.adjCaSig))...
                ;nan(trcEnd-numel(sessionData.adjCaSig),1); nan(nanWindowE,1)];
        else
            finalMedTraces(trial,:) = [nan(abs(nanWindowS),1); sessionData.adjCaSig(trcStart:trcEnd); nan(nanWindowE,1)];
        end
        
        
    end
    
    if rsp ==1
        sessionData.startSync = finalMedTraces;
    elseif rsp==2
        sessionData.respSync = finalMedTraces;
    end
    
    sessionData.baseWin = baseWin;
    
end

%% plots
 figure
 
 % Plots of different response types in the session, split by
 % synchronization moment (either start or nosepoke response)
for i = 1:4
        
    subplot(4,4,i)
    imagesc(sessionData.startSync(sessionData.trialstart(:,3)==i,:))
    xlim([0 1500]);

    subplot(4,4,4+i)
    plot(nanmean(sessionData.startSync(sessionData.trialstart(:,3)==i,:)))
    semUp = nanmean(sessionData.startSync(sessionData.trialstart(:,3)==i,:))...
        + nanstd(sessionData.startSync(sessionData.trialstart(:,3)==i,:))./...
        sqrt(size(sessionData.startSync(sessionData.trialstart(:,3)==i,:),1));
    semDown = nanmean(sessionData.startSync(sessionData.trialstart(:,3)==i,:))...
        - nanstd(sessionData.startSync(sessionData.trialstart(:,3)==i,:))./...
        sqrt(size(sessionData.startSync(sessionData.trialstart(:,3)==i,:),1));
    jbfill(1:numel(semUp),semUp,semDown);
    hold on
    
    if i > 1
        plot(nanmean(sessionData.startSync(sessionData.trialstart(:,3)==1,:)),'k')
        semUp = nanmean(sessionData.startSync(sessionData.trialstart(:,3)==1,:))...
            + nanstd(sessionData.startSync(sessionData.trialstart(:,3)==1,:))./...
            sqrt(size(sessionData.startSync(sessionData.trialstart(:,3)==1,:),1));
        semDown = nanmean(sessionData.startSync(sessionData.trialstart(:,3)==1,:))...
            - nanstd(sessionData.startSync(sessionData.trialstart(:,3)==1,:))./...
            sqrt(size(sessionData.startSync(sessionData.trialstart(:,3)==1,:),1));
        jbfill(1:numel(semUp),semUp,semDown,'k','k');
    end    
    xlim([0 1500]);
    
    subplot(4,4,2*4+i)
    imagesc(sessionData.respSync(sessionData.trialstart(:,3)==i,:))
     xlim([500 2000]);
   
    subplot(4,4,3*4+i)
    plot(nanmean(sessionData.respSync(sessionData.trialstart(:,3)==i,:)))
    semUp = nanmean(sessionData.respSync(sessionData.trialstart(:,3)==i,:))...
        + nanstd(sessionData.respSync(sessionData.trialstart(:,3)==i,:))./...
        sqrt(size(sessionData.respSync(sessionData.trialstart(:,3)==i,:),1));
    semDown = nanmean(sessionData.respSync(sessionData.trialstart(:,3)==i,:))...
        - nanstd(sessionData.respSync(sessionData.trialstart(:,3)==i,:))./...
        sqrt(size(sessionData.respSync(sessionData.trialstart(:,3)==i,:),1));
    jbfill(1:numel(semUp),semUp,semDown);
    xlim([500 2000]);
    hold on
    if i > 1
        plot(nanmean(sessionData.respSync(sessionData.trialstart(:,3)==1,:)),'k')
        semUp = nanmean(sessionData.respSync(sessionData.trialstart(:,3)==1,:))...
            + nanstd(sessionData.respSync(sessionData.trialstart(:,3)==1,:))./...
            sqrt(size(sessionData.respSync(sessionData.trialstart(:,3)==1,:),1));
        semDown = nanmean(sessionData.respSync(sessionData.trialstart(:,3)==1,:))...
            - nanstd(sessionData.respSync(sessionData.trialstart(:,3)==1,:))./...
            sqrt(size(sessionData.respSync(sessionData.trialstart(:,3)==1,:),1));
        jbfill(1:numel(semUp),semUp,semDown,'k','k');
     end    
    xlim([500 2000]);
    
    
end

    id1 = strfind(rawData.path_to_data, '\');
    suptitle(rawData.path_to_data(id1(end)+1:end));
% 
% % Figure
% Figure with ITIs or SDs separated
% Only works for vITI currently

if mean(sessionData.trialstart(:,4))>0
    
    if nanmean(sessionData.trialstart(:,4)>1)
        cats = [ 5 7.5 12.5];
    else
        cats = [1 0.5 0.2];
    end
    pos = [0 3 12 15];
    pos2 = [7 10 19 22];
    sync = {'startSync', 'respSync'};
    plotcol ={[0,0.4470,0.7410];[0.8500,0.3250,0.0980];[0.9290,0.6940,0.1250]};
    
    % Resp Types apart, ITIs
    
    for s = 1:2
        figure
        for i = 1:4
            for j = 1:3
                tmpTrc = sessionData.(sync{s})(sessionData.trialstart(:,3)==i & ...
                    sessionData.trialstart(:,4)==cats(j),:);
                subplot(4,6,j+pos(i))
                imagesc(tmpTrc)
                
                if s == 1
                    line([500 500],get(gca, 'YLim'), 'Color', 'b')
                    if mean(sessionData.trialstart(:,4)>1)
                        
                        line([(5+cats(j))*100 (5+cats(j))*100], get(gca, 'YLim'), 'Color', plotcol{j})
                    else
                        line([1000 1000], get(gca, 'YLim'), 'Color', plotcol{j})
                    end
                else
                    line([1500 1500],get(gca, 'YLim'), 'Color', 'b')
                end
                
                subplot(4,6, pos2(i):pos2(i)+2)
                plot(nanmean(tmpTrc))
                
                semUp = nanmean(tmpTrc) + nanstd(tmpTrc)./sqrt(size(tmpTrc,1));
                semDown = nanmean(tmpTrc) - nanstd(tmpTrc)./sqrt(size(tmpTrc,1));
                jbfill(1:numel(semUp),semUp,semDown,plotcol{j},plotcol{j});
                
                hold on
                xlim([0 2500])
                if s == 1
                    line([500 500],get(gca, 'YLim'), 'Color', 'b')
                    if mean(sessionData.trialstart(:,4)>1) 
                        line([(5+cats(j))*100 (5+cats(j))*100], get(gca, 'YLim'), 'Color', plotcol{j})
                    else
                        line([1000 1000], get(gca, 'YLim'), 'Color', plotcol{j})
                    end
                else
                    line([1500 1500],get(gca, 'YLim'), 'Color', 'b')
                end
            end
        end
    end
    
end


end