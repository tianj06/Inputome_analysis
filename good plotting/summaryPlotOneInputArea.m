% visualize all light response neurons
function summaryPlotOneInputArea(formattedpath, filelist, lightIdx,brainArea)
%%
saveFolder = 'C:\Users\uchidalab\Dropbox (Uchida Lab)\lab\FunInputome\rabies\analysis2015Fall\';
if strcmp(formattedpath(end),filesep)
    formattedpath = formattedpath(1:end-1);
end
smoothPSTH = zeros(length(filelist),10,5001);
rocPSTH = zeros(length(filelist),10,50);
lickPSTH = zeros(length(filelist),10,5001);
rawPSTH = zeros(length(filelist),10,5001);

for i = 1:length(filelist)
    load([formattedpath '\' filelist{i}], 'analyzedData')
    analyzedData = remove_too_few_trials(analyzedData);
    smoothPSTH(i,:,:) = analyzedData.smoothPSTH(1:10,:);
    rocPSTH(i,:,:) = analyzedData.rocPSTH(1:10,:);
    lickPSTH(i,:,:) = analyzedData.rawLick(1:10,:);
    rawPSTH(i,:,:) = analyzedData.rawPSTH(1:10,:);
    %
end
%% plot average psth for all neurons and identified neurons
averagePSTH = squeeze(nanmean(smoothPSTH));
averagelightPSTH = squeeze(nanmean(smoothPSTH(lightIdx,:,:)));
CueColor= [  0 	0 	255;%blue  
             30 	144 	255;%light blue  
             128 	128 128;
             255 0 0
             0 0 0
             0 255 0]/255; % grey
         trialType = [1 2 3 4 9 10];
figure('Position',[200 200 1000 787]);
subplot(2,2,1)
for i = [1 2 4 5 6]
        plot(averagePSTH(trialType(i),:),'color',CueColor(i,:),'LineWidth',1.5)
        i = i+1;
        hold on
end
%legend('90% W','50% W','90% puff','free water','free puff');  
%prettyP([200 4800],'','','','a')
xlim([200 4800])
title('all neurons average US+')

subplot(2,2,2)
for i = [1 2 4 5 6]
        plot(averagelightPSTH(trialType(i),:),'color',CueColor(i,:),'LineWidth',1.5)
        i = i+1;
        hold on
end
%legend('90% W','50% W','90% puff','free water','free puff');  
%prettyP([200 4800],'','','','a')
xlim([200 4800])
title('input neurons average US+')

subplot(2,2,3)
for i = 1:4
        plot(averagePSTH(i+4,:),'color',CueColor(i,:),'LineWidth',1.5)
        i = i+1;
        hold on
end
%legend('OM 90%W','OM 50%W','90% Nothing','OM 80% puff');  
%prettyP([200 4800],'','','','a')
xlim([200 4800])

title('all neurons average US-')

subplot(2,2,4)
for i = 1:4
        plot(averagelightPSTH(i+4,:),'color',CueColor(i,:),'LineWidth',1.5)
        i = i+1;
        hold on
end
%legend('OM 90%W','OM 50%W','90% Nothing','OM 80% puff');  
%prettyP([200 4800],'','','','a')
xlim([200 4800])
title('input neurons average US-')
suptitle([brainArea ' average PSTH'])
export_fig(gcf,[saveFolder brainArea '_AveragePSTH.pdf'])

%% plot auROC colormap by cue response sorted
auROCvalue = rocPSTH(:,[1 2 7 4 9],:);
auROCvalue = permute(auROCvalue,[2 1 3]);
cueResponse = nanmean(squeeze(rocPSTH(:,1,11:30)),2);
[~,plotorder] = sort(cueResponse);


figure('Position',[200 200 1000 787]);
subplot(1,6,1)
b = zeros(length(lightIdx),4);
b(lightIdx(plotorder),4) = 0.97;
imagesc(1-b,[0 1])
colormap(gca,'cool') 
axis off
titleText = {'90% reward','50% reward','no reward','Airpuff','free Reward'};

for j = 1:5
    subplot(1,6,j+1)
    plotValue = squeeze(auROCvalue(j,:,:));
    hold on;
    imagesc(plotValue(plotorder,:),[0 1]);
    colormap yellowblue
    axis(gca,'tight','ij');
    set(gca,'XTick',[10.5:10:50],'XTickLabel',{'0','1','2','3'})
    ylabel('Neuron'); xlabel('Time (s)');
    title(titleText{j});
end
suptitle( [brainArea 'all neurons sorted by Cue'])
export_fig([saveFolder brainArea 'ROCsortedByCue.pdf'])

%% clustering analysis
proc = permute (rocPSTH(:,[1 2 7],10:40), [1,3,2]);
dataToCluster = squeeze(reshape(proc,length(filelist),1,[]));
[eigvect,proj,eigval] = princomp(dataToCluster);
figure;
set(gcf,'Position',[360   242   920   706]);
p = panel();
p.pack('v',[0.4 -1])
p(1).pack('h',3)
p(1,1).select()
plot(100*cumsum(eigval)/sum(eigval))
ylim([0 100]); xlim([0 20])
xlabel('number of PCs')
ylabel('% variance explained')
% figure;imagesc(proj(:,1:20),[-2.5 2.5])
% colormap yellowblue
p(1,2).select()
gscatter(proj(:,1),proj(:,2),lightIdx,'br','.o');
xlabel('PC1')
ylabel('PC2')
legend('others','identified')
p(1,3).select()
gscatter(proj(:,1),proj(:,3),lightIdx,'br','.o');
xlabel('PC1')
ylabel('PC3')
legend('others','identified')
p(2).select()
pvec = eigvect(:,1:3);
nanvec = nan(3,size(pvec,2));
pvec = [pvec(1:31,:); nanvec; pvec(32:62,:); nanvec; pvec(63:93,:)]; % nanvec; pvec(94:end,:)
plot(pvec(:,1:3))
varExp = eigval/sum(eigval);
for i = 1:3
    legendStr{i} = sprintf('PC%d Var:%0.2f',i,varExp(i));
end
legend(legendStr,'Location','Eastoutside')
tPos = 15:33:124;
tText = {'90% W','50% W','0% W'};%,'80% Puff'
for i = 1:length(tText)
    text(tPos(i),0.2,tText{i})
end
%suptitle('Pricinple component analysis')
%saveas(gcf,[saveFolder brainArea 'PCAresults.jpg'])
export_fig([saveFolder brainArea 'PCAresults.pdf'])
%% try to decide number of clusters by ploting RSS vs number of cluster
% add dimension reduction of dataToCluster
%%
%
for i = 1:10
    nclusters =i;
    minD = inf;
    for k = 1:50
        seeds = kmeansinit(dataToCluster,nclusters);
        [ind, ~, sumD] = kmeans(dataToCluster,nclusters, 'Start',seeds);
        if sum(sumD)<minD
            clustLabel = ind;
            minD = sum(sumD);
        end
    end
    % calculate RSS
    RSS(i) = 0;
    for j = 1:i
        clustIdx = find(clustLabel == j);
        r = dataToCluster(clustIdx,:) - ...
            repmat(mean(dataToCluster(clustIdx,:)),length(clustIdx),1);
        RSS(i) = RSS(i) + sum(sum(r.*r));
    end
end
r = dataToCluster - repmat(mean(dataToCluster),size(dataToCluster,1),1);
totalRSS = sum(sum(r.*r));
figure;plot(1:10,1-RSS/totalRSS)
xlabel('Number of clusters')
ylabel('1-RSS or variance explained')
ylim([0 1])
export_fig(gcf,[saveFolder brainArea 'KmeanClusteringRSS.pdf'])
%%
nclusters =4;
minD = inf;
for i = 1:50
    seeds = kmeansinit(dataToCluster,nclusters);
    [ind, ~, sumD] = kmeans(dataToCluster,nclusters, 'Start',seeds);
    if sum(sumD)<minD
        clustLabel = ind;
        minD = sum(sumD);
    end
end
[~,plotorder] = sort(clustLabel);
% 
clustlines = nan(3,nclusters-1);
for i = 1:nclusters-1
    temp = sum(clustLabel<=i) + 0.5;
    clustlines(1:2,i) = [temp;temp];
end
clustlines = clustlines(:); %now verticalize
% 
% figure;
% subplot(1,8,1)
% b = zeros(length(lightIdx),4);
% b(lightIdx(plotorder),4) = 0.97;
% imagesc(1-b,[0 1])
% colormap(gca,'cool') 
% axis off
% 
% subplot(1,8,2:8)
% imagesc(dataToCluster(plotorder,:)); %[0 1]
% hold on;
% colormap yellowblue
% axis(gca,'tight','ij');
% xlines = cat(1,repmat(xlim',[1,nclusters-1]), nan(1,nclusters-1));
% xlines = xlines(:);
% plot(xlines,clustlines,'r');
% set(gca,'XTick',[10.5:10:50],'XTickLabel',{'0','1','2','3'})
% ylabel('Neuron'); xlabel('Time (s)');
% plot postROC heatmap

%%
figure('Position',[-14 -3 1000 787]);
p = panel();
p.pack('v',[0.6 0.2 0.2])
p(1).pack('h',6)
p(2).pack('h',nclusters)
p(3).pack('h',nclusters)

b = zeros(length(lightIdx),2);
b(lightIdx(plotorder),2) = 0.97;
p(1,1).select()
imagesc(1-b,[0 1])
ylim([1 length(lightIdx)])
colormap(gca,'cool') 
axis off
auROCvalue = rocPSTH(:,[1 2 7 4 9],:);
auROCvalue = permute(auROCvalue,[2 1 3]);
titleText = {'90% reward','50% reward','no reward','Airpuff','free Reward'};
for j = 1:5
    p(1,j+1).select()
    plotValue = squeeze(auROCvalue(j,:,:));
    hold on;
    imagesc(plotValue(plotorder,:),[0 1]);
    colormap yellowblue
    axis(gca,'tight','ij');
     xlines = cat(1,repmat(xlim',[1,nclusters-1]), nan(1,nclusters-1));
     xlines = xlines(:);
     plot(xlines,clustlines,'r');
    set(gca,'XTick',[10.5:10:50],'XTickLabel',{'0','1','2','3'})
    ylabel('Neuron'); xlabel('Time (s)');
    title(titleText{j});
end

%%
colorset= [  0 	0 	255;%blue  
             30 	144 	255;%light blue  
             128 	128 128;
             255 0 0
             0 0 0]/255; % grey
psthValue = permute(rawPSTH(:,[1 2 7 4 9],:),[2 1 3] );
lickValue = permute(lickPSTH(:,[1 2 7 4 9],:),[2 1 3] );

for j = 1:nclusters
    p(2,j).select()
    %figure;
%     a = squeeze(psthValue(2,find(clustLabel==j),:));
%     idx = ~isnan(a(:,1));
    maxy = 0;
    for k = 1:5
        a = squeeze(psthValue(k,find(clustLabel==j),:));
        %a = a(find(idx==1),:); % remove empty trials
        if min(size(a))>1
            averagePSTH = nanmean(a);
        else
            averagePSTH = a;
        end
        plot(smooth(averagePSTH,100),'Color',colorset(k,:),'LineWidth',2);hold on
        if maxy < max(smooth(averagePSTH,100))
            maxy = max(smooth(averagePSTH,100));
        end
    end
    
    title(sprintf('Cluster %d n=%d ',j,length(find(clustLabel==j))));
    xlabel('Time (s)');
    xlim([101 4800])
    %ylim([0 maxy+5])
    set(gca,'XTick',[1000:1000:5000],'XTickLabel',{'0','1','2','3'})
    ylabel('Firing Rate (spk/s)'); 
    
    
    p(3,j).select()
    maxy = 0;
    for k = 1:5
        a = squeeze(lickValue(k,find(clustLabel==j),:));
        %a = a(find(idx==1),:); % remove empty trials
        if min(size(a))>1
            averagePSTH = nanmean(a);
        else
            averagePSTH = a;
        end
        plot(smooth(averagePSTH,100),'Color',colorset(k,:),'LineWidth',2);hold on
        if maxy < max(smooth(averagePSTH,100))
            maxy = max(smooth(averagePSTH,100));
        end
    end
    
    title(sprintf('Cluster %d n=%d ',j,length(find(clustLabel==j))));
    xlabel('Time (s)');
    xlim([101 4800])
    %ylim([0 maxy+5])
    set(gca,'XTick',[1000:1000:5000],'XTickLabel',{'0','1','2','3'})
    ylabel('Lick Rate (spk/s)'); 
end
export_fig(gcf,[saveFolder brainArea 'KmeansClusteringPSTH.pdf'])
