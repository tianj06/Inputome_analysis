fl = what(pwd);
fl = fl.mat;
N = length(fl);
for i = 1:length(fl)
    %load(fl{i},'analyzedData')
    analyzedData = getPSTHSingleUnit(fl{i}); 
    save(fl{i},'-append','analyzedData');
    rocPSTH(i,:,:) = analyzedData.rocPSTH(1:10,:);
    lickPSTH(i,:,:) = analyzedData.rawLick(1:10,:);
    rawPSTH(i,:,:) = analyzedData.rawPSTH(1:10,:);
end
proc = permute (rocPSTH(:,[1 2 7],10:40), [1,3,2]);
dataToCluster = squeeze(reshape(proc,N,1,[]));
plotRSS_clusterNum(dataToCluster)
[eigvect,proj,eigval] = princomp(dataToCluster);
%%
for i = 1:length(fl)
    a = load(fl{i},'area');
    brainArea{i} = a.area;
end
% change  the name of brain areas
oldnames = {'Striatum','LH','VS','PPTg','RMTg','VP','St','DA','VTA3','VTA2','Ce'};
newnames = {'Dorsal striatum','Lateral hypothalamus','Ventral striatum',...
    'PPTg','RMTg','Ventral pallidum','Dorsal striatum','Dopamine','VTA type3',...
    'VTA type2','Central amygdala'};
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
end
%% calculate the number of neurons for each region in each cluster
orderAreas = {'Dopamine','VTA type2','VTA type3','PPTg','RMTg','Central amygdala',...
    'Lateral hypothalamus','Ventral pallidum','Dorsal striatum','Ventral striatum'
    };

oldbrain = brainArea;
for i = 1:length(orderAreas)
    idx = ismember(oldbrain,orderAreas{i});
    grp(idx) = i;
end
% merge cluster 5,6,7, which are all type2
mergeClustLabel = clustLabel;
mergeClustLabel(ismember(clustLabel,5:7)) = 5;

[tbl,chi2,p,labels] = crosstab(mergeClustLabel,grp);
totalNeuronPerArea = sum(tbl,1);
nor_tbl = tbl./repmat(totalNeuronPerArea,5,1);
c =color_select(5);
figure;
for i = 1:10
    subplot(3,4,i);
    for j = 1:5
        bar(j,nor_tbl(j,i),'FaceColor',c(j,:))
        hold on;
    end
    set(gca,'xtick',1:7)
    title(orderAreas{i})
end

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
        plot(smooth(averagePSTH,100),'Color',colorset(k,:),'LineWidth',2);hold on
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

% this is still not right, probably needs to start over
for i = 1:length(orderAreas)
    neuronIdx = find(grp == i);
    rocValues = rocPSTH(plotorder(neuronIdx),[1 2 7 4 9],:);
    rocValues = permute(rocValues,[2 1 3]);
    
    psthValue = permute(rawPSTH(plotorder(neuronIdx),[1 2 7 4 9],:),[2 1 3] );
    lickValue = permute(lickPSTH(plotorder(neuronIdx),[1 2 7 4 9],:),[2 1 3] );
    a = mergeClustLabel(plotorder);
    plot_clusters(a(neuronIdx),rocValues,psthValue,lickValue)
end


