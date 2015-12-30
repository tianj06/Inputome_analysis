
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
%% remove VTA rabies units
VTAind = ismember(brainArea,{'rVTA Type2','r VTA Type3','rdopamine'});
fl = fl(~VTAind);
rocPSTH = rocPSTH(~VTAind,:,:);
lickPSTH = lickPSTH(~VTAind,:,:);
rawPSTH = rawPSTH(~VTAind,:,:);
brainArea = brainArea(~VTAind);
N = length(fl);
%% merge some areas
% PPTg: PPTg (all animals other than PPTg_an), PPTg_an('Laurel', 'Kittentail')
% LH: LH_po ('Waterlily','Rice') LH_psth('Aubonpain') LH_an (all others)

% areaSetting1: PPTg only posterior; LH only anterior
%brainArea(ismember(brainArea,{'LH_an'})) = {'LH'};

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
inputareas = {'Dorsal striatum','Lateral hypothalamus','Ventral striatum',...
    'PPTg','RMTg','Ventral pallidum','Subthalamic'}; % ,'Dopamine','VTA type3', 'VTA type2'
inputA = ismember(brainArea, inputareas);

%% kmeans clustering
proc = permute (rocPSTH(:,[1 2 7],10:40), [1,3,2]);
temp = squeeze(reshape(proc,N,1,[]));
[eigvect,proj,eigval] = princomp(temp);
dataToCluster = proj(:,1:3);
neuronResponse = mean(rocPSTH(:,1,11:30),3);
rocPCs.eigvect = eigvect;
rocPCs.proj = proj;
rocPCs.eigval = eigval;
rocPCs.fl = fl;
rocPCs.brainArea = brainArea;
%% compare clustering using first 3 PCs
a = rawPSTH(:,[1 2 7],1:4000);
for i = 1:size(a,1)
    for j = 1:size(a,2)
        a(i,j,:) = smooth(a(i,j,:),100); % -mean(a(i,j,1:1000))
    end
end

proc = permute(a(:,:,10:10:end-10),[1,3,2]);

temp = squeeze(reshape(proc,size(a,1),1,[]));
for i = 1:size(temp,1)
    temp(i,:) = temp(i,:)/max(temp(i,:)); 
end

[eigvect,proj,eigval] = princomp(temp);
dataToCluster = proj(:,1:3);
plotRSS_clusterNum(dataToCluster)

%%
nclusters =7;
minD = inf;
for i = 1:100
    seeds = kmeansinit(dataToCluster,nclusters);
    [ind, ~, sumD] = kmeans(dataToCluster,nclusters, 'Start',seeds);
    if sum(sumD)<minD
        clustLabel = ind;
        minD = sum(sumD);
    end
end
% remap the clusterID by the mean response in each cluster
[clustLabel,plotorder] = reorder_clustLabel(clustLabel,neuronResponse);
% swap cluster 4 and 5
oldclustLabel = clustLabel;
clustLabel(oldclustLabel==4) = 5;
clustLabel(oldclustLabel==5) = 4;
rocPCs.clustLabel = clustLabel;

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
%% project the clusters to PCs
%[eigvect,proj,eigval] = princomp(dataToCluster);
%proj(:,1) = - proj(:,1);
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
%%
%plot the major PCs
%[eigvect,proj,eigval] = princomp(dataToCluster(inputA,:));
nPC = 3;
PCs = eigvect(:,1:nPC);
PCs = reshape(PCs,[],3,nPC);
colorset= [  0 	0 	255;%blue  
             30 	144 	255;%light blue  
             128 	128 128;]/255; % grey
figure;
for i = 1:nPC
    subplot(1,nPC,i)
    for j = 1:3
        plot(squeeze(PCs(:,j,i)),'color',colorset(j,:))
        hold on;
    end
    %set(gca,'xtick',[1:10:30],'xticklabel',{'0','1','2'})
    title(sprintf('PC %d var: %0.1f%%', i,100*eigval(i)/sum(eigval)))
    xlabel('Time - odor (s)')
end

