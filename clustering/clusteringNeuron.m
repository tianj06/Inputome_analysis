
fileList = what(pwd);
fileList = fileList.mat;

%% calculate values for clustering
Type = 2;
a = loadValueforClustering(fileList,Type);
cValue = squeeze(a(1,:,:));
%cValue = cValue(:,[1 5 9]); % choose only big ones
%% clean up the values
% for i = 1: size(cValue,2)
%     cValue(isnan(cValue(:,i)),i) = nanmean(cValue(:,i));
%     range = max(cValue(:,i)) - min(cValue(:,i));
%     cValue(:,i) = (cValue(:,i) - mean(cValue(:,i)) )/range;
% end


%% calculate PCA value
% [eigvect,proj,eigval] = princomp(squeeze(auROCvalue(1,:,:)));
% figure;plot(eigvect(:,1:4))
% prettyP('a','a','a','a')
% title('First four eigvect vectors control')
% set(gca,'XTick',[10.5:10:50],'XTickLabel',{'0','1','2','3'})
% 
% hl = legend(['pc1=' num2str(eigval(1))],['pc2=' num2str(eigval(2))],...
%     ['pc3=' num2str(eigval(3))],['pc4=' num2str(eigval(4))]);
% set(hl,'FontSize',8,'FontName','Arial','box','off','Location','NorthEastOutside')
% xlabel('time')
% ylabel('auROC')

% figure;
% plot(cumsum(eigval)/sum(eigval))

%% do clustering of the data
% dataToCluster =  [squeeze(auROCvalue(1,:,1:50))...
%     squeeze(auROCvalue(3,:,30:40)) ];%proj(:,1:5);
dataToCluster = cValue(:,5:40);
nclusters =3;
minD = inf;
for i = 1:20
    seeds = kmeansinit(dataToCluster,nclusters);
    [ind, ~, sumD] = kmeans(dataToCluster,nclusters, 'Start',seeds);
    if sum(sumD)<minD
        clustLabel = ind;
        minD = sum(sumD);
    end
end
%%
% l=[];
% for i = 1:nclusters
%     l(i) = length(find(clustLabel==i)); % the number of members in cluster
% end
% [~,idx] = sort(l,'descend');
% for i = 1:nclusters
%     clustLabel(clustLabel==idx(i)) = nclusters+i;
% end
% clustLabel  = clustLabel-nclusters;
% [~,plotorder] = sort(clustLabel);
%%
h1 = figure;
h2 = figure;
for i = 1:nclusters
    fileIdx = find(clustLabel==i);
    [averagePSTH, norAllPSTH]= getAveragePSTH_filelist(fileList(fileIdx));
    figure(h1);
        subplot(nclusters,1,i);plot(averagePSTH')
        if i ==1
            legend('90% W','omission 90% W','omission 10%W','airpuff')
        end
    figure(h2);
    for j = 1:4
        subplot(nclusters,4,4*(i-1)+j);
        imagesc(squeeze(norAllPSTH(:,j,:)),[0 1]);
        colormap yellowblue
    end
end

