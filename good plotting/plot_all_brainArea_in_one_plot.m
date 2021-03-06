%% save light identified units
brainAreas = {'Ce', 'LH','VS','PPTg','Striatum','VP','RMTg'};
lowsalt =  [0.01, 0.01,0.01,0.01,0.01,0.01,0.01];
highsalt = [0.01, 0.01,1, 0.01, 1,0.01,1];
allLightFiles = cell(1,4);%table('VariableNames',{'FileName' 'Area' 'Latency' 'Jitter'});
savePath = 'C:\Users\uchidalab\Dropbox (Uchida Lab)\lab\FunInputome\rabies\analysis2015Fall\';
k = 1;
for i = 1:length(brainAreas)
    brainArea = brainAreas{i};
    formattedpath = ['C:\Users\uchidalab\Dropbox (Uchida Lab)\lab\FunInputome\rabies\rabies_' brainArea '\uniqueUnits\'];
    cd(formattedpath)
    %addAreaInformation(formattedpath,brainArea);
    [lightfiles, lightlatency,lightjitter] = SelectLightResponsiveUnits(brainArea,formattedpath, lowsalt(i), highsalt(i),0);
    idx = k:k+length(lightfiles)-1;
    allLightFiles(idx,1) = lightfiles;
    allLightFiles(idx,2) = {brainArea};
    allLightFiles(idx,3) = num2cell(lightlatency');
    allLightFiles(idx,4) = num2cell(lightjitter');
    k = idx(end)+1;
end

allLightFiles = cell2table(allLightFiles, 'VariableNames',{'FileName' 'Area' 'Latency' 'Jitter'});
save([savePath 'allLightFiles.mat'],'allLightFiles');
%% analyze light identified units
% light identified neurons' response
[rocPSTH,lickPSTH,rawPSTH] = load_light_response_units(allLightFiles);
% do pca analysis
N = height(allLightFiles);
proc = permute (rocPSTH(:,[1 2 7],10:40), [1,3,2]);
dataToCluster = squeeze(reshape(proc,N,1,[]));
[eigvect,proj,eigval] = princomp(dataToCluster);
figure;
colors = color_select(7);
gscatter(proj(:,1),proj(:,2),allLightFiles.Area,colors);
save([savePath 'all_light_proj.mat'],'proj');


% do clustering analysis based on psth

%% analyze all units
[rocPSTH,lickPSTH,rawPSTH,fl,arealist] = load_all_rabies_units(brainAreas);
save([savePath 'allunits.mat'],'rocPSTH','lickPSTH','rawPSTH','fl','areaList');

N = length(fl);
proc = permute (rocPSTH(:,[1 2 7],10:40), [1,3,2]);
dataToCluster = squeeze(reshape(proc,N,1,[]));
plotRSS_clusterNum(dataToCluster)
[eigvect,proj,eigval] = princomp(dataToCluster);

%%
nclusters =5;
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
%%
figure('Position',[-14 -3 1000 787]);
p = panel();
p.pack('h',5)


auROCvalue = rocPSTH(:,[1 2 7 4 9],:);
auROCvalue = permute(auROCvalue,[2 1 3]);
titleText = {'90% reward','50% reward','no reward','Airpuff','free Reward'};
for j = 1:5
    p(j).select()
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
%% show each area 
clustering_sum = table(clustLabel,'VariableNames',{'Label'});
clustering_sum.Area = areaList';
clustering_sum.proj1 = proj(:,1);
clustering_sum.proj2 = proj(:,2);
clustering_sum.proj3 = proj(:,3);
clustering_sum.light = ismember(allfl',allLightFiles.FileName);
writetable(clustering_sum,[savePath 'clustering_all.txt'],'Delimiter',' ')