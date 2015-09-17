function plotRSS_clusterNum(dataToCluster)
for i = 1:10
    nclusters =i;
    minD = inf;
    for k = 1:50
        seeds = kmeansinit(dataToCluster,nclusters);
        [ind, ~, sumD] = kmeans(dataToCluster,nclusters, 'Start',seeds);
        if sum(sumD)<minD
            clustLabel = ind;
            minD = sum(sumD);
        end
    end
    % calculate RSS
    RSS(i) = 0;
    for j = 1:i
        clustIdx = find(clustLabel == j);
        r = dataToCluster(clustIdx,:) - ...
            repmat(mean(dataToCluster(clustIdx,:)),length(clustIdx),1);
        RSS(i) = RSS(i) + sum(sum(r.*r));
    end
end
r = dataToCluster - repmat(mean(dataToCluster),size(dataToCluster,1),1);
totalRSS = sum(sum(r.*r));
figure;plot(1:10,1-RSS/totalRSS)
xlabel('Number of clusters')
ylabel('1-RSS or variance explained')
ylim([0 1])