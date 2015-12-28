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
%% project the clusters to PCs
%[eigvect,proj,eigval] = princomp(dataToCluster);
proj(:,1) = - proj(:,1);
figure;
c =color_select(7,'hsv');
c(4,:) = [0 1 1];
c = flipud(c);
h = gscatter(proj(:,1),proj(:,2),clustLabel);
xlabel('PC1')
ylabel('PC2')
for i = 1:length(h)
    h(i).Color = c(i,:);
end
hold on; vline(0); hline(0)
figure;
h = gscatter(proj(:,1),proj(:,3),clustLabel);
xlabel('PC1')
ylabel('PC3')
for i = 1:length(h)
    h(i).Color = c(i,:);
end
hold on; vline(0); hline(0)

orderAreas = {'Dopamine','VTA type2','VTA type3','PPTg','RMTg','Subthalamic',...
    'Lateral hypothalamus','Ventral pallidum','Dorsal striatum','Ventral striatum'
    };
orderAreasNames = {'Dopamine','VTA type2','VTA type3','PPTg','RMTg','Subthalamic',...
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
nor_tbl = tbl./repmat(totalNeuronPerArea,nclusters,1); %5
figure;
h = barh(nor_tbl','stacked')
set(gca,'yticklabels',orderAreasNames)
for i = 1:nclusters
    h(i).FaceColor = c(i,:);
end
legend({'cluster1','cluster2','cluster3','cluster4','cluster5','cluster6','cluster7'},'Location','EastOutside')
%%
c =color_select(7,'hsv');
c(4,:) = [0 1 1];
c = flipud(c);
bl = squeeze(mean(rawPSTH(:,:,1:1000),3));
bl = mean(bl(:,[1,7]),2);
figure;
for m = 1:length(orderAreas)+1
    if m == length(orderAreas)+1
        areaName = 'all';
        tempbl = bl;
        templabel = clustLabel;
    else
        areaName = orderAreas{m};
        areaInd = strcmp(brainArea,orderAreas{m});
        tempbl = bl(areaInd);
        templabel = clustLabel(areaInd);
    end
    uniqueLabels = unique(templabel);
    binSize = round(max(tempbl)/10);
    maxBl = 10*round(max(tempbl)/10);
    bins = 0:binSize:maxBl;
    plotdata = zeros(length(uniqueLabels),length(bins));
    for i = 1:length(uniqueLabels)
        plotdata(i,:) = hist(tempbl(templabel==uniqueLabels(i)),bins);
    end
    subplot(3,4,m)
    h = bar(bins,plotdata','stacked');
    for i = 1:length(h)
        h(i).FaceColor = c(uniqueLabels(i),:);
    end
    set(gcf,'Color','w')
    set(gca,'Box','off','TickDir','out','TickLength',[0.02 0.025])
    title(areaName)
    xlim([-binSize, maxBl+binSize])
end
subplot(3,4,m+1)
for i = 1:7
    bar(1,0,'FaceColor',c(i,:))
    hold on
end
legend({'cluster1','cluster2','cluster3','cluster4','cluster5',...
    'cluster6','cluster7'},'Location','EastOutside')