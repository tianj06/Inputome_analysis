%clustering from extracted data

%setup a fileList
fileList = what(pwd);
fileList = fileList.mat;
pretrigger = 1000;
posttrigger = 4000;
rocBin = 100;
binNum = (pretrigger + posttrigger)/rocBin;
auROCvalue = zeros(3,length(fileList),binNum);
psthValue = zeros(4,length(fileList),5001);
for i = 1:length(fileList)
    load(fileList{i})
    odorOn = events.odorOn;
    trialType = events.trialType;
    rewardOn = events.rewardOn;
    if exist('timeWindow','var')
        if ~isnan(timeWindow(1))
            if timeWindow(1) <0
                timeWindow(1) =1;
            end
            Idx = 1:length(events.trialType);
            effIdx = (Idx>=timeWindow(1)) & (Idx<=timeWindow(2));
            odorOn = odorOn(effIdx);
            trialType = trialType(effIdx);
        end
    end
    trigger = {odorOn(trialType==1)
        odorOn(trialType==6)
        odorOn(trialType==7)
        rewardOn(trialType==9)
        }; % 90% reward
     [~, r, psths] = plotPSTH(responses.spike, trigger, pretrigger, posttrigger, ...
          'plotflag', 'none');
     % calculate roc
     psthValue(:,i,:) = psths;
     for j = 1:4
         baseline = [];
         for n = 1:pretrigger/rocBin
             if j==4
                 temp = sum(r{1}(:,rocBin*(n-1)+1:rocBin*n),2);
             else
                 temp = sum(r{j}(:,rocBin*(n-1)+1:rocBin*n),2);
             end
            baseline = [baseline; temp];
        end

        for k = 1:binNum
            s = sum(r{j}(:,rocBin*(k-1)+1:rocBin*k),2);
            auROCvalue(j,i,k) = auROC(s,baseline);
        end
     end
     
     for k = 1:binNum
            s = sum(r{1}(:,rocBin*(k-1)+1:rocBin*k),2);
            baseline = sum(r{2}(:,rocBin*(k-1)+1:rocBin*k),2);
            auROCvalue(5,i,k) = auROC(s,baseline);
            s = sum(r{3}(:,rocBin*(k-1)+1:rocBin*k),2);
            auROCvalue(6,i,k) = auROC(s,baseline);
      end
     
end
% %% normalize psth response for clustering
% 
% for i = 1:3
%     for j = 1:30
%         temp = squeeze(psthValue(i,j,:));
%         bl = mean(temp(1:1000));
%         temp = mean(reshape(temp(1:5000),100,[]));
%         maxV = max(temp(1:29));
%         minV = min(temp(1:29));
%         norm_psth(i,j,:) = (temp-bl)/(maxV-minV);
%         if maxV==minV
%             norm_psth(i,j,:)  = zeros(1,50);
%         end
%     end
% end

%% calculate PCA value
% a = [squeeze(auROCvalue(1,:,1:50))  ...
%     squeeze(auROCvalue(3,:,30:40)) ];
% [eigvect,proj,eigval] = princomp(a);
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
% 
% figure;
% plot(cumsum(eigval)/sum(eigval))
% ylim([0 1])
%% do clustering of the data
dataToCluster = [squeeze(auROCvalue(1,:,1:30))];
%squeeze(auROCvalue(1,:,10:30));

%squeeze(auROCvalue(3,:,30:40)) ];%proj(:,1:5);
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
% l=[];
% for i = 1:nclusters
%     l(i) = length(find(clustLabel==i)); % the number of members in cluster
% end
%     
% [~,idx] = sort(l,'descend');
% for i = 1:nclusters
%     clustLabel(clustLabel==idx(i)) = nclusters+i;
% end
% clustLabel  = clustLabel-nclusters;

%
% newclustLabel = zeros(1,length(clustLabel));
% newclustLabel(ismember(clustLabel,[1 3 6])) = 1;
% newclustLabel((clustLabel==4)) = 5;
% 
% savedclustLabel = clustLabel;
% clustLabel = newclustLabel;

%
% clustLabel((clustLabel==8)) = 1;
% clustLabel((clustLabel==6)) = 2;
% clustLabel((clustLabel==7)) = 6;
% nclusters = 6;
%
[~,plotorder] = sort(clustLabel);

%%
% do some plottings
figure('Position',[-14 -3 1000 787]);

%set up a vector with y values for drawing lines separating the
%clusters
clustlines = nan(3,nclusters-1);
for i = 1:nclusters-1
    temp = sum(clustLabel<=i) + 0.5;
    clustlines(1:2,i) = [temp;temp];
end
clustlines = clustlines(:); %now verticalize

% plot postROC heatmap


for j = 1:4
    subplot(1,4,j)
    plotValue = squeeze(auROCvalue(j,:,:));
    if j ==1
        titleText = '90% reward';
    elseif j==2
        titleText = '90% no reward';
    elseif j==3   
        titleText = 'Airpuff';
    elseif j==4
        titleText = 'free Reward';
        plotValue = squeeze(auROCvalue(j,:,1:20));
    end
    hold on;
    imagesc(plotValue(plotorder,:),[0 1]);
    colormap yellowblue
    axis(gca,'tight','ij');
%     xlines = cat(1,repmat(xlim',[1,nclusters-1]), nan(1,nclusters-1));
%     xlines = xlines(:);
%     plot(xlines,clustlines,'r');
    set(gca,'XTick',[10.5:10:50],'XTickLabel',{'0','1','2','3'})
    ylabel('Neuron'); xlabel('Time (s)');
    title(titleText);
end
colorbar;
% plot average PSTH for each cluster
%
%%
colorset = [0 0 1; 0 0 0; 1 0 0];
%
figure;
for j = 1:nclusters
    subplot(1,nclusters,j)
    %figure;
%     a = squeeze(psthValue(2,find(clustLabel==j),:));
%     idx = ~isnan(a(:,1));
    maxy = 0;
    for k = 1:3
        a = squeeze(psthValue(k,find(clustLabel==j),:));
        %a = a(find(idx==1),:); % remove empty trials
        if min(size(a))>1
            averagePSTH = mean(a);
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
    xlim([50 4950])
    ylim([0 maxy+5])
    set(gca,'XTick',[1000:1000:5000],'XTickLabel',{'0','1','2','3'})
    ylabel('Firing Rate (spk/s)'); 
    prettyP('','','','','m')
end

%%