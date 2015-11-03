
fl = what(pwd);
fl = fl.mat;
N = length(fl);

for i = 1:length(fl)
    load(fl{i},'analyzedData')
    %analyzedData = getPSTHSingleUnit(fl{i}); 
    %save(fl{i},'-append','analyzedData');
    rocPSTH(i,:,:) = analyzedData.rocPSTH(1:10,:);
    lickPSTH(i,:,:) = analyzedData.rawLick(1:10,:);
    rawPSTH(i,:,:) = analyzedData.rawPSTH(1:10,:);
    load(fl{i},'area');
    brainArea{i} = area;
end
proc = permute (rocPSTH(:,[1 2 7],10:40), [1,3,2]);
dataToCluster = squeeze(reshape(proc,N,1,[]));
%plotRSS_clusterNum(dataToCluster)
[eigvect,proj,eigval] = princomp(dataToCluster);

%% merge some areas
% PPTg: PPTg (all animals other than PPTg_an), PPTg_an('Laurel', 'Kittentail')
% LH: LH_po ('Waterlily','Rice') LH_psth('Aubonpain') LH_an (all others)

% areaSetting1: PPTg only posterior; LH only anterior
brainArea(ismember(brainArea,{'LH_an'})) = {'LH'};

% areaSetting2: PPTg all; LH all
brainArea(ismember(brainArea,{'LH_an','LH_psth','LH_po'})) = {'LH'};
brainArea(ismember(brainArea,{'PPTg_an','PPTg'})) = {'PPTg'};
%%
% change  the name of brain areas
oldnames = {'Striatum','LH','VS','PPTg','RMTg','VP','DA','VTA3','VTA2','STh'};
newnames = {'Dorsal striatum','Lateral hypothalamus','Ventral striatum',...
    'PPTg','RMTg','Ventral pallidum','Dopamine','VTA type3',...
    'VTA type2','Subthalamic'};
oldbrain = brainArea;
for i = 1:length(oldnames)
    idx = ismember(oldbrain,oldnames{i});
    brainArea(idx) = newnames(i);
end
%%
nclusters =7;
minD = inf;
for i = 1:50
    seeds = kmeansinit(dataToCluster,nclusters);
    [ind, ~, sumD] = kmeans(dataToCluster,nclusters, 'Start',seeds);
    if sum(sumD)<minD
        clustLabel = ind;
        minD = sum(sumD);
    end
end
% remap the clusterID by the mean response in each cluster
[clustLabel,plotorder] = reorder_clustLabel(clustLabel,mean(dataToCluster(:,1:20),2));
% 
%[~,plotorder] = sort(clustLabel);

%% 
clustlines = nan(3,nclusters-1);
for i = 1:nclusters-1
    temp = sum(clustLabel<=i) + 0.5;
    clustlines(1:2,i) = [temp;temp];
end
clustlines = clustlines(:); %now verticalize

figure('Position',[-14 -3 1000 787]);
p = panel();
p.pack('v',[0.6 0.2 0.2])
p(1).pack('h',6)
p(2).pack('h',nclusters)
p(3).pack('h',nclusters)

auROCvalue = rocPSTH(:,[1 2 7 4 9],:);
auROCvalue = permute(auROCvalue,[2 1 3]);
titleText = {'90% reward','50% reward','no reward','Airpuff','free Reward'};
for j = 1:5
    p(1,j).select()
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
        set(gca,'Box','off','TickDir','out','TickLength',[0.02 0.025])
end
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
    for k = 1:4
        a = squeeze(psthValue(k,find(clustLabel==j),:));
        %a = a(find(idx==1),:); % remove empty trials
        if min(size(a))>1
            averagePSTH = nanmean(a);
        else
            averagePSTH = a;
        end
        plot(smooth(averagePSTH,100),'Color',colorset(k,:),'LineWidth',1);hold on
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
    set(gca,'Box','off','TickDir','out','TickLength',[0.02 0.025])

    p(3,j).select()
    maxy = 0;
    for k = 1:4
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
    set(gca,'Box','off','TickDir','out','TickLength',[0.02 0.025])
end
%% calculate the number of neurons for each region in each cluster
orderAreas = {'Dopamine','VTA type2','VTA type3','PPTg','RMTg','Subthalamic',...
    'Lateral hypothalamus','Ventral pallidum','Dorsal striatum','Ventral striatum'
    };

oldbrain = brainArea;
grp = nan(1,length(brainArea));
for i = 1:length(orderAreas)
    idx = ismember(brainArea,orderAreas{i});
    grp(idx) = i;
end
% merge cluster 5,6,7, which are all type2
mergeClustLabel = clustLabel;
%mergeClustLabel(ismember(clustLabel,5:7)) = 5;

