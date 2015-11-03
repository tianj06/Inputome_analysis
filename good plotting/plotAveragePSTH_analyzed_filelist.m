function ax = plotAveragePSTH_analyzed_filelist(fl,freeReward)
if nargin <=1
    freeReward = 0;
end

psth = zeros(length(fl),10,5001);
k=1;
for i = 1:length(fl)
    load(fl{i},'analyzedData')
    trialNum = cellfun(@(x)size(x,1),analyzedData.raster);
    if (~isnan(analyzedData.smoothPSTH(9,1)))|(~freeReward)
        psth(k,:,:) = analyzedData.smoothPSTH(1:10,:);
        k = k+1;
    end
end
averagePSTH = squeeze(nanmean(psth));
CueColor= [  0 	0 	255;%blue  
             30 	144 	255;%light blue  
             128 	128 128;
             0 0 0]/255; % grey
trialType = [1 2 7 9];

        
figure;
ax(1) = subplot(1,2,1);
if freeReward
    totalTrialTypes = 4;
else
    totalTrialTypes = 3;
end 
for i = 1:totalTrialTypes
        plot(-1:0.001:4,averagePSTH(trialType(i),:),'color',CueColor(i,:),'LineWidth',1.5)
        hold on
end
h = legend('90% W','50% W','0% W','free W');
set(h,'Location','NorthWest','box','off')
prettyP([-0.9 3.8],'','','','l')
xlabel('Time - Odor (ms)')
ylabel('Spikes/s')
title(['n=' num2str(k-1)])

ax(2) = subplot(1,2,2);
for i = 1:3
        plot(-1:0.001:4,averagePSTH(i+4,:),'color',CueColor(i,:),'LineWidth',1.5)
        hold on
end
prettyP([-0.9 3.8],'','','','l')
xlabel('Time - Odor (ms)')
ylabel('Spikes/s')
set(gcf,'Position',[400   300   964   400])
end
