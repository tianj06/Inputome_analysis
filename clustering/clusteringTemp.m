PCflag = 1; PCnum = 3;
neuronResponse = mean(rocPSTH(:,1,11:30),3);
proc = permute (rocPSTH(:,[1 2 7],10:40), [1,3,2]);
dataToCluster = squeeze(reshape(proc,N,1,[]));

if PCflag 
    [eigvect,proj,eigval] = princomp(dataToCluster);
    dataToCluster = proj(:,1:PCnum);
end

bl = squeeze(mean(rawPSTH(:,:,1:1000),3));
bl = mean(bl(:,[1,7]),2);
bl = bl/max(bl);
bl_factor = 3;
dataToCluster = [bl*bl_factor proj(:,1:PCnum)];
%%
linkageMethod = {'average','centroid'};
disMetrics = {'euclidean', 'cosine'};
nclusters = 4;

i = 2;
j = 1;
clustLabel = clusterdata(dataToCluster,'maxclust',nclusters,'linkage',linkageMethod{i},...
    'distance',disMetrics{j});
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

[clustLabel,plotorder] = reorder_clustLabel(clustLabel,neuronResponse);
temp1

