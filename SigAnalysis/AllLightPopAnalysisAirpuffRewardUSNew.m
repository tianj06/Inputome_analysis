fl = what(pwd);
fl = fl.mat;
for i = 1:length(fl)
    a = load(fl{i},'area');
    brainArea{i} = a.area;
end
%% remove VTA rabies units
VTAind = ismember(brainArea,{'rVTA Type2','r VTA Type3','rdopamine'});
fl = fl(~VTAind);
N = length(fl);
clear brainArea
%%
TimeWin = 1:500;
freePuff = zeros(N,1);
freeWater = zeros(N,1);
WaterVsBefore = zeros(N,1);
PuffVsBefore = zeros(N,1);
WaterVsNothing = zeros(N,1);
PuffVsNothing = zeros(N,1);
direRUS = zeros(N,1);
direAUS = zeros(N,1);
for i = 1:length(fl)
    a = load(fl{i},'area');
    brainArea{i} = a.area;
    load(fl{i}, 'analyzedData')
    if ~exist('analyzedData', 'var')
        analyzedData = getPSTHSingleUnit(fl{i}); 
        save(fl{i},'-append','analyzedData')
    end
    % comopute airpuff response
    rs = analyzedData.raster;
    urs = rs([1 4 9 10]); 
    % free airpuff vs free reward
    US_spikes = cellfun( @(x)1000*mean(x(:,TimeWin+3000),2)-1000*mean(x(:,TimeWin+2500),2),urs,'UniformOutput',0);
    if length(US_spikes{4}) >= 5
        [~,freePuff(i)] = signrank(US_spikes{4});
        dirFreePuff(i) = mean(US_spikes{4})>0;
    else
        freePuff(i) = nan;
        dirFreePuff(i) = nan;
    end
    if length(US_spikes{3}) >= 5
        [~,freeWater(i)] = signrank(US_spikes{3});
        dirFreeWater(i) = mean(US_spikes{3})>0;
    else
        freeWater(i) = nan;
        dirFreeWater(i) = nan;
    end
    
    % compare airpuff vs before airpuff, water vs before water
    [~,WaterVsBefore(i)] = signrank(US_spikes{1});
    [~,PuffVsBefore(i)] = signrank(US_spikes{2});
    % compare airpuff vs nothing, water vs nothing
    urs = rs([1 7 4]); 
    US_spikes = cellfun( @(x)1000*mean(x(:,TimeWin+3000),2),urs,'UniformOutput',0);
    [~,WaterVsNothing(i)] = ranksum(US_spikes{1},US_spikes{2});
    [~,PuffVsNothing(i)] = ranksum(US_spikes{3},US_spikes{2});
    direRUS(i) = mean(US_spikes{1}) > mean(US_spikes{2});
    direAUS(i) = mean(US_spikes{3}) > mean(US_spikes{2}); 
end
%%
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
[G,areaName]=grp2idx(brainArea);

% ind = ismember(brainArea,{'Dopamine','VTA type3',...
%     'VTA type2'});
% brainArea(ind) = {'VTA'};
%%
sigReward = WaterVsBefore&WaterVsNothing;
sigPuff = PuffVsBefore&PuffVsNothing;

tempIdx = [];
tempIdx(:,1) = sigReward&sigPuff&(direAUS==direRUS); %RewadPuffSame
tempIdx(:,2) = sigReward&sigPuff&(direAUS~=direRUS); % RewardPuffOppo
tempIdx(:,3) = sigReward&(~sigPuff); %rewardOnly
tempIdx(:,4) = (~sigReward)&sigPuff; %puffOnly
figure;
titleText = {'Saliency','Value','RewardOnly','PuffOnly'};

