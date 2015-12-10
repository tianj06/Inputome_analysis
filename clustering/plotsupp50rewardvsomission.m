rocBin = 100;
binNum = 50;
rocPSTH50vs50 = [];
for i = 1:length(fl)
    load(fl{i},'analyzedData')
    %analyzedData = getPSTHSingleUnit(fl{i}); 
    %save(fl{i},'-append','analyzedData');
    r = analyzedData.raster;
    r1 = r{2};
    r2 = r{6};
    for k = 1:binNum
        s = sum(r1(:,rocBin*(k-1)+1:rocBin*k),2);
        b = sum(r2(:,rocBin*(k-1)+1:rocBin*k),2);
        rocPSTH50vs50(i,k) = auROC(s,b);
    end
end

%%
plotAreas = fliplr(plotAreas);
h1=figure;
diversityIdx = [];
total_var = [];
all_plot_idx = {};
for i = 1:length(plotAreas)
    neuronIdx = strcmp(brainArea,plotAreas{i});
    rocValues = squeeze(rocPSTH(neuronIdx,2,:));
    [~,plt_idx] = sort(mean(rocValues(:,11:30),2),'ascend');
    figure(h1)
    subplot(3,length(plotAreas),i)
    imagesc(rocValues(plt_idx,:),[0 1])
    colormap yellowblue
    set(gca,'XTick',[10.5:10:50],'XTickLabel',{'0','1','2','3'},...
        'TickDir','out','TickLength',[0.02 0.025],'Box','off')
        title(plotAreas{i});
    set(gca,'ytick',[])

    rocValues = squeeze(rocPSTH(neuronIdx,6,:));
    subplot(3,length(plotAreas),i+length(plotAreas))
    imagesc(rocValues(plt_idx,:),[0 1])
    colormap yellowblue
    set(gca,'XTick',[10.5:10:50],'XTickLabel',{'0','1','2','3'},...
        'TickDir','out','TickLength',[0.02 0.025],'Box','off')
    xlim([0.5 50.5])
    title(plotAreas{i});
    set(gca,'ytick',[])
    
    rocValues = squeeze(rocPSTH50vs50(neuronIdx,:));
    subplot(3,length(plotAreas),i+2*length(plotAreas))
    imagesc(rocValues(plt_idx,:),[0 1])
    colormap yellowblue
    set(gca,'XTick',[10.5:10:50],'XTickLabel',{'0','1','2','3'},...
        'TickDir','out','TickLength',[0.02 0.025],'Box','off')
    xlim([0.5 50.5])
    title(plotAreas{i});
    set(gca,'ytick',[])
end