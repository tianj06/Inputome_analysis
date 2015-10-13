function plotAveragePSTH_analyzed_filelist(fl)
psth = zeros(length(fl),10,5001);
k=1;
for i = 1:length(fl)
    load(fl{i},'analyzedData')
    analyzedData = remove_too_few_trials(analyzedData,10);
    if ~isnan(analyzedData.smoothPSTH(5,1))
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
for i = 1:3
        plot(-1:0.001:4,averagePSTH(i,:),'color',CueColor(i,:),'LineWidth',1.5)
        hold on
end
legend('90% W','50% W','0% W','free W');
prettyP([-0.9 3.8],'','','','l')
xlabel('Time - Odor (ms)')
ylabel('Spikes/s')
title(['n=' num2str(k-1)])

figure;
for i = 1:3
        plot(-1:0.001:4,averagePSTH(i+4,:),'color',CueColor(i,:),'LineWidth',1.5)
        hold on
end
prettyP([-0.9 3.8],'','','','l')
xlabel('Time - Odor (ms)')
ylabel('Spikes/s')
end