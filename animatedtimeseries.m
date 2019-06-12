%%option 1 
% 26-9-2018
%%
% define window edges
winS = 1390;
winE = 1440;
    windowStart = ceil(winS *rawData.conversion);
windowEnd = ceil(winE * rawData.conversion);

% downsample to video frame rate
% get timestamps for 20hz frame start points in seconds
caTime = winS:0.05:winE;
% recalculate to TDT frames
adjCaTime = caTime*rawData.conversion;
% initiate data table
aniData = zeros(1,numel(caTime));
% start loop through adjCaTime
for frm = 1:numel(adjCaTime)
% take window of floor(20/1017.3-1) size
    frameWin = ceil(adjCaTime(frm)):floor(adjCaTime(frm)+(1017.3/20-1));
% get data
    dataFrame = sessionData.dFFLP(frameWin);
    % take mean
    meanFrame = mean(dataFrame);
% append to data set
    aniData(frm) = meanFrame;
end

% isolate behavioral epochs from window
epochs = sessionData.trialstart(...
    sessionData.trialstart(:,2)>winS & ...
    sessionData.trialstart(:,2)<winE,:);

epochs(:,1:2) = (epochs(:,1:2) - winS);


% initiate necessary variables
tLo = 1 ;
tCa = 1;
xLo = [] ; yLo = []; caSig=[]; tSig=[0];
startSpot = 0;
maxCa = numel(aniData) ; % considering 1000 samples
% maxCa = size(sessionData.dFF,1) ; % considering 1000 samples

intervLo = maxCa;
stepCa = 1 ; % lowering step has a number of cycles and then acquire more data
% stepLo = stepCa;

% read movie file
  f=dir('*m1.avi');
movieFile = VideoReader(f.name);

clipStart = winS * movieFile.frameRate;
clipEnd = winE * movieFile.frameRate;
tVid=1;


% initiate video file
myVid = VideoWriter('ratIn5Choice.avi');
open(myVid);

figA=figure('Position', get(0, 'Screensize'));

while ( tCa <maxCa )
%     
%     % Position
%     subplot(1,2,1)
%     xL = sessionData.dFF(tLo,1);
%     yL = sessionData.dFF(tLo,2);
%     
%     
%     xLo = [xLo, xL];
%     yLo = [yLo, yL];
%     if numel(xLo) < 51
%         
%         plot(xLo,yLo, 'r')
%         
%     else
%         
%         plot(xLo(end-50:end),yLo(end-50:end), 'r')
%         
%     end
%     
%     axis([0, 180, 0, 440]);
%     tLo = tLo + stepLo;
%     drawnow;
%       
    % Calcium signal
    subplot(1,2,1)
    b = aniData(tCa);
    caSig = [ caSig, b ];
    tSig = caTime-winS;
     
    % first 50 frames (graph is not yet moving)
    if numel(caSig)<51
        startSpot = 0;
        plot(caSig,'b', 'LineWidth',2 ) ;
        
        axis([tSig(1), tSig(50), min(aniData)*1.1,...
            max(aniData*1.1)]);

    else % graphs starts moving after 50 frames
        startSpot = tCa;
        plot(tSig(end-50:end),caSig(end-50:end),'b', 'LineWidth',2 )
        
%         plot(startSpot/stepCa-50:startSpot/stepCa,caSig(end-50:end),'b') ;
        
        axis([tSig(end-50), tSig(end), min(aniData)*1.1,...
            max(aniData*1.1)]);
%         pause
        
    end
    
     xlabel('Time (s)')
    ylabel('dF/F (%)')
    title('Corrected GCaMP6m fluorescence signal')
    set(gca, 'box', 'off')
    
   % plot lines for behavioral epochs
    yL = [min(aniData)*1.1 max(aniData)*1.1];
    for lin = 1:size(epochs,1)
        line([epochs(lin,1) epochs(lin,1)], yL, 'Color', 'k', 'LineWidth', 2)
        
        if epochs(lin,3)==1
            line([epochs(lin,2) epochs(lin,2)], yL, 'Color', 'b', 'LineWidth', 2)
            
        else
            line([epochs(lin,2) epochs(lin,2)], ylim, 'Color', 'r', 'LineWidth', 2)
            
        end
    end
    

    
    grid
    tCa = tCa + stepCa;
    drawnow;
    
    
    
    subplot(1,2,2)
    movieFile.currentTime=clipStart/20+tVid/20;
    vidFrame = readFrame(movieFile);
    image(vidFrame);
    tVid = tVid+1;
    axis off
    
    
    % Write video to file
    frame = getframe(gcf);
    writeVideo(myVid,frame);
    
    
    pause(0.05)

      
