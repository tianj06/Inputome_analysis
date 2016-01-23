%% load data
fl = what(pwd);
fl = fl.mat;
% light identification
formattedpath = 'C:\Users\uchidalab\Dropbox (Uchida Lab)\lab\Ryan thesis\PPTgAllunits';
lowsalt = 0.01;
highsalt = 0.01;
plotflag = 1;
[lightfiles, lightlatency,lightjitter]= ...
    SelectLightResponsiveUnits('PPTg',formattedpath,lowsalt, highsalt,0);

finalLight = lightfiles(lightlatency<6);
lightLabel = ismember(fl,finalLight);
longlightLabel = ismember(fl,lightfiles);
% AAV vs Rabies label
for i = 1:length(fl)
    animals{i} = extractAnimalFolderFromFormatted(fl{i});
end
% %% remove cyrus
% cyrusLabel = ismember(animals,{'Cyrus'});
% animals = animals(~cyrusLabel);
% lightLabel = lightLabel(~cyrusLabel);
% fl = fl(~cyrusLabel);

AAVlabel = ismember(animals,{'ATG','Bruno','Cyrus'});
AAVlight = lightLabel&AAVlabel';
rabieslight = lightLabel&(~AAVlabel');
AAVlightL = longlightLabel&AAVlabel';
rabieslightL = longlightLabel&(~AAVlabel');
% load response
filelist = fl;
smoothPSTH = zeros(length(filelist),10,5001);
rocPSTH = zeros(length(filelist),10,50);
lickPSTH = zeros(length(filelist),10,5001);
rawPSTH = zeros(length(filelist),10,5001);

for i = 1:length(filelist)
    load([formattedpath '\' filelist{i}], 'analyzedData')
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
bl_factor = [2.5];
linkageMethod = {'average','centroid','complete','median','single'};
disMetrics = {'euclidean', 'cosine'};
clusterNum = [7];
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
                [tb(1,:,:),~,p(1)] = crosstab(AAVlight,clustLabel);
                [tb(2,:,:),~,p(2)] = crosstab(rabieslight,clustLabel);
                titleTxt = {'vGlut2','rabies'};
                figure;
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
                end
                suptitle(sprintf('bl:%0.1f link:%s dis:%s',bl_factor(n1),linkageMethod{n2},disMetrics{n3}))
                
                figure;
                for i = 1:2
                    subplot(2,1,i)
                    temp = squeeze(tb(i,:,:));
                    total = sum(temp(2,:));
                    ratio = temp(2,:)/total;
                    x = 1:nclusters;
                    bar(ratio)
                    for i1=1:numel(ratio)
                        text(x(i1),ratio(i1),sprintf('%d',temp(2,i1)),...
                                   'HorizontalAlignment','center',...
                                   'VerticalAlignment','bottom')
                    end
                    if i == 2
                        xlabel('Cluster ID')
                    else
                        set(gca,'xticklabel',{})
                    end
                    title(sprintf('%s p= %0.3f',titleTxt{i},p(i)))
                end
                suptitle(sprintf('bl:%0.1f link:%s dis:%s',bl_factor(n1),linkageMethod{n2},disMetrics{n3}))
                thres = 120;
                f = [];
                temp = crosstab(Rcslatency<thres&AAVlight&RCSvalue==1,clustLabel);
                f(1,:) = temp(2,:);
                temp = crosstab(Rcslatency<thres&rabieslight&RCSvalue==1,clustLabel);
                f(2,:) = temp(2,:);
                figure;bar(f');xlabel('Cluster ID');legend('vGlut2','rabies');ylabel('#Neurons')
                title('Fast latency neuron')
                plotdata = crosstab(Rcslatency<thres&RCSvalue==1,clustLabel);
                figure;
                bar(plotdata(2,:)./sum(plotdata))
                xlabel('Cluster ID')
                title('Fast latency neuron CS value')
                ylabel('Prob.')
                
                figure;
                bar(plotdata(2,:))
                xlabel('Cluster ID')
                title('Fast latency neuron CS value')
                ylabel('#Neurons')
                %plot the cluster info
                %plotclusteringPPTg
            end
        end
    end
end




