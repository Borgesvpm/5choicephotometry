function batch_photometry
%% use this if you want to analyze a batch of experiments
% Specify which files you want analyzed first
% Example:
% sessions = dir('*mdl*) will select all sessions of mdl rats
% sessions = dir('*mdl*iti) will select all variable ITI sessions of mdl rats

sessions = dir('*-*'); % be at the proper folder if you want to do this
currentDir = pwd;

g=[sessions.isdir];
sessions = sessions(g);

allFiles = dir('*.mat');
matFiles = {allFiles(1:end).name};

% This will loop through all selected sessions to process them into usable
% data formats
% Will return a .mat file containing all relevant data
% Saves the .mat file into the current directory

for i=1:size(sessions,1)
    % Print name of current session
    sN1 = strfind(sessions(i).name, '-');
    
    path_to_data=[currentDir '\' getfield(sessions(i),'name')];
    fprintf('%s\n',char(strcat({'Processing... File '}, num2str(i),{'/'},...
        num2str(size(sessions,1)),{'. Current data file: '},...
        sessions(i).name)))
    
    if sum(contains(matFiles,(sessions(i).name(1:sN1(2)-1))))==0
        % tests if file is already there (only for single recs 28-5-2019)
        
        % Check if it's a dual recording or a single recording
            photometry_complete(path_to_data);
        
        % Close all open files (otherwise it will return an error at some
        % point)
        fclose all;
    end
%     clearvars -except sessions currentDir
end
    
end