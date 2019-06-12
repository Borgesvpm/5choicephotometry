function [rawData]= tdtExtractDualRec(path_to_data)
%% Extract photometry data from TDT Data Tank

% path_to_data = '/Users/sybrendekloet/surfdrive/PhD/Data/Fiber photometry/Data/New setup/Tanks'; % point to folder where data is
rawData.path_to_data=path_to_data;

% set up Tank name, variables to extract
tankdir = [path_to_data];
storenames = {'GR1A', 'UV1A', 'Tr2_', 'GR2B', 'UV2B', 'Trt_'}; % name of stores to extract from TDT (usu. 4-letter code) LMag is the demodulated data, may also have other timestamps etc

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

LMag = S{1}; % 470nm channel Box 1
LMag2= S{2}; % 405nm channel Box 1
LMag3= S{3}; % trialstart moments Box 1
LMag4= S{4}; % 470nm channel Box 2
LMag5= S{5}; % 405nm channel Box 2
LMag6= S{6}; % trialstart moments Box 2
% LMag7= S{7};

% For 2-color rig, LMag data is on channels 1 and 2, channel 1 = 470nm, channel 2 = 405nm
chani1 = LMag.channels==1;
chani2 = LMag2.channels==1;

chani4 = LMag4.channels==1;
chani5 = LMag5.channels==1;

% Get LMag timestamps (use chani1 - timestamps should be the same for all Wpht channels
ts = LMag.timestamps(chani1);
t_rec_start = ts(1);

ts = ts-ts(1); % convert from Unix time to 'seconds from block start'
ts = bsxfun(@plus, ts(:), (0:LMag.npoints-1)*(1./LMag.sampling_rate));
ts = reshape(ts',[],1);

% Get LMag data as a vector (repeat for each channel)
% for Box 1
dat1 = LMag.data(chani1,:);
dat1 = reshape(dat1', [],1); % unwrap data from m x 256 array
rawData.rat_one.dat1 = [ts, dat1];
dat2 = LMag2.data(chani2,:);
dat2 = reshape(dat2', [],1); % unwrap data from m x 256 array
if size(dat2,1)>size(dat1,1) %somehow incase there are more dat2 frames than dat1
    dat2(size(dat1)+1:end)=[];
end
rawData.rat_one.dat2 = [ts, dat2];

% for Box 2
dat3 = LMag4.data(chani4,:);
dat3 = reshape(dat3', [],1); % unwrap data from m x 256 array
rawData.rat_two.dat1 = [ts, dat3];
dat4 = LMag5.data(chani5,:);
dat4 = reshape(dat4', [],1); % unwrap data from m x 256 array
if size(dat4,1)>size(dat3,1) %somehow incase there are more dat2 frames than dat1
    dat4(size(dat3)+1:end)=[];
end
rawData.rat_two.dat2 = [ts, dat4];

% Write the trialstart moments into vector
epoch1 = LMag3.timestamps; epoch1=epoch1-t_rec_start;
rawData.rat_one.epoch = reshape(epoch1', [],1); % Box 1
epoch2 = LMag6.timestamps; epoch2=epoch2-t_rec_start;
rawData.rat_two.epoch = reshape(epoch2', [],1); % Box 2

% sampling rate
rawData.conversion = LMag.sampling_rate;
% 
% % plot data
% figure
% fns = {'rat_one' 'rat_two'};
% for i = 1:2
% subplot(2,1,i)
% plot(rawData.(fns{i}).dat1(:,2))
% hold on
% plot(rawData.(fns{i}).dat2(:,2))
% end
% 

end