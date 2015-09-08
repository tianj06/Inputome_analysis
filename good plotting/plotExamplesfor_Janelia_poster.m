load('lightDataSet1.mat')
plotfl = fl([50 52 ]); %29 71 57
%%
savePath = 'C:\Users\Hideyuki\Dropbox (Uchida Lab)\lab\FunInputome\rabies\allIdentified\Analysis\examplepsth\';
for j = 1:length(plotfl)
    load(plotfl{j})
   
    figure;
    % color for 90% water, 50% water, nothing, and airpuff; will modify later
    colorSet = [0 	0 	255;%blue  
                       30 	144 	255;%light blue  
                       128 	128 128; % grey
                        0 0 0]/255; % red;
    plotTrialType = [1 2 9 ]; %[1 2 7 9]
    subplot(2,1,1)
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
    set(gca,'LineWidth',1)
    xlim([-0.9 3.9])
    %ylim([-2 Ylimit])
    set(gcf,'Color','w','Position',[400 300 280 210])
    set(gca,'Box','off','FontSize',12)
    set(gca,'TickDir','out')
    ylabel('Firing rate (spikes/s)')
    set(gca,'TickLength',[0.02 0.025])
    %set(gca,'ytick',[0:10:30])
    %l=legend({'Reward (P=0.9)','Reward (P=0.5)','Reward (P=0)','free reward'});
    %set(l,'Location','eastoutside')
    xlabel('Time - odor (s)')
    
    subplot(2,1,2)
        plotTrialType = [5 6 7 ]; %[1 2 7 9]
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
    set(gca,'LineWidth',1)
    xlim([-0.9 3.9])
    %ylim([-2 Ylimit])
    set(gcf,'Color','w','Position',[400 300 280 210])
    set(gca,'Box','off','FontSize',12)
    set(gca,'TickDir','out')
    ylabel('Firing rate (spikes/s)')
    set(gca,'TickLength',[0.02 0.025])
    %set(gca,'ytick',[0:10:30])
    %l=legend({'Reward (P=0.9)','Reward (P=0.5)','Reward (P=0)','free reward'});
    %set(l,'Location','eastoutside')
    xlabel('Time - odor (s)')
    
    
    export_fig([savePath plotfl{j}(1:end-14) '.jpg'])
end