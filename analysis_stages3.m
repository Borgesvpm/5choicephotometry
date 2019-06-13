function analysis_stages3
%% Stages analysis script
% This will take run through all rats consecutively, and return a data
% struct for each rat, containing fields with traces from every stage


%%
% Get all rat names
sessions = dir('*g*m*'); % be at the proper folder if you want to do this
currentDir = pwd;

x = rand(1,5);

sessions = sessions([sessions.isdir]);

% Determine group names
for k = 1 : length(sessions)
    cellContents = sessions(k).name;
    % Truncate and stick back into the cell
    ratNames{k} = cellContents(1:4);
end
ratNames = unique(ratNames); %ratNames is a cell array with all rat names


for rat = 1:numel(ratNames)
    
    % list all sessions from rat
    ratSessions = dir(strcat('*', ratNames{rat}, '*'));
    ratSessions = ratSessions([ratSessions.isdir]);
    
    % list all mat files in folder
    allFiles = dir('*.mat');
    matFiles = {allFiles(1:end).name};
    
    % create filename
    fn = strcat(ratNames{rat}, '_allstages.mat');
    
    % print rat name
    fprintf('%s\n',char(strcat({'Processing... Rat '}, num2str(rat),{'/'},...
        num2str(size(ratNames,2)),{' - '}, ratNames{rat})))

    
    % check if session isn't already analyzed
    if sum(contains(matFiles, fn))==0
        
        % generate structure for rat
        stageData = struct();

        % loop through all sessions from a rat
        for sess = 1:numel(ratSessions)
            
            % retrieve and print session name that's analyzed
            path_to_data=[currentDir '\' ratSessions(sess).name];
            fprintf('%s\n',char(strcat({'Processing... Session '}, num2str(sess),{'/'},...
                num2str(size(ratSessions,1)),{'. Current data file: '},...
                ratSessions(sess).name)))
            
            % retrieve stage
            sessStage = path_to_data(end-1:end);
            
            % run preprocessing and sorting
            sessionData = photometry_complete_stages(path_to_data);
            
            % 
            if isfield(stageData, sessStage) 
                stageData.(sessStage).startSync = [stageData.(sessStage).startSync;sessionData.startSync];
                stageData.(sessStage).respSync = [stageData.(sessStage).respSync;sessionData.respSync];
                stageData.(sessStage).trialstart = [stageData.(sessStage).trialstart;sessionData.trialstart];
                stageData.(sessStage).baseWin = [stageData.(sessStage).baseWin;sessionData.baseWin];
            else
                stageData.(sessStage).startSync = sessionData.startSync; 
                stageData.(sessStage).respSync = sessionData.respSync; 
                stageData.(sessStage).trialstart = sessionData.trialstart; 
                stageData.(sessStage).baseWin = sessionData.baseWin; 
            end
        end
        
        
        
    save(fn, 'stageData')
    fprintf('%s\n',char(strcat({'Saved file as: '}, fn)));
    
    end
    
end
        



end
