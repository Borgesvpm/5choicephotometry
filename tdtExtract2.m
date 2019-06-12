function [rawData]= tdtExtract2(path_to_data)
%% Extract photometry data from TDT Data Tank

% Store data path in rawData struct
rawData.path_to_data=path_to_data;

% set up Tank name, variables to extract
tankdir = [path_to_data];
storenames = {'405A', '470A', 'CoR_', 'InR_', 'Oms_', 'Prm_','Trt_','Cam1'}; % name of stores to extract from TDT (usu. 4-letter code) LMag is the demodulated data, may also have other timestamps etc

% tev_path = strcat(path_to_data,'/',uigetfile('*.tev'));
% tsq_path = strcat(path_to_data,'/',uigetfile('*.tsq'));

cd(path_to_data);
tevfile=dir('*.tev');
tsqfile=dir('*.tsq');
tev_path = strcat(path_to_data,'\', tevfile.name);
tsq_path = strcat(path_to_data,'\', tsqfile.name);

% extract
for k = 1:numel(storenames)

  storename = storenames{k}; 
  S{k} = tdt2mat(tankdir, storename, tev_path, tsq_path);
end

%% Massage data and get time stamps

LMag = S{1}; %add more if you extracted more stores above
LMag2= S{2};
LMag3= S{3};
LMag4= S{4};
LMag5= S{5};
LMag6= S{6};
LMag7= S{7};
LMag8= S{8};

% For 2-color rig, LMag data is on channels 1 and 2, channel 1 = 470nm, channel 2 = 405nm
chani1 = LMag.channels==1;
chani2 = LMag2.channels==1;

% Get LMag timestamps (use chani1 - timestamps should be the same for all Wpht channels
ts = LMag.timestamps(chani1);
t_rec_start = ts(1);

ts = ts-ts(1); % convert from Unix time to 'seconds from block start'
ts = bsxfun(@plus, ts(:), (0:LMag.npoints-1)*(1./LMag.sampling_rate));
ts = reshape(ts',[],1);

% Get LMag data as a vector (repeat for each channel)
dat1 = LMag.data(chani1,:);
dat1 = reshape(dat1', [],1); % unwrap data from m x 256 array
rawData.dat1 = [ts, dat1];
dat2 = LMag2.data(chani2,:);
dat2 = reshape(dat2', [],1); % unwrap data from m x 256 array

if size(dat2,1)>size(dat1,1) %somehow incase there are more dat2 frames than dat1
    dat2(size(dat1)+1:end)=[];
end

rawData.dat2 = [ts, dat2];
corr = LMag3.timestamps; corr=corr-t_rec_start;
corr = reshape(corr', [],1); % unwrap data from m x 256 array
rawData.corr = [corr, ones(size(corr))];
inco = LMag4.timestamps; inco=inco-t_rec_start;
inco = reshape(inco', [],1); % unwrap data from m x 256 array 
rawData.inco = [inco, ones(size(inco))*2];
omis = LMag5.timestamps; omis=omis-t_rec_start;
omis = reshape(omis', [],1); % unwrap data from m x 256 array 
rawData.omis = [omis, ones(size(omis))*3];
prem = LMag6.timestamps; prem=prem-t_rec_start;
prem = reshape(prem', [],1); % unwrap data from m x 256 array
rawData.prem = [prem, ones(size(prem))*4];
epoch = LMag7.timestamps; epoch=epoch-t_rec_start;
rawData.epoch = reshape(epoch', [],1);
rawData.conversion = LMag.sampling_rate;

camt= LMag8.timestamps; camt = camt-t_rec_start;% video time stamps
rawData.camt = reshape(camt', [],1); %unwrap data