end



%% 27-9-18 new try animated line
%%option 2
%%
% define window edges
winS = 1390;
winE = 1440;
    windowStart = ceil(winS *rawData.conversion);
windowEnd = ceil(winE * rawData.conversion);

% downsample to video frame rate
% get timestamps for 20hz frame start points in seconds
caTime = winS:0.05:winE;
% recalculate to TDT frames
adjCaTime = caTime*rawData.conversion;
% initiate data table
aniData = zeros(1,numel(caTime));
% start loop through adjCaTime
for frm = 1:numel(adjCaTime)
% take window of floor(20/1017.3-1) size
    frameWin = ceil(adjCaTime(frm)):floor(adjCaTime(frm)+(1017.3/20-1));
% get data
    dataFrame = sessionData.dFFLP(frameWin);
    % take mean
    meanFrame = mean(dataFrame);
% append to data set
    aniData(frm) = meanFrame;
end

% isolate behavioral epochs from window
epochs = sessionData.trialstart(...
    sessionData.trialstart(:,2)>winS & ...
    sessionData.trialstart(:,2)<winE,:);

epochs(:,1:2) = (epochs(:,1:2) - winS);


% initiate necessary variables
tLo = 1 ;
tCa = 1;
xLo = [] ; yLo = []; caSig=[]; tSig=caTime-winS;
startSpot = 0;
maxCa = numel(aniData) ; % considering 1000 samples
% maxCa = size(sessionData.dFF,1) ; % considering 1000 samples

intervLo = maxCa;
stepCa = 1 ; % lowering step has a number of cycles and then acquire more data
% stepLo = stepCa;


% initiate figure
figA=figure('Position', get(0, 'Screensize'));
subplot(1,2,1)

xlabel('Time (s)')
ylabel('dF/F (%)')
title('Corrected GCaMP6m fluorescence signal')
set(gca, 'box', 'off')

% plot lines for behavioral epochs
yL = [min(aniData)*1.1 max(aniData)*1.1];
for lin = 1:size(epochs,1)
    line([epochs(lin,1) epochs(lin,1)], yL, 'Color', 'k', 'LineWidth', 2)
    
    if epochs(lin,3)==1
        line([epochs(lin,2) epochs(lin,2)], yL, 'Color', 'b', 'LineWidth', 2)
        
    else
        line([epochs(lin,2) epochs(lin,2)], yL, 'Color', 'r', 'LineWidth', 2)
        
    end
end
hold on
axis([tSig(1), tSig(100), min(aniData)*1.1,...
            max(aniData*1.1)]);
grid

% read movie file
  f=dir('*m1.avi');
movieFile = VideoReader(f.name);

clipStart = winS * movieFile.frameRate;
clipEnd = winE * movieFile.frameRate;
tVid=1;

% initiate video file
myVid = VideoWriter('ratIn5Choice.avi');
open(myVid);

for ind=1:size(aniData,2)

    subplot(1,2,1)

    % first 50 frames (graph is not yet moving)
    if ind<101
        caSig = [caSig, aniData(tCa)];
        plot(tSig(1:size(caSig,2)),caSig, 'b', 'LineWidth',2)
        axis([tSig(1), tSig(100), min(aniData)*1.1,...
            max(aniData*1.1)]);

    else % graphs starts moving after 50 frames
         caSig = [caSig, aniData(tCa)];
        plot(tSig(1:size(caSig,2)),caSig,'b', 'LineWidth',2)
       
        axis([tSig(ind-100), tSig(ind), min(aniData)*1.1,...
            max(aniData*1.1)]);
    end
    
    
    tCa = tCa + stepCa;
    drawnow;
        

    %
    subplot(1,2,2)
    movieFile.currentTime=clipStart/20+tVid/20;
    vidFrame = readFrame(movieFile);
    image(vidFrame);
    tVid = tVid+1;
    axis off
    
    
    % Write video to file
    frame = getframe(gcf);
    writeVideo(myVid,frame);
    
    
    pause(0.05)

      
end

