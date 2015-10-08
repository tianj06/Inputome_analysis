homepath = 'C:\Users\uchidalab\Dropbox (Uchida Lab)\lab\FunInputome\rabies\rabies_VTA\';
fl_rabies = [homepath 'analysis\vta_light.mat'];
load(fl_rabies)
rocPSTH_r = [];
rawPSTH_r = [];
for i = 1:length(lihgtfiles)
    %analyzedData = getPSTHSingleUnit(lihgtfiles{i}); 
    %save(lihgtfiles{i},'-append','analyzedData');
    load([homepath 'formatted\' lihgtfiles{i}],'analyzedData')
    rawPSTH_r(i,:,:) = analyzedData.rawPSTH;
    rocPSTH_r(i,:,:) = analyzedData.rocPSTH;
end

fl_aav = what([homepath 'controlVTA\']);
fl_aav = fl_aav.mat;
raster_a = cell(length(fl_aav),14);
for i = 1:length(fl_aav)
    %analyzedData = getPSTHSingleUnit(fl_aav{i}); 
    %save(fl_aav{i},'-append','analyzedData');
    load([homepath 'controlVTA\' fl_aav{i}],'analyzedData')
    rawPSTH_a(i,:,:) = analyzedData.rawPSTH;
    rocPSTH_a(i,:,:) = analyzedData.rocPSTH;
end

psthAll = [rawPSTH_r ; rawPSTH_a];
%% clustering all neurons into type 1 2 3
allroc = [rocPSTH_r ; rocPSTH_a];
dataToCluster = squeeze(allroc(:,1,11:40));
nclusters =3;
minD = inf;
for i = 1:100
    seeds = kmeansinit(dataToCluster,nclusters);
    [ind, ~, sumD] = kmeans(dataToCluster,nclusters, 'Start',seeds);
    if sum(sumD)<minD
        clustLabel = ind;
        minD = sum(sumD);
    end
end
% most abundant type1
% second type2 
% third type3
l=[];
for i = 1:nclusters
    l(i) = length(find(clustLabel==i)); % the number of members in cluster
end
    
[~,idx] = sort(l,'descend');
for i = 1:nclusters
    clustLabel(clustLabel==idx(i)) = nclusters+i;
end
clustLabel  = clustLabel-nclusters;


clustlines = nan(3,nclusters-1);
for i = 1:nclusters-1
    temp = sum(clustLabel<=i) + 0.5;
    clustlines(1:2,i) = [temp;temp];
end
clustlines = clustlines(:); %now verticalize
[~,plotorder] = sort(clustLabel);
figure('Position',[-14 -3 1000 787]);

auROCvalue = allroc(:,[1 2 7],:);
auROCvalue = permute(auROCvalue,[2 1 3]);
titleText = {'90% reward','50% reward','no reward','Airpuff','free Reward'};
% mark the AAV light identified neurons
% mark the rabies label
subplot(1,4,1)
idx = plotorder< size(rocPSTH_r,1);
b = zeros(length(idx),4);
b(idx,4) = 0.97;
imagesc(1-b,[0 1])
colormap(gca,'colorcube') 
axis off

for j = 1:3
    subplot(1,4,j+1)
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
%% save type1 neurons
Nr = length(lihgtfiles);
allType1 = clustLabel==1;
rabies_type1 = lihgtfiles(allType1(1:Nr));
save('rabiesType1','rabies_type1')
AAV_type1 = fl_aav(allType1(Nr+1:end));
save('aavType1','AAV_type1')
rabies_clustLabel = clustLabel(1:Nr);
aav_clustLabel = clustLabel(Nr+1:end);
%% compute significant response 
rabies_label = 1:size(dataToCluster,1)<= Nr; % first Nr neurons are rabies

sigpair = {[11 13],[1,2],[5 7]};
windowpair = {[1000 1600],[3000 3400],[3000 4000]};
for i = 1:length(lihgtfiles)
    load([homepath 'formatted\' lihgtfiles{i}],'analyzedData')
    r = analyzedData.raster;
    for j = 1:length(sigpair)
        timeWin = windowpair{j}(1):windowpair{j}(2);
        responses = {};
        for k = 1:2
            responses{k} = mean(r{sigpair{j}(k)}(:,timeWin),2);
        end
        [~,sigresult(i,j)] = ranksum(responses{1},responses{2}); 
        responses{k} = mean(r{sigpair{j}(k)}(:,timeWin));
    end
end

for i = 1:length(fl_aav)
    load([homepath 'controlVTA\' fl_aav{i}],'analyzedData')
    r = analyzedData.raster;
    for j = 1:length(sigpair)
        timeWin = windowpair{j}(1):windowpair{j}(2);
        responses = {};
        for k = 1:2
            responses{k} = mean(r{sigpair{j}(k)}(:,timeWin),2);
        end
        if ~isempty(responses{1})
            [~,sigresult(i+length(lihgtfiles),j)] = ranksum(responses{1},responses{2}); 
        else
            sigresult(i+length(lihgtfiles),j) = 0;
        end
    end
end
% calculate baseline
b = squeeze(mean(mean(psthAll(:,11:14,1:1000),3),2));
b1 = b;
%% scatter plot for all pairs of events
labels = {'90% cue', '0% cue'; '90%W','50%W';'OM 90%W','OM 0%W'};
figure;
clusterID = 1;
resp_spikes = cell(3,2);
for k = 1:2
    if k==1
        neuronIdx = rabies_label'&(clustLabel==clusterID);
    else
        neuronIdx = (~rabies_label')&(clustLabel==clusterID);
    end
    for j = 1:length(sigpair)
        timeWin = windowpair{j}(1):windowpair{j}(2);
        responses = squeeze(mean(psthAll(neuronIdx,sigpair{j},timeWin),3)) - ...
        repmat(b(neuronIdx),1,2);
        resp_spikes{j,k} = responses(:,1)- responses(:,2);      
        %('Position',[ 377   476   658   295])
        fig_pos = 2*(j-1)+k;
        subplot(3,2,fig_pos);
        scatter(responses(:,1),responses(:,2))
        hold on;
        if j ==1 
            sigIdx = find(sigresult(neuronIdx,j)&(resp_spikes{j,k} > 0));
        else
            sigIdx = find(sigresult(neuronIdx,j)&(resp_spikes{j,k}  < 0));
        end
        scatter(responses(sigIdx,1),responses(sigIdx,2),'filled');
        refline(1,0)
        xlabel(labels{j,1})
        ylabel(labels{j,2})
        prettyP('','','','','a')
        percentSig(j,k) = length(sigIdx)/sum(neuronIdx);
        title(['percent significant:' num2str(percentSig(j,k))])
    end
end
% make a box plot to show quantitative difference between rabies and vta
group = [];
data = [];
figure;
for i = 1:3
    subplot(1,3,i)
    p_box(i) = ranksum(resp_spikes{i,1},resp_spikes{i,2});
    data = [resp_spikes{i,1}; resp_spikes{i,2}];
    group = [(2*i-1)*ones(length(resp_spikes{i,1}),1);2*i*ones(length(resp_spikes{i,2}),1)];
    boxplot(data,group)
    ylabel([labels(i,1) '-' labels(i,2)])
    set(gca,'xtick',[1,2],'xticklabels',{'rabies','AAV'});
    sigstar({[1,2]},p_box(i))
end
% make bar plot to show no quanlitative difference between rabies and vta
figure;
for i = 1:3
    subplot(1,3,i)
    bar(100*percentSig(i,:))
    ylabel([labels(i,1) '-' labels(i,2)])
    set(gca,'xtick',[1,2],'xticklabels',{'rabies','AAV'});
    ylim([0 100])
end
suptitle('Percent significant')
%%
figure;
b1 = b(rabies_label&(clustLabel'==1));
b2 = b(~rabies_label&(clustLabel'==1));
boxplot([b1;b2],[ones(length(b1),1); 2*ones(length(b2),1)])
set(gca,'xtick',[1,2],'xticklabel',{'rabies','AAV'})
title('Baseline')
ylabel('Spikes/s')
%xlim([0.5 2.5])
sigstar({[1,2]},ranksum(b1,b2))

%% plot psth rabies type1 vs AAV type1 
colorset= [  0 	0 	255;%blue  
             30 	144 	255;%light blue  
             0 0 0]/255; % grey
maxy = 0;
clusterID = 2;
figure;
ExpText = {'rabies','AAV'};
for i = 1:2
    subplot(2,1,i)
    if i==1
        neuronIdx = rabies_label'&(clustLabel==clusterID);
    else
        neuronIdx = (~rabies_label')&(clustLabel==clusterID);
    end
    for k = 1:3
        a = squeeze(psthAll(neuronIdx,k,:));
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
    
    title(sprintf('%s Cluster %d n=%d ',ExpText{i},clusterID,size(a,1)));
    xlabel('Time (s)');
    xlim([101 4800])
    %ylim([0 maxy+5])
    set(gca,'XTick',[1000:1000:5000],'XTickLabel',{'0','1','2','3'})
    ylabel('Firing Rate (spk/s)'); 
end