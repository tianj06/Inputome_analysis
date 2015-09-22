function plot_clusters(clustLabel,rocValues,psthValue,lickValue,brainArea)
nclusters = max(clustLabel);
clustlines = nan(3,nclusters-1);
for i = 1:nclusters-1
    temp = sum(clustLabel<=i) + 0.5;
    clustlines(1:2,i) = [temp;temp];
end
clustlines = clustlines(:); %now verticalize

figure('Position',[-14 -3 1000 787]);
p = panel();
p.pack('v',[0.6 0.2 0.2])
p(1).pack('h',5)
p(2).pack('h',nclusters)
p(3).pack('h',nclusters)

titleText = {'90% reward','50% reward','no reward','Airpuff','free Reward'};
for j = 1:5
    p(1,j).select()
    hold on;
    imagesc(squeeze(rocValues(j,:,:)),[0 1]);
    colormap yellowblue
    axis(gca,'tight','ij');
    xlines = cat(1,repmat(xlim',[1,nclusters-1]), nan(1,nclusters-1));
    xlines = xlines(:);
    plot(xlines,clustlines,'r');
    set(gca,'XTick',[10.5:10:50],'XTickLabel',{'0','1','2','3'})
    ylabel('Neuron'); xlabel('Time (s)');
    if j ==1
        title([brainArea ' ' titleText{j}]);
    else
        title(titleText{j});
    end
end
colorset= [  0 	0 	255;%blue  
             30 	144 	255;%light blue  
             128 	128 128;
             255 0 0
             0 0 0]/255; % grey

for j = 1:nclusters
    p(2,j).select()
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
    ylabel('Lick Rate (spk/s)'); 
end
