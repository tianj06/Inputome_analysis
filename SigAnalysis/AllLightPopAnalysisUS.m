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
bl = [];
for i = 1:length(fl)
    load(fl{i},'analyzedData')
    bl(i) = mean(analyzedData.rawPSTH(1,1:1000));
end
%% merge some areas
% PPTg: PPTg (all animals other than PPTg_an), PPTg_an('Laurel', 'Kittentail')
% LH: LH_po ('Waterlily','Rice') LH_psth('Aubonpain') LH_an (all others)
% areaSetting1: PPTg only posterior; LH only anterior
brainArea(ismember(brainArea,{'LH_an'})) = {'LH'};

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

vtaAreaIdx = ismember(areaName,{'Dopamine','VTA type2','VTA type3'});
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
Tus.pureReward = Tus.sig50Rvs50OM&(~Tus.sigExp)&(~Tus.sig50OM);
Tus.pureExp = Tus.sig90Reward&(~Tus.sig50Rvs50OM)&Tus.EXPsign;
Tus.RPE = Tus.sig50R&Tus.sigExp&Tus.RPEsign;
Tus.pureRewardWithCue = Tus.pureReward&(CS.sig90vsbslong>0.05)&(CS.sig50vsbslong>0.05);

Tus.pureExpDir = double(Tus.sig90Reward&(~Tus.sig50Rvs50OM)).*Tus.EXPsign;
Tus.pureRPEDir = double(Tus.sig50R&(~Tus.sigExp)).*Tus.RPEsign;
Tus.brainArea = brainArea';
Tus.mixed = Tus.sig50Rvs50OM&(~Tus.pureReward)&(~Tus.RPE);
Tus.other = (~Tus.sig50Rvs50OM)&(~Tus.pureExp);
Tus.brainArea = brainArea';
writetable(Tus,[savePath 'us_light2.txt'],'Delimiter',',');

Tus_short = Tus(llatency<=6|isnan(llatency),:);
Tus_long = Tus(llatency>6|isnan(llatency),:);
writetable(Tus_short,[savePath 'us_short2.txt'],'Delimiter',',');
writetable(Tus_long,[savePath 'us_long2.txt'],'Delimiter',',');

Tus_early = Tus(rdate<=11|isnan(llatency),:);
Tus_late = Tus(rdate>11|isnan(llatency),:);
writetable(Tus_early,[savePath 'us_early.txt'],'Delimiter',',');
writetable(Tus_late,[savePath 'us_late.txt'],'Delimiter',',');

% with CS and positive RPE
Tus.RPE = Tus.sig50R&Tus.sigExp&Tus.RPEsign;
Tus.RPEsign = Tus.RPEsign.*Tus.RPE;
Tus.RPEsign(Tus.RPEsign==2) = -1;
PosRPE = double(Tus.RPEsign.*CS.csValue >0);

%% plot bar graphs of response
us_plot = Tus(:,{'pureReward','pureRewardWithCue','pureExp'});
us_plot.mixed = Tus.sig50Rvs50OM&(~Tus.pureReward);
colNames = us_plot.Properties.VariableNames;
percent = [];
percent(1,:) = mean(us_plot{~isnan(llatency),:});
percent(2,:) = mean(us_plot{llatency<=6,:});
%percent(2,:) = mean(us_plot{llatency>6,:});
percent(3,:) = mean(us_plot{rdate<=11,:});
%percent(5,:) = mean(us_plot{rdate>11,:});

%rowNames = {'short latency','long latency','all','early rabies','late rabies'};
rowNames = {'all','short latency','early rabies'};
figure;
bar(100*percent)
set(gca,'xticklabels',rowNames)
legend(colNames)
prettyP('','','','','a')

