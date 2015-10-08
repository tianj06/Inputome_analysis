function quickPSTHPlotting_formatted_new(filename)
load(filename)
plotTrialType = [1 2 7];
            %than the biggest data point.
figure;
% color for 90% water, 50% water, nothing, and airpuff; will modify later
colorSet = [0 	0 	255;%blue  
                   30 	144 	255;%light blue  
                   128 	128 128; % grey
                    255 0 0]/255; % red;

subplot(2,2,1)
for i = 1:length(plotTrialType)
    r = analyzedData.raster{plotTrialType(i)};
    averagePSTH = [];
    % smooth the PSTH using box smoothing method, you should choose
    % your own favoriate
    averagePSTH = 1000*smoothPSTH(r, 'box', 300);
    errPSTH(i,:) = std(averagePSTH)/sqrt(size(r,1));
    meanPSTH(i,:) = mean(averagePSTH);
    % make the plotting
    errorbar_patch(-1:0.001:4,meanPSTH(i,:),errPSTH(i,:),colorSet(i,:));
end
% make the plot beautiful
xlim([-0.9 3.9])
%ylim([-2 Ylimit])
set(gcf,'Color','w')
set(gca,'Box','off','FontSize',12)
set(gca,'TickDir','out')
ylabel('Firing rate (spikes/s)')
set(gca,'TickLength',[0.02 0.025])
set(gca,'ytick',[0:10:30])
set(gca,'LineWidth',1)

%l=legend({'Reward (P=0.9)','Reward (P=0.5)','Reward (P=0)','Airpuff (P=0.8)'});
%set(l,'Location','eastoutside')
xlabel('Time - odor (s)')
%%
subplot(2,2,2)
plotTrialType = [5 6 7];
for i = 1:length(plotTrialType)
    r = analyzedData.raster{plotTrialType(i)};
    N = size(r,1);
    averagePSTH = [];
    % smooth the PSTH using box smoothing method, you should choose
    % your own favoriate
    averagePSTH = 1000*smoothPSTH(r, 'box', 300);
    errPSTH(i,:) = std(averagePSTH)/sqrt(N);
    meanPSTH(i,:) = mean(averagePSTH);
    % make the plotting
    errorbar_patch(-1:0.001:4,meanPSTH(i,:),errPSTH(i,:),colorSet(i,:));
end
% make the plot beautiful
xlim([-0.9 3.9])
%ylim([-2 Ylimit])
set(gcf,'Color','w')
set(gca,'Box','off','FontSize',12)
set(gca,'TickDir','out')
ylabel('Firing rate (spikes/s)')
set(gca,'TickLength',[0.02 0.025])
set(gca,'ytick',[0:10:30])
set(gca,'LineWidth',1)

%l=legend({'Reward (P=0.9)','Reward (P=0.5)','Reward (P=0)','Airpuff (P=0.8)'});
%set(l,'Location','eastoutside')
xlabel('Time - odor (s)')


%%
subplot(2,2,[3 4])
laserOnset = events.freeLaserOn;
postLaseSpikeTime = zeros(length(laserOnset),31);
k =0;
for i=1:length(laserOnset)
    idx = find((responses.spike>laserOnset(i)-15)& (responses.spike<(laserOnset(i)+15)));
    nearestspikes=responses.spike(idx);
    if ~isempty(nearestspikes)
         k=k+1;
         postLaseSpikeTime(i,round(nearestspikes-laserOnset(i))+16)=1;
    end
end
xbar = -15:15;
bar(xbar, sum(postLaseSpikeTime)/length(laserOnset),'EdgeColor','none');
hold on;
h1 = vline(0,'k--');
set(h1,'LineWidth',1)
xlabel('Time - laser (ms)');
xlim([-15 15]);
set(gca,'xtick',-10:5:10)
set(gcf,'Color','w')
set(gca,'Box','off','FontSize',12)
set(gca,'TickDir','out')
ylabel('Freq')
set(gca,'TickLength',[0.02 0.025])
set(gca,'LineWidth',1)