[tbl,chi2,p,labels] = crosstab(mergeClustLabel,grp);
totalNeuronPerArea = sum(tbl,1);
nor_tbl = tbl./repmat(totalNeuronPerArea,7,1); %5
c =color_select(5);
figure;
for i = 1:10
    subplot(3,4,i);
    for j = 1:5
        bar(j,nor_tbl(j,i),'FaceColor',c(j,:))
        hold on;
    end
    set(gca,'xtick',1:5)
    title(orderAreas{i})
end
% stacked version of the plot
figure;
barh(nor_tbl','stacked')
set(gca,'yticklabels',orderAreas)
legend({'cluster1','cluster2','cluster3','cluster4','cluster5','cluster6','cluster7'},'Location','EastOutside')
%%
psthValue = permute(rawPSTH(:,[1 2 7 4 9],:),[2 1 3] );
lickValue = permute(lickPSTH(:,[1 2 7 4 9],:),[2 1 3] );
for j = 1:5
    figure;
    p = panel();
    p.pack('h',[0.6,-1])
    p(1).select()
    barh(nor_tbl(j,10:-1:1),'FaceColor',c(j,:))
    set(gca,'ytick',1:10,'ytickLabel',orderAreas(10:-1:1))
    title(['cluster id: ',num2str(j) ])
    ylim([0 10])

    p(2).select()
    for k = 1:4
        a = squeeze(psthValue(k,find(mergeClustLabel==j),:));
        %a = a(find(idx==1),:); % remove empty trials
        if min(size(a))>1
            averagePSTH = nanmean(a);
        else
            averagePSTH = a;
        end
        plot(smooth(averagePSTH,100),'Color',colorset(k,:),'LineWidth',1);hold on
        if maxy < max(smooth(averagePSTH,100))
            maxy = max(smooth(averagePSTH,100));
        end
    end
    
    title(sprintf('Cluster %d n=%d ',j,length(find(mergeClustLabel==j))));
    xlabel('Time (s)');
    xlim([101 4800])
    %ylim([0 maxy+5])
    set(gca,'XTick',[1000:1000:5000],'XTickLabel',{'0','1','2','3'})
    ylabel('Firing Rate (spk/s)'); 
end

%% do the same plot for each area

% reorder the neurons so that cluster 1, 2, 3.. neurons are in sequential
% order
orderedROC = rocPSTH(plotorder,:,:);
orderedPSTH = rawPSTH(plotorder,:,:);
orderedLick = lickPSTH(plotorder,:,:);
orderedLabel = mergeClustLabel(plotorder);
orderedArea = brainArea(plotorder);
savePath = 'D:\Dropbox (Uchida Lab)\lab\FunInputome\rabies\analysis2015Fall\';
for i = 3:length(newnames)
    neuronIdx = strcmp(orderedArea,newnames{i});
    rocValues = orderedROC(neuronIdx,[1 2 7 4 9],:);
    rocValues = permute(rocValues,[2 1 3]);
    
    psthValue = permute(orderedPSTH(neuronIdx,[1 2 7 4 9],:),[2 1 3]);
    lickValue = permute(orderedLick(neuronIdx,[1 2 7 4 9],:),[2 1 3]);
    plot_clusters(orderedLabel(neuronIdx),rocValues,psthValue,lickValue,newnames{i});
    set(gcf,'units','normalized','outerposition',[0 0 1 1],'PaperPositionMode','auto');
    saveas(gcf,[savePath newnames{i} 'Input_cluster'],'tif')
end
%% plot all input areas and diversity measurement side by side
plotAreas = {'Dopamine','PPTg','RMTg','Lateral hypothalamus',...
    'Subthalamic','Ventral pallidum','Dorsal striatum','Ventral striatum'};
h1=figure;
h2=figure;
diversityIdx = [];
total_var = [];
for i = 1:length(plotAreas)
    neuronIdx = strcmp(brainArea,plotAreas{i});
    rocValues = squeeze(rocPSTH(neuronIdx,2,:));
    %r = squeeze(rawPSTH(neuronIdx,1,:)) 
%     tempROC = rocPSTH(neuronIdx,[1:3 5:7],11:30);
%     temp_div_data_roc = reshape(permute(tempROC,[1 3 2]),sum(neuronIdx),[]);
%     tempPSTH = rawPSTH(neuronIdx,[1:3 5:7],1001:3000);
%     norm_psth = [];
%     for k = 1:sum(neuronIdx)
%         a = [];
%         for j = 1:size(tempPSTH,2)
%             a(j,:) = smooth(tempPSTH(k,j,:),100);
%         end
%         a = reshape(a',1,[]);
%         norm_psth(k,:) = (a - min(a))/(max(a)-min(a));
%     end
%    div_data = norm_psth;
    % sort rocValues by its cue response
    [~,plt_idx] = sort(mean(rocValues(:,11:30),2),'ascend');
    figure(h1)
    subplot(2,length(plotAreas),i)
    imagesc(rocValues(plt_idx,:),[0 1])
    colormap yellowblue
    set(gca,'XTick',[10.5:10:50],'XTickLabel',{'0','1','2','3'},...
        'TickDir','out','TickLength',[0.02 0.025],'Box','off')
        title(plotAreas{i});

    rocValues = squeeze(rocPSTH(neuronIdx,6,:));
    subplot(2,length(plotAreas),i+length(plotAreas))
    imagesc(rocValues(plt_idx,:),[0 1])
    colormap yellowblue
    set(gca,'XTick',[10.5:10:50],'XTickLabel',{'0','1','2','3'},...
        'TickDir','out','TickLength',[0.02 0.025],'Box','off')
%    n = sum(neuronIdx);
%    n_time = size(div_data,2);
%     for j = 1:n_time
%         total_var(i,j) = sqrt(var(div_data(:,j))); %/(max(div_data(:,j))-min(div_data(:,j)))
%     end
    xlim([0.5 50.5])
    %diversityIdx(i) = sum(total_var);
    title(plotAreas{i});
%     figure(h2)
%     subplot(1,length(plotAreas),i)
%     plot(total_var(i,1:3001))
    %xlim([-10,41])
    %ylim([0 0.05])
end
%table(plotAreas',diversityIdx')
% figure;
% barh(8:-1:1,nanmean(total_var,2))
% set(gca,'ytickLabel',plotAreas(8:-1:1))
% xlabel('Average variance')

%%
figure('Position',[720  86   1693  1227]); 
xmax = -inf;
xmin = inf;
ymax = -inf;
ymin = inf;
for i = 1:length(plotAreas)
    neuronIdx = strcmp(brainArea,plotAreas{i});
    subplot(3,3,i)
    x = proj(neuronIdx,1);
    y = proj(neuronIdx,3);
    scatter(x,y)
    title(plotAreas{i})
    xlabel('PC1')
    ylabel('PC3')
    if min(x) < xmin
        xmin = min(x);
    end
    if max(x) > xmax
        xmax = max(x);
    end
    if min(y)<ymin
        ymin = min(y);
    end
    if max(y)>ymax
        ymax = max(y);
    end
end
for i = 1:length(plotAreas)
    subplot(3,3,i)
    xlim([xmin xmax])
    ylim([ymin ymax])
end
%%
figure;
plot(100*cumsum(eigval)/sum(eigval))
ylim([0 100]); xlim([0 20])
xlabel('number of PCs')
ylabel('% variance explained')

figure;
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

%%
plotAreas = {'Dopamine','PPTg','RMTg','Lateral hypothalamus',...
    'Subthalamic','Ventral pallidum','Dorsal striatum','Ventral striatum'};
all_eigval = [];
meanCorr = [];
bins = -1:0.1:1; 
hist_corr = zeros(length(plotAreas),length(bins));
for i = 1:length(plotAreas)
    neuronIdx = strcmp(brainArea,plotAreas{i});
    proc = permute (rocPSTH(neuronIdx,[1 2 5 6 7],10:40), [1,3,2]);
    proc = squeeze(reshape(proc,sum(neuronIdx),1,[]));
    c = corr(proc');
    ind = find(triu(c,1));
    meanCorr(i) = nanmean(c(ind));
    hist_corr(i,:) = hist(c(ind),bins)/length(ind);
    [eigvect,proj,eigval] = princomp(proc);
    all_eigval(:,i) = eigval;
end 

% figure;
% barh(all_eigval(1,:)./sum(all_eigval,1))
% set(gca,'yticklabels',plotAreas)

figure;
barh(meanCorr)
set(gca,'yticklabels',plotAreas)
xlabel('Mean pairwise correlation')
prettyP('','','','','a')

figure;
imagesc(flipud(hist_corr))
hold on; vline(11)
colormap gray
set(gca,'yticklabels',fliplr(plotAreas))
set(gca,'xtick',1:5:21,'xticklabel',{'-1','-0.5','0','0.5','1'})
set(gcf,'Color','w')
set(findall(gcf,'-property','FontName'),'FontName','Arial')
set(gca,'Box','off','FontSize',14,'FontName','Arial')
set(gca,'TickDir','out')
set(gca,'TickLength',[0.02 0.025])
