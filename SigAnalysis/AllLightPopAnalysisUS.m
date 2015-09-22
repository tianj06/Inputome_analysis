fl = what(pwd);
fl = fl.mat;
for i = 1:length(fl)
    a = load(fl{i},'area');
    brainArea{i} = a.area;
end
for i = 1:length(fl)
    Tus(i,:) = CompuateUSrelatedResponse(fl{i});
    CS(i,:) = CompuateCSRelatedResponse(fl{i});    
end

[G,areaName]=grp2idx(brainArea);
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
%%

figure;
bar(grpstats(Tus.sig50Rvs50OM,G))
set(gca,'xtickLabel',areaName)

figure;
bar(grpstats(Tus.other,G))
set(gca,'xtickLabel',areaName)

RPE = Tus.sig50Rvs50OM&Tus.sigExp&Tus.RPEsign;
figure;
bar(grpstats(RPE,G))
set(gca,'xtickLabel',areaName)
%%
savePath = ['C:\Users\uchidalab\Dropbox (Uchida Lab)\lab\FunInputome\rabies\analysis2015Fall\'];
Tus.pureReward = Tus.sig50Rvs50OM&(~Tus.sigExp)&(~Tus.sig50OM);
Tus.pureExp = Tus.sig90Reward&(~Tus.sig50Rvs50OM)&Tus.EXPsign;
Tus.RPE = Tus.sig50R&Tus.sigExp&Tus.RPEsign;

Tus.pureExpDir = double(Tus.sig90Reward&(~Tus.sig50Rvs50OM)).*Tus.EXPsign;
Tus.pureRPEDir = double(Tus.sig50R&(~Tus.sigExp)).*Tus.RPEsign;
Tus.brainArea = brainArea';
Tus.mixed = Tus.sig50Rvs50OM&(~Tus.pureReward)&(~Tus.RPE);
Tus.other = (~Tus.sig50Rvs50OM)&(~Tus.pureExp);
Tus.brainArea = brainArea';
%writetable(Tus,[savePath 'us.txt'],'Delimiter',',');
%% make average PSTH response for specific groups
inputG = G<=7|G==10;
plotAveragePSTH_analyzed_filelist(fl(Tus.pureReward&inputG&Tus.Rewardsign)) %,savePath
plotAveragePSTH_analyzed_filelist(fl(Tus.RPE&inputG&Tus.Rewardsign)) %,savePath

plotAveragePSTH_analyzed_filelist(fl(Tus.pureExpDir==1&inputG)) %,savePath

plotAveragePSTH_analyzed_filelist(fl(Tus.pureExpDir==2&inputG)) %,savePath


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

% with CS and positive RPE
Tus.RPE = Tus.sig50R&Tus.sigExp&Tus.RPEsign;
Tus.RPEsign = Tus.RPEsign.*Tus.RPE;
Tus.RPEsign(Tus.RPEsign==2) = -1;
PosRPE = double(Tus.RPEsign.*CS.csValue >0);

% with CS and positive RPE, negative RPE

AllRPE = double((Tus.RPEsign.*CS.csValue >0)&(Tus.OM50sign.*CS.csValue >0));
CSposNegRPE = AllRPE;
CSposRPE = PosRPE;
JoinedRPE = table(CSposRPE,CSposNegRPE);
JoinedRPE.brainArea = brainArea';
writetable(JoinedRPE,[savePath 'jRPE.txt'],'Delimiter',',');


figure;
bar(grpstats(CSposRPE,G))
set(gca,'xtickLabel',areaName)

%%

fl((us.pureExp)&(G==3))