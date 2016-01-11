fl = what(pwd);
fl = fl.mat;
for i = 1:length(fl)
    a = load(fl{i},'area');
    brainArea{i} = a.area;
end

brainArea(ismember(brainArea,{'LH_an','LH_psth','LH_po'})) = {'LH'};
brainArea(ismember(brainArea,{'PPTg_an','PPTg'})) = {'PPTg'};

% change  the name of brain areas
oldnames = {'Striatum','LH','VS','PPTg','RMTg','VP','DA','VTA3','VTA2','STh'};
newnames = {'Dorsal striatum','Lateral hypothalamus','Ventral striatum',...
    'PPTg','RMTg','Ventral pallidum','Dopamine','VTA type3',...
    'VTA type2','Subthalamic'};
oldbrain = brainArea;
for i = 1:length(oldnames)
    idx = ismember(oldbrain,oldnames{i});
    brainArea(idx) = newnames(i);
end
%%
plotrange = 100;
allpsthSM = [];
for i = 1:length(fl)
    idx = strfind(fl{i},'_');
    fileName = fl{i}(1:idx(5)-1);
    animalName = fileName(1:idx(1)-1);
    load(fl{i},'responses','events')
    plotLaser = events.freeLaserOn(diff(events.freeLaserOn)>=plotrange);
    [~,~,psth] = plotPSTH(responses.spike, plotLaser, 20, ...
        plotrange, 'plotflag', 'none','smooth','n');
    allpsthSM(i,:) = smooth(psth,3);
end
%%
for i = 1:length(newnames)
    ind = strcmp(brainArea,newnames{i});
    figure;
    title(newnames{i})
    imagesc(allpsthSM(ind,:),[0 150])
end