fl = what(pwd);
fl = fl.mat;
binSize = 20;
nBin = 5000/binSize;
rawpsthAll = zeros(length(fl),nBin*10);

for i = 1:length(fl)
    load(fl{i},'analyzedData','area')
    p = analyzedData.rawPSTH(1:10,:);
    newp = squeeze(mean(reshape(p(:,1:5000),size(p,1),binSize,nBin),2));
    for j = 1:size(newp,1)
        newp(j,:) = smooth(newp(j,:),3);
    end
    rawpsthAll(i,:)= reshape(newp',1,[]);
    brainArea{i} = area;
end

a = rawpsthAll(:,1:50:end);
brainArea(ismember(brainArea,{'LH_an','LH_psth','LH_po'})) = {'LH'};
brainArea(ismember(brainArea,{'PPTg_an','PPTg'})) = {'PPTg'};

%% change  the name of brain areas
oldnames = {'Striatum','LH','VS','PPTg','RMTg','VP','DA','VTA3','VTA2','STh'};
newnames = {'Dorsal striatum','Lateral hypothalamus','Ventral striatum',...
    'PPTg','RMTg','Ventral pallidum','Dopamine','VTA type3',...
    'VTA type2','Subthalamic'};
oldbrain = brainArea;
for i = 1:length(oldnames)
    idx = ismember(oldbrain,oldnames{i});
    brainArea(idx) = newnames(i);
end
save('allUnitrawPSTH20ms','brainArea','rawpsthAll')

%%
VTA_index = strcmp(brainArea,'DA')|strcmp(brainArea,'VTA2')|strcmp(brainArea,'VTA3');
psth = rawpsthAll(~VTA_index,:);
vtaPsth = mean(rawpsthAll(strcmp(brainArea,'DA'),:));
figure;
subIdx = [1:100 150:350];
for i = 1:6
    ind=floor(124/6)*i;
    plot(smooth(psth(ind,subIdx))+i*40)
    hold on;
end
axis off

figure;
plot(smooth(vtaPsth(subIdx)))


figure;
for i = 1:10:124
    figure;
    plot(smooth(psth(i,subIdx)))
    axis off
end