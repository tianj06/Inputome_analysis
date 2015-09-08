function plot_pop_summary_fromAnalyzed(fl)
    psthAll = [];
    auROCall = [];
    for i = 1:length(fl)
        load(fl{i},'analyzedData')
        psthAll(i,:,:) = analyzedData.smoothPSTH;
        auROCall(i,:,:) = analyzedData.rocPSTH;
    end
    
    figure;
    % color for 90% water, 50% water, nothing, and airpuff; will modify later
    colorSet = [0 	0 	255;%blue  
                   30 	144 	255;%light blue  
                   %128 	128 128; % grey
                    0 0 0]/255; % black;
    subplot(2,2,1)
    plotTrialType = [1 2 9];
    for i = 1:length(plotTrialType)
        errPSTH(i,:) = nanstd(squeeze(psthAll(:,plotTrialType(i),:)))/sqrt(length(fl));
        meanPSTH(i,:) = nanmean(squeeze(psthAll(:,plotTrialType(i),:)));
        % make the plotting
        if length(fl)>1
            errorbar_patch(-1:0.001:4,meanPSTH(i,:),errPSTH(i,:),colorSet(i,:));
        else
            plot(-1:0.001:4,squeeze(psthAll(1,plotTrialType(i),:)),'color',colorSet(i,:)); hold on;
        end
        xlim([-0.9 3.9])
        title('US+')
    end
    
    subplot(2,2,3)
    plotTrialType = [5:7];
    for i = 1:length(plotTrialType)
        errPSTH(i,:) = nanstd(squeeze(psthAll(:,plotTrialType(i),:)))/sqrt(length(fl));
        meanPSTH(i,:) = nanmean(squeeze(psthAll(:,plotTrialType(i),:)));
        % make the plotting
        if length(fl)>1
            errorbar_patch(-1:0.001:4,meanPSTH(i,:),errPSTH(i,:),colorSet(i,:));
        else
            plot(-1:0.001:4,squeeze(psthAll(1,plotTrialType(i),:)),'color',colorSet(i,:))
            hold on;
        end
        xlim([-0.9 3.9])
        title('US-')
    end    
    
    subplot(2,2,2)
    imagesc(squeeze(auROCall(:,1,:)),[0 1])
    colormap yellowblue
    title('90% reward')
    subplot(2,2,4)
    imagesc(squeeze(auROCall(:,6,:)),[0 1])
    colormap yellowblue
    title('50% omission')

end