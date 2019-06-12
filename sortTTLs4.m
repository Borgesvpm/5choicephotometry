function sessionData=sortTTLs4(rawData, sessionData)
%% Match behavioral data


%% Load the trial data
%
% Based on timestamps in TDT files
% Retrieve trial data from raw Data file
%
respEpoch = sortrows([rawData.corr; rawData.inco; rawData.omis; rawData.prem],1);
epoch=rawData.epoch;

%
% Based on timestamps in MPC files
% To be 100% sure we can also check with the MPC file on the side. 
%
rN1 = strfind(rawData.path_to_data, '\'); rN2 = strfind(rawData.path_to_data, '-');
ratName = rawData.path_to_data(rN1(end)+1:rN2(1)-1);

rN3 = strfind(ratName, '_'); 
ratName_one = ratName(1:rN3-1); ratName_two=ratName(rN3+1:end);

rD = rawData.path_to_data(rN2(1)+1:rN2(2)-1);
ratDate = strcat(rD(1:2), '-', rD(3:4), '-', rD(5:6));

dirPlusRat = strcat('G:\Data\MPC\*',ratDate,'*', ratName, '*');
mpcFile = dir(dirPlusRat);

if size(mpcFile,1)==1
    mpcFileName = strcat('G:\Data\MPC\',mpcFile.name);
    mpcOut = read_5choice(mpcFileName);
elseif size(mpcFile,1)==0
        try
            bPath = strcat(rawData.path_to_data,'\', getfield(dir(strcat(rawData.path_to_data, '\!201*')),'name'));
            mpcOut = read_5choice(bPath);
        catch
            perf = respEpoch(:,2);
            trialITI = zeros(numel(perf),1);
            trialSD = zeros(numel(perf),1);
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
            perf = respEpoch(:,2);
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

if sum(rawData.path_to_data(end-1:end) ~= 's2')==0
    perf = ones(numel(epoch),1);
end
    
% Checks for trialstarts just before end of session
if respEpoch(1, 1) < epoch(1)
    % Incase the MPC session started before the TDT recording
    if numel(perf)<10
        trN=numel(perf)-1;
    else
        trN = 10;
    end
    
    if sum(abs(perf(1:trN)-respEpoch(2:trN+1,2)))==0
        trialITI(end)=[]; trialSD(end)=[];
        startT(end)= []; respT(end)=[];perf(end)=[];
        
    else
        trialITI(1)=[]; trialSD(1)=[];
        startT(1)= []; respT(1)=[];perf(1)=[];
    end
    respEpoch(1,:) =[];
end
% Checks for sessions started before recording
if epoch(end,1) > respEpoch(end,1)
    if size(epoch,1) > size(respEpoch,1)
        epoch=epoch(1:end-1);
        perf = perf(1:end-1);trialSD = trialSD(1:end-1); trialITI = trialITI(1: end-1);
    elseif size(epoch,1) == size(respEpoch,1)
        epoch = [epoch(1:end-1);nan(1,1)];
        perf = perf(1:end-1);trialSD = trialSD(1:end-1); trialITI = trialITI(1: end-1);
    end
end

% Makes sure there's only responses following trial starts
tmpPerf = sortrows([zeros(numel(epoch),1), epoch, nan(numel(epoch),1);...
    ones(numel(respEpoch(:,1)),1), respEpoch],2);
Err1 = find([nan(1,1);diff(tmpPerf(:,1))]==0);
if tmpPerf(Err1,1) == 0
    tmpPerf(Err1-1:Err1+1,:)=nan(3,3); % Removes entire faulty trial from TDT data
elseif tmpPerf(Err1,1) == 1
    tmpPerf(Err1-2:Err1,:)=nan(3,3); % Removes entire faulty trial from TDT data
end

% Remove Err1 from perf, trial ITI, trialSD
if sum(rawData.path_to_data(end-1:end) ~= 's2')>0
    perf(floor(Err1/2)) = [];
    trialSD(floor(Err1/2)) = [];
    trialITI(floor(Err1/2)) = [];
end

% If applicable, remove last trialstart w/o response from session
if isnan(tmpPerf(end,2))
    tmpPerf(end,:)=[];
end

% Makes sure there are no random inbetween trialstart pulses or responses
nxtTmpPerf = [tmpPerf(tmpPerf(:,1)==0,2),tmpPerf(tmpPerf(:,1)==1,2:3)];
Err2 = find([nan(1,1);diff(nxtTmpPerf(:,2))]<5);
nxtTmpPerf(Err2,:)=[];

tmpTrt = [];
if sum(rawData.path_to_data(end-1:end) ~= 's2')>1
    for i = 1: min([numel(perf), size(nxtTmpPerf,1)])
        
        if perf(i)~=nxtTmpPerf(i,3)
            perf(i)=[];trialSD(i)=[];trialITI(i)=[];
        else
            if mean(trialSD)<1 && sum(trialSD)>1
                tmpTrt = [tmpTrt;[nxtTmpPerf(i,:), trialSD(i)]];
            elseif mean(trialITI)>1
                tmpTrt = [tmpTrt;[nxtTmpPerf(i,:), trialITI(i)]];
            else
                tmpTrt = [tmpTrt;[nxtTmpPerf(i,:), 0]];
            end
        end
    end
    
    if corr(tmpTrt(:,3), perf(1:size(tmpTrt,1))) > 0.99
        sessionData.trialstart = tmpTrt;
    else
        fprintf('Something is seriously up with TTLs')
    end
    
else
    
    sessionData.trialstart = [nxtTmpPerf, zeros(size(nxtTmpPerf,1),1)];
end

end
