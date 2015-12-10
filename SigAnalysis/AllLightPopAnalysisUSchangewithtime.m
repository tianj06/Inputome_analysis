fl = what(pwd);
fl = fl.mat;
%fl = getfiles_OnlyInOnePath (path1,path2);
%%
for i = 1:length(fl)
    a = load(fl{i},'area');
    brainArea{i} = a.area;
    Tus(i,:) = CompuateUSrelatedResponse(fl{i},0,1:500);
    Tuslate(i,:) = CompuateUSrelatedResponse(fl{i},0,501:1000);
end
brainArea(ismember(brainArea,{'LH_an','LH_psth','LH_po'})) = {'LH'};
brainArea(ismember(brainArea,{'PPTg_an','PPTg'})) = {'PPTg'};
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

N = length(fl);
Tus.Timewin = repmat({'early'},N,1);
Tus.brainArea = brainArea';
Tuslate.Timewin = repmat({'late'},N,1);
Tuslate.brainArea = brainArea';
TusFinal = vertcat(Tus, Tuslate);
%%

TusFinal.pureReward = TusFinal.sig50Rvs50OM&(~TusFinal.sigExp)&(~TusFinal.sig50OM);
TusFinal.pureExp = TusFinal.sig90Reward&(~TusFinal.sig50Rvs50OM)&TusFinal.EXPsign;
TusFinal.RPE = TusFinal.sig50R&TusFinal.sigExp&TusFinal.RPEsign;

TusFinal.pureExpDir = double(TusFinal.sig90Reward&(~TusFinal.sig50Rvs50OM)).*TusFinal.EXPsign;
TusFinal.pureRPEDir = double(TusFinal.sig50R&TusFinal.sigExp).*TusFinal.RPEsign;
TusFinal.mixed = TusFinal.sig50Rvs50OM&(~TusFinal.pureReward)&(~TusFinal.RPE);
TusFinal.other = (~TusFinal.sig50Rvs50OM)&(~TusFinal.pureExp);

TusFinal.RPE = TusFinal.sig50R&TusFinal.sigExp&TusFinal.RPEsign;
TusFinal.RPEsign = TusFinal.RPEsign.*TusFinal.RPE;
TusFinal.RPEsign(TusFinal.RPEsign==2) = -1;
savePath = 'C:\Users\uchidalab\Documents\GitHub\Inputome_analysis\SigAnalysis\';
writetable(TusFinal,[savePath 'us_time.txt'],'Delimiter',',');