[G,areaName]=grp2idx(brainArea);
for i = 1:4
    subplot(2,2,i)
    barh(grpstats(tempIdx(:,i),G')); set(gca,'ytickLabel',areaName);xlim([0 1])
    title(titleText{i})
end

figure;
res = [];
for i = 1:length(areaName)
    subplot(3,4,i)
    res(:,1,1) = tempIdx(:,1)&direRUS==1;
    res(:,1,2) = tempIdx(:,1)&direRUS==0;
    res(:,2,1) = tempIdx(:,2)&direRUS==1;
    res(:,2,2) = tempIdx(:,2)&direRUS==0;
    res(:,3,1) = tempIdx(:,3)&direRUS==1;
    res(:,3,2) = tempIdx(:,3)&direRUS==0;
    res(:,4,1) = tempIdx(:,4)&direAUS==1;
    res(:,4,2) = tempIdx(:,4)&direAUS==0;
    bar(squeeze(mean(res(G==i,:,:))),'stacked');
    legend('pos','neg')
    title(areaName{i});ylim([0 1]);xlim([0 5])
    set(gca,'xtickLabel',titleText)
end

tempIdx = [];
tempIdx(:,1) = sigReward&(direRUS==1); % reward pos
tempIdx(:,2) = sigReward&(direRUS==0); % reward neg
tempIdx(:,3) = sigPuff&(direAUS==1); % airpuff pos
tempIdx(:,4) = sigPuff&(direAUS==0); % airpuff neg
figure;
titleText = {'reward pos','reward neg','airpuff pos','airpuff neg'};

[G,areaName]=grp2idx(brainArea);
for i = 1:4
    subplot(2,2,i)
    barh(grpstats(tempIdx(:,i),G')); set(gca,'ytickLabel',areaName);xlim([0 1])
    title(titleText{i})
end
%%
puffNans = find(isnan(freePuff));
waterNans = find(isnan (freeWater));
notNans = find((~isnan(freePuff))&(~isnan(freeWater)));
sigReward = freeWater(notNans);
sigPuff = freePuff(notNans);
dirFreePuff = dirFreePuff(notNans);
dirFreeWater = dirFreeWater(notNans);

names = unique(brainArea); 
remainCounts = cell(length(names),3);
for i = 1:length(names)
    n1 = sum(strcmp(brainArea,names{i}));
    n2 = sum(strcmp(brainArea(notNans),names{i}));
    remainCounts{i,1} = names{i};
    remainCounts{i,2} = n1;
    remainCounts{i,3} = n2;
end

%%
tempIdx = [];
tempIdx(:,1) = sigReward&sigPuff&(dirFreePuff==dirFreeWater); %RewadPuffSame
tempIdx(:,2) = sigReward&sigPuff&(dirFreePuff~=dirFreeWater); % RewardPuffOppo
tempIdx(:,3) = sigReward&(~sigPuff); %rewardOnly
tempIdx(:,4) = (~sigReward)&sigPuff; %puffOnly
figure;
titleText = {'Saliency','Value','RewardOnly','PuffOnly'};

[G,areaName]=grp2idx(brainArea(notNans));
for i = 1:4
    subplot(2,2,i)
    barh(grpstats(tempIdx(:,i),G')); set(gca,'ytickLabel',areaName);xlim([0 1])
    title(titleText{i})
end

figure;
res = [];
for i = 1:length(areaName)
    subplot(3,4,i)
    res(:,1,1) = tempIdx(:,1)&dirFreeWater==1;
    res(:,1,2) = tempIdx(:,1)&dirFreeWater==0;
    res(:,2,1) = tempIdx(:,2)&dirFreeWater==1;
    res(:,2,2) = tempIdx(:,2)&dirFreeWater==0;
    res(:,3,1) = tempIdx(:,3)&dirFreeWater==1;
    res(:,3,2) = tempIdx(:,3)&dirFreeWater==0;
    res(:,4,1) = tempIdx(:,4)&dirFreePuff==1;
    res(:,4,2) = tempIdx(:,4)&dirFreePuff==0;
    bar(squeeze(mean(res(G==i,:,:))),'stacked');
    legend('pos','neg')
    title(areaName{i});ylim([0 1]);xlim([0 5])
    set(gca,'xtickLabel',titleText)
end

tempIdx = [];
tempIdx(:,1) = sigReward&(dirFreeWater==1); % reward pos
tempIdx(:,2) = sigReward&(dirFreeWater==0); % reward neg
tempIdx(:,3) = sigPuff&(dirFreePuff==1); % airpuff pos
tempIdx(:,4) = sigPuff&(dirFreePuff==0); % airpuff neg
figure;
titleText = {'reward pos','reward neg','airpuff pos','airpuff neg'};

for i = 1:4
    subplot(2,2,i)
    barh(grpstats(tempIdx(:,i),G')); set(gca,'ytickLabel',areaName);xlim([0 1])
    title(titleText{i})
end