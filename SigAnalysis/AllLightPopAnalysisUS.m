% path1 = pwd;
% path2 = 'C:\Users\uchidalab\Dropbox (Uchida Lab)\lab\FunInputome\rabies\analysis2015Fall\newLight\';
% fl = getfiles_OnlyInOnePath (path1,path2);

fl = what(pwd);
fl = fl.mat;
%%
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
    load(fl{i},'CS')
    if  exist('CS','var')
        TCS(i,:) = CS;    
    else
        TCS(i,:) = CompuateCSRelatedResponse(fl{i},1);   
    end
    clear CS valueAnalyzedUS analyzedData
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
Tus.pureReward = Tus.sig50Rvs50OM&(~Tus.sigExp)&(~Tus.sig50OM);
Tus.pureExp = Tus.sig90Reward&(~Tus.sig50Rvs50OM)&Tus.EXPsign;
Tus.RPE = Tus.sig50R&Tus.sigExp&Tus.RPEsign;
Tus.pureRewardWithCue = Tus.pureReward&(TCS.sig90vsbslong>0.05)&(TCS.sig50vsbslong>0.05);

Tus.pureExpDir = double(Tus.sig90Reward&(~Tus.sig50Rvs50OM)).*Tus.EXPsign;
Tus.pureRPEDir = double(Tus.sig50R&(~Tus.sigExp)).*Tus.RPEsign;
Tus.brainArea = brainArea';
Tus.mixed = Tus.sig50Rvs50OM&(~Tus.pureReward)&(~Tus.RPE);
Tus.other = (~Tus.sig50Rvs50OM)&(~Tus.pureExp);
Tus.brainArea = brainArea';
%writetable(Tus,[savePath 'us_nonlight.txt'],'Delimiter',',');

Tus_short = Tus(llatency<=6|isnan(llatency),:);
Tus_long = Tus(llatency>6|isnan(llatency),:);
writetable(Tus_short,[savePath 'us_short3.txt'],'Delimiter',',');
writetable(Tus_long,[savePath 'us_long3.txt'],'Delimiter',',');

Tus_early = Tus(rdate<=11|isnan(llatency),:);
Tus_late = Tus(rdate>11|isnan(llatency),:);
%writetable(Tus_early,[savePath 'us_early.txt'],'Delimiter',',');
%writetable(Tus_late,[savePath 'us_late.txt'],'Delimiter',',');

% with CS and positive RPE
Tus.RPE = Tus.sig50R&Tus.sigExp&Tus.RPEsign;
Tus.RPEsign = Tus.RPEsign.*Tus.RPE;
Tus.RPEsign(Tus.RPEsign==2) = -1;
PosRPE = double(Tus.RPEsign.*TCS.csValue >0);
%plot_pop_summary_fromAnalyzedPanel(fl(Tus.RPEsign==-1&G == 6),savePath,'Inputs3msPureReward')
a = fl(Tus.RPEsign==-1&G == 6);
for i = 1:length(a)
    quickPSTHPlotting_formatted_3(a{i})
end
%% plot bar graphs of response
inputG = ~ismember(G,find(vtaAreaIdx));
inputG = ismember(brainArea,{'Dorsal striatum','Lateral hypothalamus','Ventral striatum',...
    'PPTg','RMTg','Ventral pallidum','Subthalamic'});

us_plot = Tus(:,{'pureReward','pureRewardWithCue','pureExp'});
us_plot.mixed = Tus.sig50Rvs50OM&(~Tus.pureReward);
colNames = us_plot.Properties.VariableNames;
% plot non light neurons
percent(1,:) = mean(us_plot{inputG,:});
figure;
bar(100*percent,'edgecolor','none');
set(gca,'xticklabels',colNames)

% plot light neurons
percent = [];
percent(1,:) = mean(us_plot{~isnan(llatency)&inputG,:});
percent(2,:) = mean(us_plot{llatency<=6&inputG,:});
%percent(2,:) = mean(us_plot{llatency>6,:});
percent(3,:) = mean(us_plot{rdate<=11&inputG,:});
%percent(5,:) = mean(us_plot{rdate>11,:});

%rowNames = {'short latency','long latency','all','early rabies','late rabies'};
rowNames = {'all','short latency','early rabies'};
figure;
bar(100*percent,'edgecolor','none');
set(gca,'xticklabels',rowNames)
legend(colNames)
prettyP('','','',[0:10:40],'a')


% figure;
% bar(100*percent')
% set(gca,'xticklabels',colNames)
% legend(rowNames)
% prettyP('','','','','a')
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

AllRPE = double((Tus.RPEsign.*TCS.csValue >0)&(Tus.OM50sign.*TCS.csValue >0));
RewardRPE = Tus.RPE;
CSposNegRPE = AllRPE;
CSposRPE = PosRPE;
JoinedRPE = table(CSposRPE,CSposNegRPE,RewardRPE);
JoinedRPE.brainArea = brainArea';
writetable(JoinedRPE,[savePath 'jRPE_nonlight.txt'],'Delimiter',',');
JoinedRPE_short = JoinedRPE(llatency<=6|isnan(llatency),:);
writetable(JoinedRPE_short,[savePath 'jRPE_short2.txt'],'Delimiter',',');

JoinedRPE_early = JoinedRPE(rdate<=11|isnan(llatency),:);
writetable(JoinedRPE_early,[savePath 'jRPE_early.txt'],'Delimiter',',');

JoinedRPE_late = JoinedRPE(rdate>11|isnan(llatency),:);
writetable(JoinedRPE_late,[savePath 'jRPE_late.txt'],'Delimiter',',');

%%
rpe_plot = [Tus.RPE PosRPE AllRPE];
percent = mean(rpe_plot(inputG,:));
figure; bar(1:3,percent)
set(gca,'xticklabel',{'reward RPE', 'reward&cue RPE', 'all RPE'})

percent = [];
percent(1,:) = mean(rpe_plot(~isnan(llatency)&inputG,:));
percent(2,:) = mean(rpe_plot(llatency<=6&inputG,:));
percent(3,:) = mean(rpe_plot(rdate<=11&inputG,:));
rowNames = {'all','short latency','early rabies'};
figure;
w = [0.6 0.48 0.35];
c = color_select(3);
for i = 1:3
    bar(1:3,100*percent(:,i),w(i),'FaceColor',c(i,:),'EdgeColor','none')
    hold on;
end
set(gca,'xticklabels',rowNames)
legend({'reward RPE', 'reward&cue RPE', 'all RPE'})
prettyP('','','','','a')


%% make average PSTH response for specific groups
% areas that miss free reward responses
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