%% calculate the number of neurons for each region in each cluster
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
nor_tbl = tbl./repmat(totalNeuronPerArea,7,1); %5
figure;
for i = 1:10
    subplot(3,4,i);
    for j = 1:length(unique(mergeClustLabel))
        bar(j,nor_tbl(j,i),'FaceColor',c(j,:))
        hold on;
    end
    set(gca,'xtick',1:5)
    title(orderAreasNames{i})
end
%% stacked version of the plot
figure;
h = barh(nor_tbl','stacked')
set(gca,'yticklabels',orderAreasNames)
for i = 1:nclusters
    h(i).FaceColor = c(i,:);
end
legend({'cluster1','cluster2','cluster3','cluster4','cluster5','cluster6','cluster7'},'Location','EastOutside')
%% plot the average response for each input area in each cluster
m = 1;
figure;
for i = 1:7
    clusterInd = clustLabel==i;
    for j = 1:length(orderAreas)
        areaName = orderAreas{j};
        areaInd = strcmp(brainArea,orderAreas{j});
        plotInd = clusterInd&areaInd';
        subplot(7,length(orderAreas),m)
        m = m + 1;
        maxy = 0;
        for k = 1:3
            a = squeeze(psthValue(k,plotInd,:));
            %a = a(find(idx==1),:); % remove empty trials
            if min(size(a))>1
                averagePSTH = nanmean(a);
            else
                averagePSTH = a;
            end
            tempTrace = smooth(averagePSTH,100);
            plot(tempTrace(1:10:end),'Color',colorset(k,:),'LineWidth',1);hold on
            if maxy < max(tempTrace)
                maxy = max(tempTrace);
            end
        end

        title(sprintf('n=%d ',sum(plotInd)));
        xlim([10 480])
        %ylim([0 maxy+5])
        set(gca,'XTick',[100:100:500],'XTickLabel',{})
        set(gca,'Box','off','TickDir','out','TickLength',[0.02 0.025])
    end
end
%% plot each area top pcs
nPC = 4;

colorset= [  0 	0 	255;%blue  
             30 	144 	255;%light blue  
             128 	128 128;
             255 0 0]/255; % grey

a = rawPSTH(:,[1 2 7],1:4000);
for i = 1:size(a,1)
    for j = 1:size(a,2)
        a(i,j,:) = smooth(a(i,j,:),100); % -mean(a(i,j,1:1000))
    end
end
proc = permute(a(:,:,10:10:end-10),[1,3,2]);

dataToCluster = squeeze(reshape(proc,size(a,1),1,[]));
for i = 1:size(dataToCluster,1)
    dataToCluster(i,:) = dataToCluster(i,:)/max(dataToCluster(i,:)); 
end

[eigvect,proj,eigval] = princomp(dataToCluster);
nPC = 4;
PCs = eigvect(:,1:nPC);
PCs = reshape(PCs,size(proc,2),size(proc,3),nPC);
figure;
PCs(:,:,1) = -PCs(:,:,1);

for i = 1:nPC
    subplot(1,nPC,i)
    for j = 1:3
        plot(squeeze(PCs(:,j,i)),'color',colorset(j,:))
        hold on;
    end
    xlim([1,size(proc,2)])
    title(sprintf('PC%d var %0.1f%%',i,100*eigval(i)/sum(eigval)))
end
%%
% proc = permute (rocPSTH(:,[1 2 7 4],10:40), [1,3,2]);
% dataToCluster = squeeze(reshape(proc,N,1,[]));
oldbrainArea = brainArea;
brainArea(ismember(brainArea,{'Dopamine','VTA type2','VTA type3'})) = {'VTA'};
oldorderAreas = orderAreas;
orderAreas = [{'VTA'},orderAreas(4:end)];
figure;
for m = 1:length(orderAreas)
    areaName = orderAreas{m};
    areaInd = strcmp(brainArea,orderAreas{m});
    [eigvect,proj,eigval] = princomp(dataToCluster(areaInd,:));
    PCs = eigvect(:,1:nPC);
    PCs = reshape(PCs,size(proc,2),size(proc,3),nPC);
    for i = 1:nPC
        subplot(nPC,length(orderAreas),(i-1)*length(orderAreas)+m) 
        if i==1
            PCs(:,:,i) = -PCs(:,:,i);
        end
        for j = 1:3
            plot(squeeze(PCs(:,j,i)),'color',colorset(j,:))
            hold on;
        end
        %set(gca,'xtick',[0:10:30],'xticklabel',{'0','1','2','3'})
        %xlim([0 30])
        set(gca,'xtick',[0:100:300],'xticklabel',{'0','1','2','3'})
        xlim([0 400])
        title(sprintf('var %0.1f%%',100*eigval(i)/sum(eigval)))
    end
end

%% for each area, plot baseline seperated by cluster label
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
%% compare low firing rate neurons in dorsal, ventral striatum and ventral pallidum
areasIn = {'Dorsal striatum','Ventral striatum','Ventral pallidum'};
N_area = length(areasIn);
figure;
for i = 1:N_area
    areaInd = strcmp(brainArea,areasIn{i});
    blInd = bl < 15;
    clustInd = clustLabel == 2;
    plotroc = squeeze(rocPSTH(areaInd'&clustInd&blInd,1,:));
    subplot(1,N_area,i)
    imagesc(plotroc,[0 1])
    colormap yellowblue
    title(areasIn{i})
    set(gca,'XTick',[10.5:10:50],'XTickLabel',{'0','1','2','3'})
end

% fplot = fl(strcmp(brainArea','Ventral striatum')&clustLabel == 2);
% for i = 1:length(fplot)
%     quickPSTHPlotting_formatted_new(fplot{i})
% end
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
plotAreas = fliplr(plotAreas);
h1=figure;
h2=figure;
diversityIdx = [];
total_var = [];
all_plot_idx = {};
for i = 1:length(plotAreas)
    neuronIdx = strcmp(brainArea,plotAreas{i});
    rocValues = squeeze(rocPSTH(neuronIdx,1,:));
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
    set(gca,'ytick',[])

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
    set(gca,'ytick',[])
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
stdCorr = [];
bins = -1:0.1:1; 
hist_corr = zeros(length(plotAreas),length(bins));
nanNum = zeros(length(plotAreas),2);
for i = 1:length(plotAreas)
    neuronIdx = strcmp(brainArea,plotAreas{i});
    proc = permute (rocPSTH(neuronIdx,[1 2 5 6 7],10:40), [1,3,2]);
    proc = squeeze(reshape(proc,sum(neuronIdx),1,[]));
    c = corr(proc');
    ind = find(triu(c,1));
    nanNum(i,1) = sum(isnan(c(ind)));
    nanNum(i,2) = sum(length(ind));
    
    meanCorr(i) = nanmean(c(ind));
    stdCorr(i) = nanstd(c(ind));
    hist_corr(i,:) = hist(c(ind),bins)/length(ind);
    [eigvect,proj,eigval] = princomp(proc);
    all_eigval(:,i) = eigval;
end 

% figure;
% barh(all_eigval(1,:)./sum(all_eigval,1))
% set(gca,'yticklabels',plotAreas)

figure;
barh(meanCorr)
hold on
herrorbar(meanCorr,[1:8],stdCorr)
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

%%
i= 2;
neuronIdx = strcmp(brainArea,plotAreas{i});
proc = squeeze(rocPSTH(neuronIdx,1,10:40))';
figure;
plot(proc(:,1:8:end))
prettyP('','','','','a')
xlim([0 30])
set(gca,'xtick',[0:10:30],'xticklabel',{'0','1','2','3'})
ylim([0.1 1])
set(gca,'ytick',[0:0.2:1])
%%
i = 1;
neuronIdx = strcmp(brainArea,plotAreas{i});
proc = permute (rocPSTH(neuronIdx,[1 2 5 6 7],10:40), [1,3,2]);
proc = squeeze(reshape(proc,sum(neuronIdx),1,[]))';
figure;
plot(proc(:,[2 11]))
prettyP('',[0 1],'',[0 0.5 1],'a')
set(gca,'xtick',[0:31:155],'xticklabel',{'0','1','2','3'})
c = corr(proc(:,[2 10]));
title(num2str(c(1,2)))
