fl = what(pwd);
fl = fl.mat;
N = length(fl);
%%
sigPuff = [];
sigRCS = zeros(N,1);
direRCS = zeros(N,1);
sigACS = zeros(N,1);
direACS = zeros(N,1);
for i = 1:length(fl)
    a = load(fl{i},'area');
    brainArea{i} = a.area;
    load(fl{i}, 'analyzedData')
    if ~exist('analyzedData', 'var')
        analyzedData = getPSTHSingleUnit(fl{i}); 
        save(fl{i},'-append','analyzedData')
    end
    load(fl{i}, 'valueAnalyzedUS')
    if exist('valueAnalyzedUS','var')
        Tus(i,:) = valueAnalyzedUS;
    else
        Tus(i,:) = CompuateUSrelatedResponse(fl{i},1);
    end
    % comopute airpuff response
    rs = analyzedData.raster;
    urs = rs([4 7]); % 0, 50% omission, 50 reward, 90 reward
    % extract US response (subtract by iti baseline)
    TimeWin = 1:500;
    US_spikes = cellfun( @(x)1000*mean(x(:,TimeWin+3000),2),urs,'UniformOutput',0);
    [~,sigPuff(i)] = ranksum(US_spikes{1}, US_spikes{2}); 
    direPuff(i) = mean(US_spikes{1}) > mean(US_spikes{2});
    
    ucs = rs([11 13 14]);
    CS_spikes = cellfun( @(x)1000*mean(x(:,TimeWin+3000),2),ucs,'UniformOutput',0);
    [~,sigRCS(i)] = ranksum(CS_spikes{1}, CS_spikes{2}); 
    direRCS(i) = mean(CS_spikes{1}) > mean(CS_spikes{2});
    [~,sigACS(i)] = ranksum(CS_spikes{3}, CS_spikes{2}); 
    direACS(i) = mean(CS_spikes{3}) > mean(CS_spikes{2});   
end
direPuff = direPuff';
sigPuff = sigPuff';
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
for i = 1:length(areaName)
    disp(areaName{i})
    disp(sum(G==i))
end

%% remove VTA rabies units
VTAind = ismember(brainArea,{'rVTA Type2','r VTA Type3','rdopamine'});
fl = fl(~VTAind);
direPuff = direPuff(~VTAind);
sigPuff = sigPuff(~VTAind);
brainArea = brainArea(~VTAind);
% reward responsive units
sigReward = Tus.sig50Rvs50OM & Tus.sig50R;
direReward = Tus.Rewardsign;% 1, >0 else 0
sigReward = sigReward(~VTAind);
direReward = direReward(~VTAind);
sigRCS = sigRCS(~VTAind,1);
direRCS = direRCS(~VTAind,1);
sigACS = sigACS(~VTAind,1);
direACS = direACS(~VTAind,1);
%% US analysis
tempIdx = [];
tempIdx(:,1) = sigReward&sigPuff&(direPuff==direReward); %RewadPuffSame
tempIdx(:,2) = sigReward&sigPuff&(direPuff~=direReward); % RewardPuffOppo
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
for i = 1:10
    subplot(3,4,i)
    res(:,1,1) = tempIdx(:,1)&direReward==1;
    res(:,1,2) = tempIdx(:,1)&direReward==0;
    res(:,2,1) = tempIdx(:,2)&direReward==1;
    res(:,2,2) = tempIdx(:,2)&direReward==0;
    res(:,3,1) = tempIdx(:,3)&direReward==1;
    res(:,3,2) = tempIdx(:,3)&direReward==0;
    res(:,4,1) = tempIdx(:,4)&direPuff==1;
    res(:,4,2) = tempIdx(:,4)&direPuff==0;
    bar(squeeze(mean(res(G==i,:,:))),'stacked');
    legend('pos','neg')
    title(areaName{i});ylim([0 1]);xlim([0 5])
    %set(gca,'xtickLabel',titleText)
end

%% CS analysis
tempIdx = [];
tempIdx(:,1) = sigRCS&sigACS&(direACS==direRCS); %RewadPuffSame
tempIdx(:,2) = sigRCS&sigACS&(direACS~=direRCS); % RewardPuffOppo
tempIdx(:,3) = sigRCS&(~sigACS); %rewardOnly
tempIdx(:,4) = (~sigRCS)&sigACS; %puffOnly
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
for i = 1:10
    subplot(3,4,i)
    res(:,1,1) = tempIdx(:,1)&direRCS==1;
    res(:,1,2) = tempIdx(:,1)&direRCS==0;
    res(:,2,1) = tempIdx(:,2)&direRCS==1;
    res(:,2,2) = tempIdx(:,2)&direRCS==0;
    res(:,3,1) = tempIdx(:,3)&direRCS==1;
    res(:,3,2) = tempIdx(:,3)&direRCS==0;
    res(:,4,1) = tempIdx(:,4)&direACS==1;
    res(:,4,2) = tempIdx(:,4)&direACS==0;
    bar(squeeze(mean(res(G==i,:,:))),'stacked');
    legend('pos','neg')
    title(areaName{i});ylim([0 1]);xlim([0 5])
    set(gca,'xtickLabel',titleText)
end
