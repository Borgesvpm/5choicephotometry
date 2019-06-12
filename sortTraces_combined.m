function [sortedData,ctData] = sortTraces_combined(combinedData)
%% Sort data based on ITI / SD
%
% In:
% combinedData - struct with all traces and trace metadata
%
% Out:
% sortedData - struct with fields:
%   .(rat)
%       .(ITI/SD/fixed)
%       .(trialstart)
%
%
%
%

% Define rat names
ratNames = fieldnames(combinedData);

% Define sync names
syncNames = {'startSync'; 'respSync'};

% Define names for struct subfields
try
    if size(combinedData.(ratNames{1}).trialstart{1, 1})>3
        if mean(combinedData.(ratNames{1}).trialstart{1,1}(:,4))>1
            conditionNames = {'longITI'; 'midITI'; 'shortITI'};
            conditionSpecs = [12.5 7.5 5];
        else
            conditionNames = {'shortSD'; 'midSD'; 'longSD'};
            conditionSpecs = [0.2; 0.5; 1];
        end
    else
        conditionNames = {'fixedITI'};
    end
catch
    conditionNames = {'fixedITI'};
end

% Distribute data in proper fields

for sync = 1:2
    % Distinguish between sync @ triastart and response
    for rat = 1:size(fieldnames(combinedData),1)
        % Loop through rats
        
        trialSpecs = vertcat(combinedData.(ratNames{rat}).trialstart{:});
        traces = vertcat(combinedData.(ratNames{rat}).(syncNames{sync}){:});
        bWins = vertcat(combinedData.(ratNames{rat}).baseWin{:});
        
        % Sort by consecutive trials
        % correct trials after errors
        for rsp = 0:3 
            ctData.(syncNames{sync}).(ratNames{rat}).corrAfter{rsp+1}= ...
                traces([0;diff(trialSpecs(:,3))==-rsp] & trialSpecs(:,3)==1,:);
        end        
        
        % trial after condition
        trMatch = [0; trialSpecs(1:end-1,4)]; % matches previous trials with current trials
        for cond = 1:size(conditionNames,1)
            for rsp = 1:4
                ctData.(syncNames{sync}).(ratNames{rat}).afterDiff{cond,rsp} = ...
                    traces(trMatch == conditionSpecs(cond) & trialSpecs(:,3)==rsp,:);
            end
        end
        
        for cond = 1:size(conditionNames,1)
            % Loop through trial type (ITI/SD/fixed)
            
            if size(conditionNames,1)>1
                % Group trials based on trial type
                % Only for varSD / varITI trials
               
                condTraces = traces(trialSpecs(:,4)==conditionSpecs(cond),:);
                condSpecs = trialSpecs(trialSpecs(:,4)==conditionSpecs(cond),:);
                condbWins = bWins(trialSpecs(:,4)==conditionSpecs(cond),:);
                
                % Sort by response type
                for resp = 1:4
                    sortedData.(syncNames{sync}).(conditionNames{cond}).(ratNames{rat}){resp}...
                        = condTraces(condSpecs(:,3)==resp,:);
                    
                end
                sortedData.(syncNames{sync}).(conditionNames{cond}).(ratNames{rat}){5}...
                    = [condSpecs,condbWins];
                
            else
                % Group trials based on response type in fixed ITI sessions
                trialSpecs = vertcat(combinedData.(ratNames{rat}).trialstart{:});
                traces = vertcat(combinedData.(ratNames{rat}).(syncNames{sync}){:});
                bWins = vertcat(combinedData.(ratNames{rat}).baseWin{:});
                for resp = 1:4
                    sortedData.(syncNames{sync}).(conditionNames{cond}).(ratNames{rat}){resp}...
                        = traces(trialSpecs(:,3)==resp,:);
                end
                sortedData.(syncNames{sync}).(conditionNames{cond}).(ratNames{rat}){5}...
                    = [trialSpecs, bWins];
                
            end
            
        end
        
    end
    
end