figure;
bar(100*percent')
set(gca,'xticklabels',colNames)
legend(rowNames)
prettyP('','','','','a')
%%
clear percent
percent(1,:) = mean(us_plot{llatency<=3,:});
percent(2,:) = mean(us_plot{llatency>3&llatency<=5,:});
percent(3,:) = mean(us_plot{llatency>5&llatency<=8,:});
percent(4,:) = mean(us_plot{llatency>8,:});
figure;
bar(100*percent)
legend(colNames)
set(gca,'xticklabels',{'<3','3-5','5-8','>8'})
savePath = 'C:\Users\uchidalab\Dropbox (Uchida Lab)\lab\FunInputome\rabies\analysis2015Fall\';
plot_pop_summary_fromAnalyzedPanel(fl(llatency<=3&Tus.pureReward),savePath,'Inputs3msPureReward')

plot_pop_summary_fromAnalyzedPanel(fl(llatency>3&llatency<=5&Tus.pureReward),savePath,'Inputs3-5msPureReward')

plot_pop_summary_fromAnalyzedPanel(fl(llatency>5&llatency<=8&Tus.pureReward),savePath,'Inputs5-8msPureReward')

figure;
bins = 0:2:50;
histData(1,:) = hist(bl(llatency<=3),bins);
histData(2,:) = hist(bl(llatency>3&llatency<=5),bins);
histData(3,:) = hist(bl(llatency>5&llatency<=8),bins);
for i = 1:3
    subplot(3,1,i)
    histData(i,:) = histData(i,:)/sum(histData(i,:));
    bar(bins,histData(i,:))
    ylim([0 0.3])
end

percent(1,:) = mean(us_plot{llatency<=3&G~=6,:});
percent(2,:) = mean(us_plot{llatency>3&llatency<=5&G~=6,:});
percent(3,:) = mean(us_plot{llatency>5&llatency<=8&G~=6,:});
percent(4,:) = mean(us_plot{llatency>8&G~=6,:});
figure;
bar(100*percent)
legend(colNames)
set(gca,'xticklabels',{'<3','3-5','5-8','>8'})

subIdx = llatency>8;
countA = zeros(1,length(areaName));
for i = 1:length(areaName)
    countA(i) = sum(G(subIdx)==i);
end
%% with CS and positive RPE, negative RPE

AllRPE = double((Tus.RPEsign.*CS.csValue >0)&(Tus.OM50sign.*CS.csValue >0));
RewardRPE = Tus.RPE;
CSposNegRPE = AllRPE;
CSposRPE = PosRPE;
JoinedRPE = table(CSposRPE,CSposNegRPE,RewardRPE);
JoinedRPE.brainArea = brainArea';
writetable(JoinedRPE,[savePath 'jRPE.txt'],'Delimiter',',');
JoinedRPE_short = JoinedRPE(llatency<=6|isnan(llatency),:);
writetable(JoinedRPE_short,[savePath 'jRPE_short2.txt'],'Delimiter',',');

JoinedRPE_early = JoinedRPE(rdate<=11|isnan(llatency),:);
writetable(JoinedRPE_early,[savePath 'jRPE_early.txt'],'Delimiter',',');

JoinedRPE_late = JoinedRPE(rdate>11|isnan(llatency),:);
writetable(JoinedRPE_late,[savePath 'jRPE_late.txt'],'Delimiter',',');

%%
rpe_plot = [Tus.RPE PosRPE AllRPE];
percent = [];
percent(1,:) = mean(rpe_plot(~isnan(llatency),:));
percent(2,:) = mean(rpe_plot(llatency<=6,:));
percent(3,:) = mean(rpe_plot(rdate<=11,:));

rowNames = {'all','short latency','early rabies'};
figure;
w = [0.6 0.4 0.2];
c = color_select(3);
for i = 1:3
    bar(1:3,100*percent(:,i),w(i),'FaceColor',c(i,:))
    hold on;
end
set(gca,'xticklabels',rowNames)
legend({'reward RPE', 'reward&cue RPE', 'all RPE'})
prettyP('','','','','a')


%% make average PSTH response for specific groups
inputG = ~ismember(G,find(vtaAreaIdx));
plotAveragePSTH_analyzed_filelist(fl(Tus.pureReward&inputG&Tus.Rewardsign)) %,savePath
plotAveragePSTH_analyzed_filelist(fl(Tus.RPE&inputG&Tus.Rewardsign)) %,savePath

plotAveragePSTH_analyzed_filelist(fl(Tus.pureExpDir==1&inputG)) %,savePath

plotAveragePSTH_analyzed_filelist(fl(Tus.pureExpDir==2&inputG)) %,savePath
plotAveragePSTH_analyzed_filelist(fl(Tus.pureRewardWithCue&inputG)) %,savePath
 plot_pop_summary_fromAnalyzed(fl(Tus.pureRewardWithCue&inputG))
plot_pop_summary_fromAnalyzedPanel(fl(Tus.pureRewardWithCue&inputG),savePath)

plotAveragePSTH_analyzed_filelist(fl(Tus.pureReward&(G<=7|G==10)))

idx = find(Tus.sigReward&(~Tus.sigExp)&(~Tus.sig50OM));
plot_pop_summary_fromAnalyzedPanel( fl(idx),savePath)

 plot_pop_summary_fromAnalyzed(fl(CSposRPE&inputG))

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