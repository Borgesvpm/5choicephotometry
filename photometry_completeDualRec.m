function photometry_completeDualRec(path_to_data)

%% analysis of dual recording sessions
% Splits data from two rats that did task simultaneously
% Sorts and takes traces like normal script
% Returns .mat file for both sessions in format that is accepted by
% further analysis scripts

%% To Do
% Fix response sync timings in read_5choice
% Check vITI and vSD session timings
% Check alignment epoch and startT/respT etc.
% Check local baseline application preprocessing


%% Extracts data from TDT file
rawData  = tdtExtractDualRec(path_to_data);

%% Preprocessing
[sData, rawData] = preProcessingSteps2DualRec(rawData);

%% Matches data from TDT to corresponding MPC files
sData = sortTTLs4DualRec(rawData,sData);

%% Take traces
fld = fieldnames(sData);

for rat = 1:2
    sData.(fld{rat}) = takeTraces8DualRec(rawData, sData.(fld{rat}));
end

%% Save .mat files
for rat = 1:2
    sessionData = sData.(fld{rat});
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
    newname=[fld{rat}, myfile(idct(1):idct(2)-1) '_traces.mat'];
    newdir = mydir(1:idcs(end)-1);
    cd(newdir)
    if exist(newname)==2
    newname=[fld{rat}, myfile(idct(1):idct(2)-1) '_traces_2.mat'];
    end
    save(newname, 'sessionData')
end

 clear sessionData
 clear rawData


end