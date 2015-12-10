%path1 = pwd;
%path2 = 'C:\Users\uchidalab\Dropbox (Uchida Lab)\lab\FunInputome\rabies\analysis2015Fall\newLight\';
fl = what(pwd);
fl = fl.mat;
%fl = getfiles_OnlyInOnePath (path1,path2);
%%
for i = 1:length(fl)
    a = load(fl{i},'area');
    brainArea{i} = a.area;
    TusJump(i,:) = CompuateMixedStateResponse(fl{i});
    Tus(i,:) = CompuateUSrelatedResponse(fl{i});
    CS(i,:) = CompuateCSRelatedResponse(fl{i});    
end
% bl = [];
% for i = 1:length(fl)
%     load(fl{i},'analyzedData')
%     bl(i) = mean(analyzedData.rawPSTH(1,1:1000));
% end
%% merge some areas
% PPTg: PPTg (all animals other than PPTg_an), PPTg_an('Laurel', 'Kittentail')
% LH: LH_po ('Waterlily','Rice') LH_psth('Aubonpain') LH_an (all others)
% areaSetting1: PPTg only posterior; LH only anterior
%brainArea(ismember(brainArea,{'LH_an'})) = {'LH'};

% areaSetting2: PPTg all; LH all
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
[G,areaName]=grp2idx(brainArea);
for i = 1:length(areaName)
    disp(areaName{i})
    disp(sum(G==i))
end
%% seperate the latency by short and long
llatency = nan(length(fl),1); % VTA neurons doesn't have latency are nans
rdate = nan(length(fl),1);
for i = 1:length(fl)
    load(fl{i},'lightResult','rabiesDate')
    if exist('lightResult','var')
        llatency(i) = lightResult.latency; 
        rdate(i) = rabiesDate;
    end
    clear lightResult rabiesDate
end
[G L] = grp2idx(brainArea');
shortcount = grpstats(llatency<=6,G,'sum');
longcount = grpstats(llatency>6,G,'sum');

vtaAreaIdx = ismember(areaName,{'Dopamine','VTA type2','VTA type3','rVTA Type2','r VTA Type3','rdopamine'});
idx = ~vtaAreaIdx;
bardata = [-shortcount(idx),longcount(idx)];
figure
barh(longcount(idx),'BaseValue',0)
hold on;
barh(-shortcount(idx),'BaseValue',0)
set(gca,'ytickLabel',L(idx))
xlabel('# neurons')
set(gca,'xlabel')
%%
savePath = ['C:\Users\uchidalab\Documents\GitHub\Inputome_analysis\SigAnalysis\'];
% mixed state 1) more 50% jump than 90% jump, direction of jump is consistent with cue response 
TusJump.MixedState = TusJump.sig50vs90&(TusJump.dir50R.*CS.csValue==1);
% state value 1) reward neurons that also have cs value. reward direction
% same as cs value response
Tus.pureReward = Tus.sig50Rvs50OM&(~Tus.sigExp)&(~Tus.sig50OM);
rewardSign = Tus.Rewardsign;
rewardSign (rewardSign==0) = -1;
TusJump.ValueState = Tus.pureReward & (CS.csValue.*rewardSign==1);

free = 0;
ax = plotAveragePSTH_analyzed_filelist(fl(TusJump.MixedState), free);%,savePath

ax = plotAveragePSTH_analyzed_filelist(fl(TusJump.ValueState), free);%,savePath

TusJump.brainArea = brainArea';
tb=grpstats(TusJump, 'brainArea','sum','DataVars',{'MixedState','ValueState'});

%%
VTA2 = strcmp('VTA2',brainArea);
TusJump(VTA2,:)

plot_pop_summary_fromAnalyzedPanel(fl(VTA2))

