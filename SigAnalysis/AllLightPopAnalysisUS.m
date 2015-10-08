%path1 = pwd;
%path2 = 'C:\Users\uchidalab\Dropbox (Uchida Lab)\lab\FunInputome\rabies\analysis2015Fall\newLight\';
fl = what(pwd);
fl = fl.mat;
%fl = getfiles_OnlyInOnePath (path1,path2);
%%
for i = 1:length(fl)
    a = load(fl{i},'area');
    brainArea{i} = a.area;
    Tus(i,:) = CompuateUSrelatedResponse(fl{i});
    CS(i,:) = CompuateCSRelatedResponse(fl{i});    
end

%% change  the name of brain areas
oldnames = {'Striatum','LH','VS','PPTg','RMTg','VP','St','DA','VTA3','VTA2','Ce'};
newnames = {'Dorsal striatum','Lateral hypothalamus','Ventral striatum',...
    'PPTg','RMTg','Ventral pallidum','Dorsal striatum','Dopamine','VTA type3',...
    'VTA type2','Central amygdala'};
oldbrain = brainArea;
for i = 1:length(oldnames)
    idx = ismember(oldbrain,oldnames{i});
    brainArea(idx) = newnames(i);
end
[G,areaName]=grp2idx(brainArea);

%% seperate the latency by short and long
llatency = nan(length(fl),1); % VTA neurons doesn't have latency are nans
for i = 1:length(fl)
    load(fl{i},'lightResult')
    if exist('lightResult','var')
        llatency(i) = lightResult.latency; 
    end
    clear lightResult
end
[G L] = grp2idx(brainArea');
shortcount = grpstats(llatency<=6,G,'sum');
longcount = grpstats(llatency>6,G,'sum');
idx = [1 2 3 4 5 6  10];
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
Tus.pureReward = Tus.sig50Rvs50OM&(~Tus.sigExp)&(~Tus.sig50OM);
Tus.pureExp = Tus.sig90Reward&(~Tus.sig50Rvs50OM)&Tus.EXPsign;
Tus.RPE = Tus.sig50R&Tus.sigExp&Tus.RPEsign;
Tus.pureRewardWithCue = Tus.pureReward&(CS.sig50vs0_long>0.05)&(CS.sig90vs0_long>0.05);

Tus.pureExpDir = double(Tus.sig90Reward&(~Tus.sig50Rvs50OM)).*Tus.EXPsign;
Tus.pureRPEDir = double(Tus.sig50R&(~Tus.sigExp)).*Tus.RPEsign;
Tus.brainArea = brainArea';
Tus.mixed = Tus.sig50Rvs50OM&(~Tus.pureReward)&(~Tus.RPE);
Tus.other = (~Tus.sig50Rvs50OM)&(~Tus.pureExp);
Tus.brainArea = brainArea';
%writetable(Tus,[savePath 'us_nonlight.txt'],'Delimiter',',');

Tus_short = Tus(llatency<=6|isnan(llatency),:);
Tus_long = Tus(llatency>6|isnan(llatency),:);
writetable(Tus_short,[savePath 'us_short.txt'],'Delimiter',',');
writetable(Tus_long,[savePath 'us_long.txt'],'Delimiter',',');

% with CS and positive RPE
Tus.RPE = Tus.sig50R&Tus.sigExp&Tus.RPEsign;
Tus.RPEsign = Tus.RPEsign.*Tus.RPE;
Tus.RPEsign(Tus.RPEsign==2) = -1;
PosRPE = double(Tus.RPEsign.*CS.csValue >0);

%% with CS and positive RPE, negative RPE

AllRPE = double((Tus.RPEsign.*CS.csValue >0)&(Tus.OM50sign.*CS.csValue >0));
CSposNegRPE = AllRPE;
CSposRPE = PosRPE;
JoinedRPE = table(CSposRPE,CSposNegRPE);
JoinedRPE.brainArea = brainArea';
writetable(JoinedRPE,[savePath 'jRPE.txt'],'Delimiter',',');

%% make average PSTH response for specific groups
inputG = G<=6|G==10;
plotAveragePSTH_analyzed_filelist(fl(Tus.pureReward&inputG&Tus.Rewardsign)) %,savePath
plotAveragePSTH_analyzed_filelist(fl(Tus.RPE&inputG&Tus.Rewardsign)) %,savePath

plotAveragePSTH_analyzed_filelist(fl(Tus.pureExpDir==1&inputG)) %,savePath

plotAveragePSTH_analyzed_filelist(fl(Tus.pureExpDir==2&inputG)) %,savePath
plotAveragePSTH_analyzed_filelist(fl(Tus.pureRewardWithCue&inputG)) %,savePath

plotAveragePSTH_analyzed_filelist(fl(Tus.pureReward&(G<=7|G==10)))
idx = find(Tus.sigReward&(~Tus.sigExp)&(~Tus.sig50OM));
plot_pop_summary_fromAnalyzedPanel( fl(idx),savePath)

%%
otherMixed = Tus.sigReward&Tus.sigExp&(~RPE);
allRes = grpstats([otherMixed Tus.sigReward&(~Tus.sigExp)  Tus.sigExp&(~Tus.sigReward)  RPE],G);
figure;
bar(allRes,'stack')
set(gca,'xtickLabel',areaName)
legend('other','pure reward','pure exp','pure RPE')
%%
savePath = 'D:\Dropbox (Uchida Lab)\lab\FunInputome\rabies\allIdentified\Analysis\psthPlottings\check\';
plot_pop_summary_fromAnalyzedPanel( fl(Tus.other&G==3),savePath)
%% Compute complete RPE signal


figure;
bar(grpstats(CSposRPE,G))
set(gca,'xtickLabel',areaName)

%%

fl((us.pureExp)&(G==3))