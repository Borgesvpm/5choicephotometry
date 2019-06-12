function mpcOut =read_5choice(filename)
%function read_5choice(filename) Will import the data from filename and
%perform simple analysis on the data stored on row 41 downwards

fid = fopen(filename, 'rt');
% read the entire file, if not too big
s = textscan(fid, '%s', 'delimiter', '\n');
% search for your Region:
idx1 = find(strcmp(s{1}, 'X:'), 1, 'first');

M=importdata(filename,' ',idx1+1); %import the data, consider line 1-39 as text
realdata=M.data;               %realdata now stores the numbers
endFind=mean(realdata,2);

yesTrial=find(endFind>0);
lastTrial=ceil(yesTrial(end)/12);  %The total number of trials
trialSD=realdata(12:12:lastTrial*12,2);
trialITI=realdata(12:12:lastTrial*12,3);

clear endFind yesTrial

startT=realdata(1:12:lastTrial*12,2); %starttime
respT=zeros(lastTrial,1); %response times
laser=zeros(lastTrial,1); %laser on =1
corct=zeros(lastTrial,1); %Correct response =1
incr=zeros(lastTrial,1); %Incorrect response =1
prem=zeros(lastTrial,1); %premature response >0
omis=zeros(lastTrial,1); %Omission trial =1
premcor=zeros(lastTrial,1); %correct response after premature nosepoke
magLat=zeros(lastTrial,1); %magazine latency
cueLoc=zeros(lastTrial,1); %Cue location
compCor=zeros(lastTrial,1); %Compulsive responses correct location
compIncor=zeros(lastTrial,1);%Compulsive responses incorrect location

latPostTO=zeros(lastTrial,1); %latency after previous trial/TO



for i=1:lastTrial
    cueLoc(i)=realdata((i-1)*12+1,3);
    latPostTO(i)=realdata((i-1)*12+1,4);
    
    
%     if realdata(i*12,1)~0
%         laser(i)=1;     %Was the laser on?
%     end
    if sum(realdata((i-1)*12+3,:))>0 %Correct trial
        corct(i)=1;

        respT(i)=sum(realdata((i-1)*12+3,:));
        magLat(i)=realdata((i-1)*12+1,5);

    end
    if sum(realdata((i-1)*12+4,:))>0 %Incorrect trial
        incr(i)=1;
         respT(i)=sum(realdata((i-1)*12+4,:));
        magLat(i)=realdata((i-1)*12+1,5);
    end
    if sum(realdata((i-1)*12+9,:))>0
        prem(i)=sum(realdata((i-1)*12+9,:)); %will store number of premature responses
        if prem(i)>0
            prem(i)=1;
        end
        respT(i)= sum(realdata((i-1)*12+2,:))+startT(i);
%         respT(i)=sum((realdata((i-1)*12+2,:))/sum(realdata((i-1)*12+9,:)); %avg premature time
        
    end
    
    om=prem(i)+corct(i)+incr(i); %Will be 0 if no premature,correct or incorrect (==omission)
    if om==0
        omis(i)=1;
        if mean(trialITI)> 1
        respT(i) = startT(i) + trialITI(i) + 3;
        else
            respT(i) = startT(i) + 8;
    end
    
    if prem(i)==1 && corct(i) == 1  %Sometimes rats make a correct response after making a premature response when FP_100 script is used
        premcor(i) = 1;
        prem(i) = 0;
        corct(i) = 0; 
        omis(i) = 0;
    end
    
%     if sum(realdata((i-1)*12+10,:))>0
%         compCor(i)=sum(realdata((i-1)*12+10,:));
%     end
%     if sum(realdata((i-1)*12+11,:))>1
%         compIncor=sum(realdata((i-1)*12+11,:));
%     end
%     
end


mpcOut.performance = corct+(incr*2)+(omis*3)+(prem*4);
mpcOut.respT = respT;
mpcOut.startT = startT;
mpcOut.trialITI = trialITI;
mpcOut.trialSD = trialSD;

end

