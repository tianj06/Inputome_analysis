% make new beautiful example neuron:
neuronNum = 1;
switch neuronNum
    case 1
        filename = 'Fireweed_2014-07-27_09-41-15_TT8_04_formatted.mat';
        %'Aubonpain_2015-03-04_00-00-01_TT3_04_formatted.mat';%'Violet_2014-10-20_09-22-51_TT3_01_formatted.mat';
    case 2
        filename ='Mochi_2015-01-09_11-11-36_TT1_01_formatted';
    case 3
        filename ='Violet_2014-10-16_12-02-23_TT7_01_formatted.mat';
end
dataPath = 'C:\Users\Hideyuki\Dropbox (Uchida Lab)\lab\FunInputome\rabies\rabies_VTA\formatted\';

analyzedData = getPSTHSingleUnit([dataPath filename]); % calculate the PSTH
%%
plotTrialType = [1 2 7 9];
Ylimit = 30;% this is the maxium y axis in your plot, usually a bit bigger
            %than the biggest data point.
figure;
% color for 90% water, 50% water, nothing, and airpuff; will modify later
colorSet = [0 	0 	255;%blue  
                   30 	144 	255;%light blue  
                   128 	128 128; % grey
                    0 0 0]/255; % black;

% a rectangular patch to indicate odor on time; 
h1 = patch([0 1 1 0],[0 0 Ylimit Ylimit],[0.5 0.5 0.5],'edgecolor','none','FaceAlpha',0.2)
% this code makes sure it doesn't show up in the legend
set(get(get(h1,'Annotation'),'LegendInformation'),'IconDisplayStyle','off'); 
hold on;

% to add a reference line at US onset
h2 = plot([2 2],[0 Ylimit],'--','Color',[0.7 0.7 0.7],'LineWidth',2)
set(get(get(h2,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');

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
ylim([-2 Ylimit])
set(gcf,'Color','w')
set(gca,'Box','off','FontSize',12)
set(gca,'TickDir','out')
ylabel('Firing rate (spikes/s)')
set(gca,'TickLength',[0.02 0.025])
set(gca,'ytick',[0:5:10]) %[0:10:30]
set(gca,'LineWidth',1)

l=legend({'Reward (P=0.9)','Reward (P=0.5)','Reward (P=0)','Free Reward'});
set(l,'Location','eastoutside')
xlabel('Time - odor (s)')
set(gcf, 'Position',[200 200 1400 700]);
% saveas(gcf,['example neuron' num2str(neuronNum) 'psth.fig' ])
% plot2svg(['example neuron' num2str(neuronNum) 'psth.svg']);
export_fig(gcf,['example neuron' num2str(neuronNum) '.jpg' ])
%%
load([dataPath filename])
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
figure;
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
saveas(gcf,['example neuron' num2str(neuronNum) 'lightHist.fig' ])
export_fig(['example neuron' num2str(neuronNum) 'lightHist.jpg' ])
%%
nanmean(checkLaser.Raw_Spon_wv)
checkLaser.Raw_wv