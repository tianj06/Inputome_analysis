filePath = 'D:\Dropbox (Uchida Lab)\lab\FunInputome\rabies\rabies_VTA\analysis\DAtype';

fl = dir(filePath);
fl(1:2) = [];
fl = {fl.name};



for i = 1:length(fl)
    fn = [fl{i}(1:end-4) '_formatted.mat']; %
    load(fn)
    psthAll(i,:,:) = analyzedData.smoothPSTH;
    rocAll(i,:,:) = analyzedData.rocPSTH;
end

%% calculate average record days


%% those are for control plottings
% fl = what(pwd);
% fl = fl.mat;
% 
% for i = 1:length(fl)
%     fn = fl{i}; %
%     load(fn)
%     psthAll(i,:,:) = analyzedData.smoothPSTH;
%     rocAll(i,:,:) = analyzedData.rocPSTH;
% end
%%
figure;
imagesc(squeeze(rocAll(:,1,:)),[0 1])
colormap yellowblue
set(gcf,'Color','w')
set(gca,'Box','off','FontSize',14)
set(gca,'xtick',[10.5:10:41],'xtickLabel',{'0','1','2','3'})
title('90% reward')
xlabel('Time-odor (s)')
ylabel('# Neuron')

%%
figure;
    % color for 90% water, 50% water, nothing, and airpuff; will modify later
    colorSet = [0 	0 	255;%blue  
                   30 	144 	255;%light blue  
                   128 	128 128; % grey
                    255 0 0]/255; % black;
    plotTrialType = [1 2 7 4];
    bin = 10;
    for i = 1:length(plotTrialType)
        errPSTH(i,:) = nanstd(squeeze(psthAll(:,plotTrialType(i),:)))/sqrt(length(fl));
        meanPSTH(i,:) = nanmean(squeeze(psthAll(:,plotTrialType(i),:)));
        % make the plotting
        binPSTH(i,:) = mean(reshape(meanPSTH(i,1:5000),10,[]));
        temp = squeeze(psthAll(:,plotTrialType(i),:));
        for j = 1:length(fl)
            temp_bin(j,:) = squeeze(nanmean(reshape(temp(j,1:5000),10,[])));
        end
        errBinPSTH = nanstd(temp_bin)/sqrt(length(fl));
        if length(fl)>1000
            %errorbar_patch(-1:0.001:4,meanPSTH(i,:),errPSTH(i,:),colorSet(i,:));
            errorbar_patch(linspace(-1,4,500),binPSTH(i,:),errBinPSTH,colorSet(i,:));

        else
            %plot(-1:0.001:4,squeeze(psthAll(1,plotTrialType(i),:)),'color',colorSet(i,:)); hold on;
            plot(linspace(-1,4,500),squeeze(binPSTH(i,:)),'color',colorSet(i,:),'LineWidth',1.5); hold on;

        end
        xlim([-0.9 3.8])
    end
   prettyP ('','',[0:3],'','a')
   %legend({'90% water','50% water', 'nothing', '80% airpuff'},'location','eastoutside')
   %title('US+')
xlabel('Time-odor (s)')
ylabel('Spikes/s')
legend({'Reward (P=0.9)','Reward (P=0.5)','Reward (P=0)','Airpuff (P=0.8)'},'Location','EastOutside')
