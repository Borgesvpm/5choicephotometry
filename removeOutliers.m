function sessionData = removeOutliers(sessionData)
%% remove outliers
x=isoutlier(mean(sessionData.startSync'));
y=isoutlier(mean(sessionData.respSync'));
z= x+y;

sessionData.startSync(z>0,:)=[];
sessionData.respSync(z>0,:)=[];
sessionData.trialstart(z>0,:)=[];


end
