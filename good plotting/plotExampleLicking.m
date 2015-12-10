
figure;
% color for 90% water, 50% water, nothing, and airpuff; will modify later
colorSet = [0 	0 	255;%blue  
                   30 	144 	255;%light blue  
                   128 	128 128; % grey
                    255 0 0]/255; % red;
plotTrialType = [1 2 7];

subplot(1,2,1)
for i = 1:length(plotTrialType)
    r = analyzedData.rasterLick{plotTrialType(i)};
    averagePSTH = [];
    % smooth the PSTH using box smoothing method, you should choose
    % your own favoriate
    averagePSTH = 1000*smoothPSTH(r, 'box', 200);
    errPSTH(i,:) = std(averagePSTH)/sqrt(size(r,1));
    meanPSTH(i,:) = mean(averagePSTH);
    % make the plotting
    errorbar_patch(-0.9:0.01:3.9,meanPSTH(i,100:10:end-100),errPSTH(i,100:10:end-100),colorSet(i,:));
end
% make the plot beautiful
xlim([-0.9 3.9])
%ylim([-2 Ylimit])
set(gcf,'Color','w')
set(gca,'Box','off','FontSize',12)
set(gca,'TickDir','out')
ylabel('Firing rate (spikes/s)')
set(gca,'TickLength',[0.02 0.025])
set(gca,'ytick',[0:3:10])
set(gca,'LineWidth',1)