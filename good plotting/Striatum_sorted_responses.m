fl = what(pwd);
fl = fl.mat;
N = length(fl);
for i = 1:length(fl)
    load(fl{i},'analyzedData')
    rocPSTH(i,:,:) = analyzedData.rocPSTH(1:10,:);
end

for i = 1:length(fl)
    a = load(fl{i},'area');
    brainArea{i} = a.area;
end
% change  the name of brain areas
oldnames = {'Striatum','LH','VS','PPTg','RMTg','VP','St','DA','VTA3','VTA2','Ce'};
newnames = {'Dorsal striatum','Lateral hypothalamus','Ventral striatum',...
    'PPTg','RMTg','Ventral pallidum','Dorsal striatum','Dopamine','VTA type3',...
    'VTA type2','Central amygdala'};
oldbrain = brainArea;
for i = 1:length(oldnames)
    idx = ismember(oldbrain,oldnames{i});
    brainArea(idx) = newnames(i);
end
%%
%areaInterested = 'Ventral striatum';
dataInterested = rocPSTH(:,:,:);
[~,peakROCTime] = max(squeeze(dataInterested(:,1,:))'); %strcmp(brainArea,areaInterested)
[~,plotorder] = sort(peakROCTime);
figure;
auROCvalue = dataInterested(:,[1 2 7 4 9],:);
auROCvalue = permute(auROCvalue,[2 1 3]);
titleText = {'90% reward','50% reward','no reward','Airpuff','free Reward'};
for j = 1:5
    subplot(1,5,j)
    plotValue = squeeze(auROCvalue(j,:,:));
    hold on;
    imagesc(plotValue(plotorder,:),[0 1]);
    colormap yellowblue
    axis(gca,'tight','ij');
    set(gca,'XTick',[10.5:10:50],'XTickLabel',{'0','1','2','3'})
    ylabel('Neuron'); xlabel('Time (s)');
    title(titleText{j});
end
%%
auROCvalue = dataInterested(:,[1 2 7 4 9],:);
auROCvalue = permute(auROCvalue,[2 1 3]);
for i = 1:size(auROCvalue,1)
    for j = 1:size(auROCvalue,2)
        auROCvalue(i,j,:) = auROCvalue(i,j,:)./max(auROCvalue(i,j,:));
    end
end
figure
titleText = {'90% reward','50% reward','no reward','Airpuff','free Reward'};
for j = 1:5
    subplot(1,5,j)
    plotValue = squeeze(auROCvalue(j,:,:));
    hold on;
    imagesc(plotValue(plotorder,:));
    colormap yellowblue
    axis(gca,'tight','ij');
    set(gca,'XTick',[10.5:10:50],'XTickLabel',{'0','1','2','3'})
    ylabel('Neuron'); xlabel('Time (s)');
    title(titleText{j});
end