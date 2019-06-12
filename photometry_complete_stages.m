function sessionData = photometry_complete_stages(path_to_data)
%% This script will process data from one 5-choice photometry recording
% session. 

%% Input: 
% path_to_data = the path of the folder containing the data
%
% Example:
% path_to_data = 'E:\PhD\Data\FP\GDS\varITI\gDS11-180917-145244 - viti'
%
% If you are already in the folder in the Matlab navigator, you can also
% enter this line in the command window:
% path_to_data = pwd
%
%
%% Ouput: 
% 1) sessionData
% Structure array containing all processed data from the recording session
% 
% Contents:
% sessionData.dFF = preprocessed data trace of entire recording
%
% sessionData.trialstart = all relevant timepoints for the behavioral data.
%   Meaning of contents:
%   row 1 = timepoints of every trial initiation
%   row 2 = timepoints of every response 
%   row 3 = response type
%
%   only in variable ITI/SD sessions:
%   row 4 = ITI / SD
%
% sessionData.traces = data traces of +-15s around trial initiation,
%   synchronized at trial initiation
%   Meaning of contents:
%   .responseTypes = data traces sorted based on response type
%       {1} = correct response
%       {2} = incorrect response
%       {3} = omission
%       {4} = premature response
%
% sessionData.tracesResp =  data traces of +-15s around response,
%   synchronized at response
%   Meaning of contents:
%   .responseTypes = data traces sorted based on response type
%       {1} = correct response
%       {2} = incorrect response
%       {3} = omission
%       {4} = premature response
%
% sessionData.startSync = data traces of +-15s around trial initiation,
%   synchronized at trial initiation
% sessionData.respSync = data traces of +-15s around response,
%   synchronized at response 
%
% sessionData.errCor = data traces of +-15s around trial initiation,
%   synchronized at trial initiation, but only correct trials preceded by
%   an error trial (incorrect, omission and premature are pooled)
%
% sessionData.corCor = data traces of +-15s around trial initiation,
%   synchronized at trial initiation, but only correct trials preceded by
%   a correct response
%
% UNUSED PARTS:
% sessionData.dFFLP = lowpass-filtered trace of entire session
% sessionData.trialSD = SD values in variable SD sessions
% sessionData.trialITI = ITI values in variable ITI sessions
%
% 2) rawData
% Structure array with all raw data and preprocessing information 
%
% Contents:
% rawData.dat1 = raw data trace of 405nm channel (in frames)
% rawData.dat2 = raw data trace of 470nm channel (in frames)
% rawData.corr = timepoints of correct responses (in seconds)
% rawData.inco = timepoints of incorrect responses (in s)
% rawData.omis = t of omissions (in s)
% rawData.prem = t of premature responses (in s)
% rawData.epoch = timepoints of initiation of every trial (in s)
% rawData.conversion = sampling rate (hz)
% rawData.camt = camera time (in frames, framerate = 20hz)
%
%
% 3) .MAT file
% The script will also create a .mat file of the data in structure array
% sessionData, and will save it in the main folder (one up from the current
% one), with animal information and date in its name.
%
% Example:
% if the current folder name is 'gDS11-180917-145244 - viti'
% the .mat file will be called 'gDS11-180917_traces.mat'


%% Step 1: extract all data from raw TDT file
% will give a struct (rawData) with fields containing:
% dat1 = raw data trace of 405nm channel (in frames)
% dat2 = raw data trace of 470nm channel (in frames)
% corr = timepoints of correct responses (in seconds)
% inco = timepoints of incorrect responses (in s)
% omis = t of omissions (in s)
% prem = t of premature responses (in s)
% epoch = timepoints of initiation of every trial (in s)
% conversion = sampling rate (hz)
% path_to_data=pwd;

stageName = path_to_data(end-1:end);
rawData = tdtExtract2(path_to_data);
if stageName == 's2'
    if size(rawData.epoch,1)<size(rawData.corr,1)
    tmpCorr = rawData.corr(:,1);
    rawData.corr=[rawData.epoch, ones(numel(rawData.epoch),1)];
    rawData.epoch=tmpCorr;
    end
elseif stageName == 's1'
    rawData.corr=[rawData.epoch, ones(numel(rawData.epoch),1)];
end
%% preprocessing 
% This step does preprocessing. 
% Applies a fit to the 405nm data to scale it to the 470nm channel
% We also apply an exponential fit to correct for bleaching
% Then subtract the scaled 405nm channel from the 470nm signal trace
% And divide the remaining trace by the 405 nm trace
% This will give the dF/F for the entire trace as output
% 
% output = sessiondata.adjCaSig
[sessionData, rawData] = preProcessingSteps2(rawData);

%% Match behavioral data
% Matches trial start timestamps with response times. RespEpoch is a matrix
% with all response times for each response type. Column 1 has the
% timestamps, column 2 has response types:
% 1=corr, 2=incorrect, 3=omission, 4=premature
% We then sort the rows based on response time, to match
% with trial start times generated before, which are expressed in variable
% epoch
%
% output = sessionData.trialstart
% this is a matrix with trial start times (s), trial response times (s) and response type 
sessionData = sortTTLs4(rawData, sessionData);


%% cutting out traces from the raw data file

% This cuts out traces corresponding to a trial window. Will also load
% behavioral data from var SD and var ITI sessions. The trial window will
% be 15sec for fixed ITI and longer for variable ITI sessions.
sessionData = takeTraces8(rawData, sessionData);

%% remove outliers

% Removes outliers from data set based on the extent of deviation within
% trials. Particularly good at removing outliers due to extreme noise or cable
% detachments. 
% sessionData = removeOutliers(sessionData)


%% Video analysis
% This part is about video analysis; here we sort traces based on the
% animals location in the 5s before the cue onset
% currently have 3 different options:
% 1 = rat stays at magazine and turns head (75% of time in left half)
% 2 = rat moves to nosepoke holes and watches there (75% of time near
% NPHs)
% 3 = mixed strategy where he isnt 75% at magazine or nosepoke holes
%
% %
% if size(dir('*.csv'),1)>0
%     sessionData=videoanalysis_5c(sessionData)
% end
%% sorting the traces into appropriate formats

% Traces will be sorted according to their:
%
% 1) Response type
%   correct, incorrect, omission, premature 
%   sessionData.traces
%
% 2) Task characteristics (trial ITI/SD)
%   variable ITI, variable SD
%   sessionData.traces.varITI
%
% 3) Task strategy
%   nosepoke, magazine or mixed
%   sessionData.vidSync.traces(.trialITI)
%
% 4) Synchronization on response or trial start
%   trialstart or nosepoke response
%   sessionData.tracesResp
%
% sessionData=sortTraces(sessionData)

%% Save .mat file
mydir  = path_to_data;
idcs   = strfind(mydir,'\');
myfile = mydir(idcs(end)+1:end);
idct   = strfind(myfile,'-');
idus = strfind(myfile,'_');
if numel(idus)>1
    if idct(1)<idus(1)
        idend = idct(1);
    else
        idend = idus(1);
    end
else
    idend=idct(1);
end
newname=[myfile(1:idend-1) myfile(idct(1):idct(2)-1) '_traces.mat'];
newdir = mydir(1:idcs(end)-1);
cd(newdir)
save(newname, 'sessionData')
%  clear sessionData
%  clear rawData
fclose all;



end

    
    
    
