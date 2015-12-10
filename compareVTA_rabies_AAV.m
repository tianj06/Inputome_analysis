homepath = 'C:\Users\uchidalab\Dropbox (Uchida Lab)\lab\FunInputome\rabies\rabies_VTA\';
fl_rabies = [homepath 'analysis\vta_light_high.mat'];
load(fl_rabies)
rocPSTH_r = [];
rawPSTH_r = [];

strangeFile = {'Woodchuck_2012-05-15_15-33-10_TT4_3_formatted.mat',
     'Xenopus_2012-05-21_13-35-50_TT2_3_formatted.mat',
     'Fettuccine_2014-11-12_00-00-00_TT2_01_formatted.mat',
     'Fireweed_2014-07-20_13-30-41_TT6_01_formatted.mat'};
ind = find(ismember(lightfiles,strangeFile));
lightfiles(ind) = [];
for i = 1:length(lightfiles)
    %analyzedData = getPSTHSingleUnit(lightfiles{i}); 
    %save(lightfiles{i},'-append','analyzedData');
    load([homepath 'formatted\' lightfiles{i}],'analyzedData');
    analyzedData = remove_too_few_trials(analyzedData,5);
    rawPSTH_r(i,:,:) = analyzedData.rawPSTH;
    rocPSTH_r(i,:,:) = analyzedData.rocPSTH;
end

for i = 1:length(lightfiles)
    load([homepath 'formatted\' lightfiles{i}],'rabiesDate');
    rabies_dates(i) = rabiesDate;
    clear rabiesDate
end
fl_aav = what([homepath 'controlVTA\']);
fl_aav = fl_aav.mat;
raster_a = cell(length(fl_aav),14);
for i = 1:length(fl_aav)
    %analyzedData = getPSTHSingleUnit(fl_aav{i}); 
    %save(fl_aav{i},'-append','analyzedData');
    load([homepath 'controlVTA\' fl_aav{i}],'analyzedData');
    analyzedData = remove_too_few_trials(analyzedData,5);
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
    set(gca,'XTick',[10.5:10:50],'XTickLabel',{'0','1','2','3'},'TickDir','out',...
        'TickLength',[0.02 0.025])
    ylabel('Neuron'); xlabel('Time (s)');
    title(titleText{j});
end
%% save type1 neurons
Nr = length(lightfiles);
rabies_label = 1:size(dataToCluster,1)<= Nr; % first Nr neurons are rabies
b = squeeze(mean(mean(psthAll(:,11:14,1:1000),3),2));
rabies_type1 = lightfiles(clustLabel==1&rabies_label'&b<15);
save('rabiesType1','rabies_type1')
AAV_type1 = fl_aav(allType1(Nr+1:end));
%save('aavType1','AAV_type1')
rabies_clustLabel = clustLabel(1:Nr);
aav_clustLabel = clustLabel(Nr+1:end);

%% compute significant response 

sigpair = {[11 13],[1,2],[5 7]};
windowpair = {[1000 1500],[3000 3500],[3000 4000]};
for i = 1:length(lightfiles)
    load([homepath 'formatted\' lightfiles{i}],'analyzedData')
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
            [~,sigresult(i+length(lightfiles),j)] = ranksum(responses{1},responses{2}); 
        else
            sigresult(i+length(lightfiles),j) = 0;
        end
    end
end
% calculate baseline
b = squeeze(mean(mean(psthAll(:,11:14,1:1000),3),2));
b1 = b;
%% scatter plot for all pairs of events
rdate = [rabies_dates';nan(length(fl_aav),1)];
labels = {'90% cue', '0% cue'; '90%W','50%W';'OM 90%W','OM 0%W'};
figure;
clusterID = 1;
resp_spikes = cell(3,2);
nNeuron = [];
for k = 1:2
    if k==1
        neuronIdx = rabies_label'&(clustLabel==clusterID)&b<15&rdate>=9;
        %neuronIdx = rabies_label'&(clustLabel==clusterID)&rdate<=11;
    else
        neuronIdx = (~rabies_label')&(clustLabel==clusterID)&b<15;
        %neuronIdx = rabies_label'&(clustLabel==clusterID)&rdate>11;
    end
    nNeuron(k) = sum(neuronIdx);
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
%%
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
    set(gca,'xtick',[1,2],'xticklabels',{'rabies late','rabies AAV'}); %{'rabies','AAV'}
    sigstar({[1,2]},p_box(i))
    prettyP('','','','','a')
end
% make bar plot to show no quanlitative difference between rabies and vta

% compute errorbar on rabies

%%
figure;
for i = 1:3
    subplot(1,3,i)
    errorSig(i,:) = 100*sqrt(percentSig(i,:).*(1-percentSig(i,:))./nNeuron); 
    s = percentSig(i,1)*nNeuron(1);
    n = nNeuron(1);
    p = myBinomTest(s,n,percentSig(i,2),'Two')
    bar([1,2],100*percentSig(i,:))
    hold on;
    errorbar([1,2],100*percentSig(i,:),errorSig(i,:),'k.')
    ylabel([labels(i,1) '-' labels(i,2)])
    set(gca,'xtick',[1,2],'xticklabels',{'rabies late','AAV'});  %{'rabies early','rabies late'}
    prettyP('',[0 100],'',[0 50 100],'a')
end
suptitle('Percent significant')

for i = 1:3
    prabies(i) = signrank(resp_spikes{i,1});
    paav(i) = signrank(resp_spikes{i,2});
end
%%
figure;
b1 = b(rabies_label&(clustLabel'==1)&b'<10);
b2 = b(~rabies_label&(clustLabel'==1)&b'<10);
boxplot([b1;b2],[ones(length(b1),1); 2*ones(length(b2),1)])
set(gca,'xtick',[1,2],'xticklabel',{'rabies','AAV'})
title('Baseline')
ylabel('Spikes/s')
%xlim([0.5 2.5])
sigstar({[1,2]},ranksum(b1,b2))
prettyP('',[0 13],'','','a')
%% plot cue response vs baseline
cue = squeeze(mean(psthAll(:,11,1000+[0:500]),3)) -b;
figure;
scatter(b1,cue(rabies_label&(clustLabel'==1)))
hold on;
scatter(b2,cue(~rabies_label&(clustLabel'==1)),'r')

%% plot psth rabies type1 vs AAV type1 
colorset= [  0 	0 	255;%blue  
             30 	144 	255;%light blue  
             127 127 127;
             0 0 0]/255; % grey
maxy = 0;
clusterID = 1;
figure;
ExpText = {'rabies early 6-9 days','rabies late 10-15 days','AAV'};
daythres = 9;
trialTypes = [1 2 7 9];
for i = 1:3
    subplot(3,1,i)
    if i==1
        neuronIdx = rabies_label'&(clustLabel==clusterID)&b<10&rdate<=daythres;
    elseif i==2
        neuronIdx = rabies_label'&(clustLabel==clusterID)&b<10&rdate>daythres;
    else
        neuronIdx = (~rabies_label')&(clustLabel==clusterID)&b<10;
    end
    for k = 1:4
        a = squeeze(psthAll(neuronIdx,trialTypes(k),:));
        %a = a(find(idx==1),:); % remove empty trials
        if min(size(a))>1
            averagePSTH = nanmean(a);
        else
            averagePSTH = a;
        end
        plot(smooth(averagePSTH(500:4500),100),'Color',colorset(k,:),'LineWidth',1);hold on
        if maxy < max(smooth(averagePSTH,100))
            maxy = max(smooth(averagePSTH,100));
        end
    end
    
    title(sprintf('%s Cluster %d n=%d ',ExpText{i},clusterID,size(a,1)));
    xlabel('Time (s)');
    xlim([101 3800])
    %ylim([0 maxy+5])
    set(gca,'XTick',[500:1000:3500],'XTickLabel',{'0','1','2','3'})
    ylabel('Firing Rate (spk/s)'); 
    prettyP('','','','','a')
end

savePath = 'C:\Users\uchidalab\Dropbox (Uchida Lab)\lab\FunInputome\rabies\analysis2015Fall\';
ind = rabies_label'&(clustLabel==clusterID)&b<10&rdate<=11;
%plot_pop_summary_fromAnalyzedPanel(lightfiles(ind),savePath,'vta early type1')

%% plot psth rabies type1 early days vs late
colorset= [  0 	0 	255;%blue  
             30 	144 	255;%light blue  
             0 0 0]/255; % grey
maxy = 0;
clusterID = 1;
figure;
ExpText = {'rabies early','rabies late'};
rdate = [rabies_dates';nan(length(fl_aav),1)];
for i = 1:2
    subplot(2,1,i)
    if i==1
        neuronIdx = rabies_label'&(clustLabel==clusterID)&rdate<=11;
    else
        neuronIdx = rabies_label'&(clustLabel==clusterID)&rdate>11;
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
%% plot example VTA rabies neurons
examplefiles = {'Fireweed_2014-07-25_13-26-44_TT6_02_formatted.mat',
               'Bellflower_2014-07-12_13-13-20_TT1_01_formatted.mat',
               'Mimosa_2014-09-24_10-23-38_TT8_01_formatted.mat'};
FigureSavePath = 'C:\Users\uchidalab\Dropbox (Uchida Lab)\lab\FunInputome\writing\Figures\';
for i = 1:3
    quickPSTHPlotting_formatted(examplefiles{i})
    %saveas(gcf,[FigureSavePath examplefiles{i} ])
end