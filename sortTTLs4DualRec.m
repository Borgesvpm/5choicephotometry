function sessionData=sortTTLs4DualRec(rawData, sessionData)
%% Match behavioral data


%% Load the trial data
%
% Based on timestamps in MPC files
% To be 100% sure we can also check with the MPC file on the side.
%
rN1 = strfind(rawData.path_to_data, '\'); rN2 = strfind(rawData.path_to_data, '-');
rN3 = rawData.path_to_data(rN1(end)+1:rN2(1)-1);

rN4 = strfind(rN3, '_');
ratName{1} = rN3(1:rN4-1); ratName{2}=rN3(rN4+1:end);

rD = rawData.path_to_data(rN2(1)+1:rN2(2)-1);
ratDate = strcat(rD(1:2), '-', rD(3:4), '-', rD(5:6));
ratNs = {'rat_one', 'rat_two'};

dC1 = datetime(str2num(rD(1:2)), str2num(rD(3:4)), str2num(rD(5:6)));
dC2 = datetime(0019, 05, 07);
if dC1 >= dC2
    ratNs = {'rat_two', 'rat_one'};
end

for i = 1:2
    dirPlusRat = strcat('G:\Data\MPC\*',ratDate,'*', ratName{i}, '*');
    mpcFile = dir(dirPlusRat);
    
    if size(mpcFile,1)==1
        mpcFileName = strcat('G:\Data\MPC\',mpcFile.name);
        mpcOut = read_5choice(mpcFileName);
    elseif size(mpcFile,1)==0
        try
            bPath = strcat(rawData.path_to_data,'\', ...
                getfield(dir(strcat(rawData.path_to_data, '\!201*', ratName{i},'*')),'name'));
            mpcOut = read_5choice(bPath);
        catch
            fprintf('no MPC file found. fix it before proceeding')
        end
    elseif size(mpcFile,1)>1
        % Determine time of TDT recording
        tdtHours = rawData.path_to_data(rN2(2)+1:rN2(2)+2);
        tdtMins = rawData.path_to_data(rN2(2)+3:rN2(2)+4);
        tdtTime = str2double(tdtHours) + str2double(tdtMins)/60;
        
        % Compare to possible mpc file times
        for mpc = 1:size(mpcFile,1)
            mpcInd3 = strfind(mpcFile(mpc).name,'_');
            mpcHours = mpcFile(mpc).name(mpcInd3(1)+1:mpcInd3(1)+2);
            mpcMins = mpcFile(mpc).name(mpcInd3(1)+4:mpcInd3(1)+5);
            mpcTime = str2double(mpcHours) + str2double(mpcMins)/60;
            
            temp_prox(mpc) = abs(mpcTime - tdtTime);
        end
        
        % Get index of lowest (temporally closest) mpc file
        [~, final_mpc] = min(temp_prox);
        % Allocate mpc file name
        mpcFileName = strcat('G:\Data\MPC\',mpcFile(final_mpc).name);
        try
            mpcOut = read_5choice(mpcFileName);
        catch
            try
                bPath = strcat(rawData.path_to_data,'\', getfield(dir(strcat(path_to_data, '\!201*')),'name'));
                mpcOut = read_5choice(bPath);
            catch
%                 perf = respEpoch(:,2);
                trialITI = zeros(numel(perf),1);
                trialSD = zeros(numel(perf),1);
            end
        end
        
    end
    
    try
        respT = mpcOut.respT;
        startT = mpcOut.startT;
        perf = mpcOut.performance;
        trialITI = mpcOut.trialITI; trialSD = mpcOut.trialSD;
    catch
        respT = zeros(numel(perf),1);
    end
    
    
    %% Checks to be done:
    % Are epoch and respEpoch same size?
    % Are all epochs and respEpochs matched (i.e. is their relative timing
    % correct?)
    
    epoch = rawData.(ratNs{i}).epoch;
    tmpTrt=[];
        
    for trial = 1: min([numel(startT), numel(epoch)])
        
        tmpDiff(trial) = epoch(trial)-startT(trial);
        
        if trial > 1
            
            if abs(tmpDiff(trial)-tmpDiff(trial-1))>1
                
                epoch(trial) = [];
                
            end
            
        end
        
        adjRspTime = respT(trial) - startT(trial) + epoch(trial);
        
        if mean(trialITI)> 1
            tmpTrt = [tmpTrt; [epoch(trial), adjRspTime, perf(trial), trialITI(trial)]];
        elseif mean(trialSD) > 0
            tmpTrt = [tmpTrt; [epoch(trial), adjRspTime, perf(trial), trialSD(trial)]];
        else
            tmpTrt = [tmpTrt; [epoch(trial), adjRspTime, perf(trial), zeros(1,1)]];
        end
        
    end
    
    if corr(tmpTrt(:,1), tmpTrt(:,2)) > 0.99
        sessionData.(ratName{i}).trialstart = tmpTrt;
    else
        fprintf('Something is seriously up with TTLs')
    end
    
end

end
