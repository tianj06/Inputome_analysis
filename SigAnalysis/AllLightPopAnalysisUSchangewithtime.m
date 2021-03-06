fl = what(pwd);
fl = fl.mat;
%fl = getfiles_OnlyInOnePath (path1,path2);
%%
for i = 1:length(fl)
    a = load(fl{i},'area');
    brainArea{i} = a.area;
    Tus_before(i,:) = CompuateUSrelatedResponse(fl{i},0,-499:0);
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
Tus_before.Timewin = repmat({'before'},N,1);
Tus_before.brainArea = brainArea';
TusFinal = vertcat(Tus, Tuslate);
TusFinal = vertcat(Tus_before,TusFinal);
beep
%%
TusFinal.pureReward = TusFinal.sig50Rvs50OM&(~TusFinal.sigExp)&(~TusFinal.sig50OM);
TusFinal.pureExp = TusFinal.sig90Reward&(~TusFinal.sig50Rvs50OM)&TusFinal.EXPsign;

TusFinal.pureExpDir = double(TusFinal.sig90Reward&(~TusFinal.sig50Rvs50OM)).*TusFinal.EXPsign;
TusFinal.mixed = TusFinal.sig50Rvs50OM&(~TusFinal.pureReward)&(~TusFinal.RPE);
TusFinal.other = (~TusFinal.sig50Rvs50OM)&(~TusFinal.pureExp);

TusFinal.RPE = TusFinal.sig50R&TusFinal.sigExp&TusFinal.RPEsign&TusFinal.sig50Rvs50OM;
TusFinal.pureRPEDir = double(TusFinal.RPE).*TusFinal.RPEsign;

savePath = 'C:\Users\uchidalab\Documents\GitHub\Inputome_analysis\SigAnalysis\';
writetable(TusFinal,[savePath 'us_time_all1.txt'],'Delimiter',',');
%%
inputareas = {'Dorsal striatum','Lateral hypothalamus','Ventral striatum',...
    'PPTg','RMTg','Ventral pallidum','Subthalamic'};
inputA = ismember(TusFinal.brainArea, inputareas);
sum((TusFinal.RPE == 1)&inputA&strcmp(TusFinal.Timewin,'before'))

%%
ustimenew.RPE = TusFinalnew.RPE;
ustimenew.RPEsign = TusFinalnew.RPEsign;
writetable(ustimenew,[savePath 'us_time_new1.txt'],'Delimiter',',');
filelist = fl(ind(352+(1:352)));
for i = 1:length(filelist)
    quickPSTHPlotting_formatted_new(filelist{i})
end
%% debug before reward RPE neurons
ind = TusFinal.RPE&strcmp(TusFinal.Timewin,'before');
filelist = fl(ind);
for i = 1:length(filelist)
    quickPSTHPlotting_formatted_new(filelist{i})
    t_text = filelist{i}(1:end-14);
    title(t_text)
end
