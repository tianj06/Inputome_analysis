%%
homePath = 'C:\Users\uchidalab\';
lightPath = [homePath 'Dropbox (Uchida Lab)\lab\FunInputome\rabies\analysis2015Fall\newLight'];
allunitPath = [homePath 'Dropbox (Uchida Lab)\lab\FunInputome\rabies\analysis2015Fall\allunits'];
AreaToAnalyze = 'LH';
load([homePath 'Dropbox (Uchida Lab)\lab\FunInputome\rabies\analysis2015Fall\allunits_CSNewWithLatency.mat'],'RCSvalue','Rcslatency')
allRCSl = Rcslatency;
allRCSvalue = RCSvalue;
%% load data
fl1 = what(lightPath);fl1 = fl1.mat;
fl2 = what(allunitPath);fl2 = fl2.mat;
rabiesLight = ismember(fl2,fl1);
for i = 1:length(fl2)
    load(fl2{i},'area')
    brainArea{i} = area;
    clear area
end
%%
ind = strcmp(brainArea,AreaToAnalyze);
fl = fl2(ind);

rabieslight = rabiesLight(ind);
rabieslightL = rabieslight;

Rcslatency = allRCSl(ind);
RCSvalue = allRCSvalue(ind);

% load response
filelist = fl;
smoothPSTH = zeros(length(filelist),10,5001);
rocPSTH = zeros(length(filelist),10,50);
lickPSTH = zeros(length(filelist),10,5001);
rawPSTH = zeros(length(filelist),10,5001);

for i = 1:length(fl)
    load([allunitPath '\' filelist{i}], 'analyzedData')
    if rabieslightL(i)
        load([allunitPath '\' filelist{i}], 'lightResult')
        if lightResult.latency > 6
            rabieslight(i) = 0;
        end
    end
    analyzedData = remove_too_few_trials(analyzedData,5);
    smoothPSTH(i,:,:) = analyzedData.smoothPSTH(1:10,:);
    rocPSTH(i,:,:) = analyzedData.rocPSTH(1:10,:);
    lickPSTH(i,:,:) = analyzedData.rawLick(1:10,:);
    rawPSTH(i,:,:) = analyzedData.rawPSTH(1:10,:);
    %
end

%%
PCflag = 1; PCnum = 3; N = length(fl);
neuronResponse = mean(rocPSTH(:,1,11:30),3);
proc = permute (rocPSTH(:,[1 2 4 7],10:40), [1,3,2]);
dataToCluster = squeeze(reshape(proc,N,1,[]));

if PCflag 
    [eigvect,proj,eigval] = princomp(dataToCluster);
    dataToCluster = proj(:,1:PCnum);
end

bl = squeeze(mean(rawPSTH(:,:,1:1000),3));
bl = mean(bl(:,[1,7]),2);

bl = bl/max(bl);
bl_factor = [0]; %0
linkageMethod = {'average','centroid','complete','median','single'};
disMetrics = {'euclidean', 'cosine'};
clusterNum = [5 6 7]; %5
plotFlag = [0 0];
for n0 = 1:length(clusterNum)
    nclusters = clusterNum(n0);
    for n1 = 1:length(bl_factor)
        for n2 = 3%1:length(linkageMethod)
            for n3 = 1%1:length(disMetrics) %Euclidean distance
                dataToCluster = [bl*bl_factor(n1) proj(:,1:PCnum)];
                clustLabel = clusterdata(dataToCluster,'maxclust',nclusters,'linkage',linkageMethod{n2},...
                    'distance',disMetrics{n3});
                minD = inf;
                for i = 1:100
                    seeds = kmeansinit(dataToCluster,nclusters);
                    [ind, ~, sumD] = kmeans(dataToCluster,nclusters, 'Start',seeds);
                    if sum(sumD)<minD
                        clustLabel = ind;
                        minD = sum(sumD);
                    end
                end
                p = [];
                tb = [];
                [clustLabel,plotorder] = reorder_clustLabel(clustLabel,neuronResponse);
                [tb(1,:,:),~,p(1)] = crosstab(rabieslight,clustLabel);
                [tb(2,:,:),~,p(2)] = crosstab(rabieslightL,clustLabel);
                titleTxt = {'short','all'};
                figure('position',[560   624   414   324]);
                for i = 1:2
                    subplot(2,1,i)
                    temp = squeeze(tb(i,:,:));
                    total = sum(temp);
                    ratio = temp(2,:)./total;
                    x = 1:nclusters;
                    bar(ratio)
                    for i1=1:numel(ratio)
                        text(x(i1),ratio(i1),sprintf('%d/%d',temp(2,i1),total(i1)),...
                                   'HorizontalAlignment','center',...
                                   'VerticalAlignment','bottom')
                    end
                    if i == 2
                        xlabel('Cluster ID')
                    else
                        set(gca,'xticklabel',{})
                    end
                    title(sprintf('%s p= %0.3f',titleTxt{i},p(i)))
                    ylabel('%Cluster')
                end
                suptitle(sprintf('bl:%0.1f link:%s dis:%s',bl_factor(n1),linkageMethod{n2},disMetrics{n3}))
                
              if plotFlag(1)
                figure('position',[560   624   414   324]);
                for i = 1:2
                    subplot(2,1,i)
                    temp = squeeze(tb(i,:,:));
                    total = sum(temp(2,:));
                    ratio = temp(2,:)/total;
                    totalN = sum(temp);
                    x = 1:nclusters;
                    bar(ratio)
                    for i1=1:numel(ratio)
                        text(x(i1),ratio(i1),sprintf('%d/%d',temp(2,i1),totalN(i1)),...
                                   'HorizontalAlignment','center',...
                                   'VerticalAlignment','bottom')
                    end
                    if i == 2
                        xlabel('Cluster ID')
                    else
                        set(gca,'xticklabel',{})
                    end
                    title(titleTxt{i})
                    ylabel('%Identified')
                end
               suptitle(sprintf('bl:%0.1f link:%s dis:%s',bl_factor(n1),linkageMethod{n2},disMetrics{n3}))
               
                thres = 120;
                f = [];
                temp = crosstab(Rcslatency<thres&rabieslight&RCSvalue==1,clustLabel);
                f(1,:) = temp(2,:);
                temp = crosstab(Rcslatency<thres&rabieslightL&RCSvalue==1,clustLabel);
                f(2,:) = temp(2,:);
                figure('position',[627 541 907 250]);subplot(1,3,1);bar(f');xlabel('Cluster ID');legend('short','all');ylabel('#Neurons')
                title('Light identified')
                plotdata = crosstab(Rcslatency<thres&RCSvalue==1,clustLabel);
                subplot(1,3,2);bar(plotdata(2,:)./sum(plotdata))
                xlabel('Cluster ID')
                title('All by cluster')
                ylabel('Prob.')
                
                subplot(1,3,3);bar(plotdata(2,:))
                xlabel('Cluster ID')
                ylabel('#Neurons')
                title('All by cluster')
                suptitle('Fast latency CS value neuron')
              end
              if plotFlag(2)
                plotclusteringPPTg
              end
            end
        end
    end
end




