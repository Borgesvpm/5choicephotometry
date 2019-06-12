function compareGroups_plots(sortedData)

%% Group data according to experimental group
% This will also sort trials based on their response times (either premature
% responses or correct/incorrect latencies)

syncs = fieldnames(sortedData);
condNames = fieldnames(sortedData.(syncs{1}));
ratNames = fieldnames(sortedData.(syncs{1}).(condNames{1}));
resps = {'correct' 'incorrect' 'omission' 'premature'};
trtMeans = struct; rspMeans = struct; zTrtMeans = struct; zRspMeans = struct; 
xLine = [12.5  7.5  5 12.5 7.5 5];
allrspT =struct;

% Determine group names
for k = 1 : length(ratNames)
    cellContents = ratNames{k};
    % Truncate and stick back into the cell
    grpNames{k} = cellContents(1:3);
end
grpNames = unique(grpNames);

%% Plot conditions
for sync = 1:2
    for cond = 1:3
        for i = 1:4
        respTime=[];
            for j = 1:size(ratNames,1)
                
                %% Calculations 
                %
                %  
                %
                %
                %
                %
                %
                %% Assign rat to group
                for group = 1:size(grpNames,2)
                    if strcmp(ratNames{j,1}(1:3), grpNames(group))
                        grp = grpNames(group);
                    end
                end
                plotDat = sortedData.(syncs{sync}).(condNames{cond}).(ratNames{j}){1,i};
                
                trialDat = sortedData.(syncs{sync}).(condNames{cond}).(ratNames{j}){1,5};
                bMeans = trialDat(trialDat(:,3)==i,5);
                bStd = trialDat(trialDat(:,3)==i,6);
                
                % normalization
                normPD = (plotDat-prctile(plotDat,0.25,2))./(prctile(plotDat,99.75,2)-prctile(plotDat,0.25,2));
                normBM = (bMeans-prctile(plotDat,0.25,2))./(prctile(plotDat,99.75,2)-prctile(plotDat,0.25,2));
                normBS = bStd./(prctile(plotDat,99.75,2)-prctile(plotDat,0.25,2));

                plotDat = normPD; bMeans = normBM; bStd = normBS;
                %% Get response times
                %
                % arrangement of structure array: 
                % Long ITI  -  Mid ITI  -  Short ITI
                % Correct
                % Incorrect
                % Omission
                % Premature
                tmpRspTime = trialDat(trialDat(:,3)==i,1:2);
                respTime =tmpRspTime(:,2)-tmpRspTime(:,1);

                if isfield(allrspT, grp{1})
                    if i>size(allrspT.(grp{1}),1)
                        allrspT.(grp{1}){i,cond} = respTime;
                    elseif cond > size(allrspT.(grp{1}),2)
                        allrspT.(grp{1}){i,cond} = respTime;
                    else
                        allrspT.(grp{1}){i,cond} = [allrspT.(grp{1}){i,cond};respTime];
                    end
                    
                else
                    allrspT.(grp{1}){i,cond} = respTime;
                end

                
                
                %% Calculate means
                % Take means and sort by group
                % Nan premature responses 
                rspDat = [];
                
                if i < 4
                    if size(plotDat,1) > 1
                        tmpMean = nanmean(plotDat(1:end,:)-bMeans);
                    else
                        tmpMean = nan(1,2545);
                    end
                    
                    if sync == 1 
                        trtMeans.(grp{1}){i,cond}(j,:) = tmpMean;
                    else
                        rspMeans.(grp{1}){i,cond}(j,:) = tmpMean;
                    end
                  
                else
                    % This removes non-trial related premature responses
                    % from trialstart sync (everything after premature
                    % response nosepoke is NaN
                    %
                    % In case of response sync, it will remove everything
                    % before trialstart
                     if sync == 1
                        if size(plotDat,1)> 1
                            for tr = 1:size(plotDat,1)
                                % replace out of trial timings with nan
                                rspDat(tr,:) = [plotDat(tr, 1:508+ceil(respTime(tr)*101.73)), ...
                                    nan(1,2037 - ceil(respTime(tr)*101.73))];
                            end
                            % Add everything to structure with other data
                            trtMeans.(grp{1}){i,cond}(j,:) =  nanmean(rspDat(1:end,:)-bMeans);
                        else
                            trtMeans.(grp{1}){i,cond}(j,:) = nan(1,2545);
                        end
                        
                     else
                        % Response syncs
                        if size(plotDat,1)> 1
                            for tr = 1:size(plotDat,1)
                                % replace out of trial timings with nan
                                rspDat(tr,:) = [nan(1,508+floor((xLine(cond)-respTime(tr))*101.73)), ...
                                    plotDat(tr, 508 + ceil((xLine(cond)-respTime(tr))*101.73):end)];
                            end
                            
                            rspMeans.(grp{1}){i,cond}(j,:) = nanmean(rspDat(1:end,:)-bMeans);
                        else
                            rspMeans.(grp{1}){i,cond}(j,:) = nan(1,2545);
                        end
                    end
                end                   
                %% Take z-scores and only take significant bins
                
                % Take mean and std of raw traces
                % Take mean and std of baseline window in raw traces

                % arrangement of structure array:
                % Long ITI  -  Mid ITI  -  Short ITI
                % Correct
                % Incorrect
                % Omission
                % Premature

                
                if i <4 
                    % Everything but prematures
                    if sync == 1
                        if size(plotDat,1)> 1
                            zTrtMeans.(grp{1}){i,cond}(j,:) = sum((plotDat-bMeans)./bStd>2)...
                                /size(plotDat,1);
                        else
                            zTrtMeans.(grp{1}){i,cond}(j,:) = nan(1,2545);
                        end
                    else
                        if size(plotDat,1)> 1
                            zRspMeans.(grp{1}){i,cond}(j,:) =sum((plotDat-bMeans)./bStd>2)...
                                /size(plotDat,1);
                        else
                            zRspMeans.(grp{1}){i,cond}(j,:) = nan(1,2545);
                        end
                    end
                    
                else
                    % Prematures
                    
                     if sync == 1
                        if size(rspDat,1)> 1
                            zTrtMeans.(grp{1}){i,cond}(j,:) = sum((rspDat-bMeans)./bStd>2)...
                                /size(rspDat,1);
                        else
                            zTrtMeans.(grp{1}){i,cond}(j,:) = nan(1,2545);
                        end
                    else
                        if size(rspDat,1)> 1
                            zRspMeans.(grp{1}){i,cond}(j,:) =sum((rspDat-bMeans)./bStd>2)...
                                /size(rspDat,1);
                        else
                            zRspMeans.(grp{1}){i,cond}(j,:) = nan(1,2545);
                        end
                    end
                   
                end
                
                %% Information distance
                binsize = ceil(size(plotDat,2)/125);
                binnum = ceil((1:size(plotDat,2))/max(binsize));
                % fraction of bins
                binfrac = 1/max(binnum);
                H = []; binmean =[];
                for trial = 1:size(plotDat,1)
                    if sync == 1
                        binmean(trial,:) = accumarray(binnum(:), ...
                            plotDat(trial,1:end)',...
                            [],@nanmean);
                        % overall mean signal
%                         trMed = nanmean(plotDat(trial,:));
                        trMed = bMeans(trial,:);
                    else
                        binmean(trial,:) = accumarray(binnum(:), ...
                            plotDat(trial,1:end)',...
                            [],@nanmean);
                        trMed = nanmean(plotDat(trial,:));
%                         normalized with baseline w
                        trMed = bMeans(trial,:);
                    end
                    
                    for bin = 1:max(binnum)
                        if sync == 1
                            H(trial, bin)= abs(binfrac*binmean(trial,bin)*log2(binmean(trial,bin)/trMed));
                        else
                            H(trial, bin)= abs(binfrac*binmean(trial,bin)*log2(binmean(trial,bin)/trMed));
                        end
                    end
                    
                end
                
                if size(H,1)>1
                    if sync == 1
                        infoDist.(grp{1}){i,cond}(j,:) = nanmean(H);
                    else
                        infoDistRsp.(grp{1}){i,cond}(j,:) = nanmean(H);
                    end
                else
                    if sync == 1
                        infoDist.(grp{1}){i,cond}(j,:) = nan(1,max(binnum));
                    else
                        infoDistRsp.(grp{1}){i,cond}(j,:) = nan(1,max(binnum));
                    end
                end
                
                    
            end
        end
    end
end
%% Check for zeros
for numGroups = 1:size(grpNames,2)
    
    for numCells = 1:numel(trtMeans.(grpNames{numGroups}))
        
        trtMeans.(grpNames{numGroups}){numCells} = trtMeans.(grpNames{numGroups}){numCells}...
            (mean(trtMeans.(grpNames{numGroups}){numCells},2)~=0,:);
        rspMeans.(grpNames{numGroups}){numCells} = rspMeans.(grpNames{numGroups}){numCells}...
            (mean(rspMeans.(grpNames{numGroups}){numCells},2)~=0,:);
        zRspMeans.(grpNames{numGroups}){numCells} = zRspMeans.(grpNames{numGroups}){numCells}...
            (mean(zRspMeans.(grpNames{numGroups}){numCells},2)~=0,:);
        zTrtMeans.(grpNames{numGroups}){numCells} = zTrtMeans.(grpNames{numGroups}){numCells}...
            (mean(zTrtMeans.(grpNames{numGroups}){numCells},2)~=0,:);
        infoDist.(grpNames{numGroups}){numCells} = infoDist.(grpNames{numGroups}){numCells}...
            (mean(infoDist.(grpNames{numGroups}){numCells},2)~=0,:);
        infoDistRsp.(grpNames{numGroups}){numCells} = infoDistRsp.(grpNames{numGroups}){numCells}...
            (mean(infoDistRsp.(grpNames{numGroups}){numCells},2)~=0,:);
        
    end
    
end


end