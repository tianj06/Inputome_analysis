%% areas that miss free reward responses
missReward = zeros(length(fl),1);
missOmission = zeros(length(fl),1);
for i = 1:length(fl)
    load(fl{i},'analyzedData')
    trialNum = cellfun(@(x)size(x,1),analyzedData.raster);
    minTrialNum = 5;
    removeTrials = trialNum < minTrialNum;
    missReward(i) = removeTrials(9);
    missOmission(i) =  removeTrials(5);
end
figure;
barh(grpstats(missReward,G,'mean'))
set(gca,'yTicklabels',L)
title('Percent neurons miss free reward')
figure;
barh(grpstats(missOmission,G,'mean'))
set(gca,'yTicklabels',L)
title('Percent neurons miss omission 90% reward')

%% make average PSTH response for specific groups
inputG = ~ismember(G,find(vtaAreaIdx));
free = 0;
if free
    reward_name = '';
else
    reward_name = 'not include free';
end

savePath = 'C:\Users\uchidalab\Dropbox (Uchida Lab)\lab\FunInputome\writing\Figures\average response\';

% postive pure reward
ax = plotAveragePSTH_analyzed_filelist(fl(Tus.pureReward&inputG&Tus.Rewardsign), free);%,savePath
ylim = [-0.5 18]; set(ax(1),'ylim',ylim); set(ax(2),'ylim',ylim); 
export_fig([savePath 'pure reward positive' reward_name],'-pdf')
% negative pure reward
ax = plotAveragePSTH_analyzed_filelist(fl(Tus.pureReward&inputG&~Tus.Rewardsign), free); %,savePath
ylim = [-0.5 25.5]; set(ax(1),'ylim',ylim); set(ax(2),'ylim',ylim); 
export_fig([savePath 'pure reward negative' reward_name],'-pdf')
% pure reward no cue resonse
ax = plotAveragePSTH_analyzed_filelist(fl(Tus.pureRewardWithCue&inputG), free); %,savePath
ylim = [-0.5 16]; set(ax(1),'ylim',ylim); set(ax(2),'ylim',ylim); 
export_fig([savePath 'pure reward positive no cue' reward_name],'-pdf')
% pure expectation positive
ax = plotAveragePSTH_analyzed_filelist(fl(Tus.pureExpDir==1&inputG), free); %,savePath
ylim = [-0.5 14.5]; set(ax(1),'ylim',ylim); set(ax(2),'ylim',ylim); 
export_fig([savePath 'pure expectation positive' reward_name],'-pdf')
% pure expectation negative
ax = plotAveragePSTH_analyzed_filelist(fl(Tus.pureExpDir==2&inputG), free); %,savePath
ylim = [-0.5 30.5]; set(ax(1),'ylim',ylim); set(ax(2),'ylim',ylim); 
export_fig([savePath 'pure expectation negative' reward_name],'-pdf')
% perfect RPE 
ax = plotAveragePSTH_analyzed_filelist(fl(AllRPE&inputG), free); %,savePath
ylim = [-0.5 40.5]; set(ax(1),'ylim',ylim); set(ax(2),'ylim',ylim); 
export_fig([savePath 'perfect RPE' reward_name],'-pdf')
% partial RPE
% Tus.RPE = Tus.sig50R&Tus.sigExp&Tus.RPEsign;
ax = plotAveragePSTH_analyzed_filelist(fl(Tus.RPE&inputG), free); %,savePath
ylim = [-0.5 40.5]; set(ax(1),'ylim',ylim); set(ax(2),'ylim',ylim); 
export_fig([savePath 'partial RPE (only reward)' reward_name],'-pdf')
% mixed all
mixed = Tus.sig50Rvs50OM&(~Tus.pureReward);
ax = plotAveragePSTH_analyzed_filelist(fl(mixed&inputG), free); %,savePath
ylim = [-0.5 35.5]; set(ax(1),'ylim',ylim); set(ax(2),'ylim',ylim); 
export_fig([savePath 'mixed all' reward_name],'-pdf')
% mixed without RPE 
% Tus.mixed = Tus.sig50Rvs50OM&(~Tus.pureReward)&(~Tus.RPE);
ax = plotAveragePSTH_analyzed_filelist(fl(Tus.mixed&inputG), free); %,savePath
ylim = [-0.5 25.5]; set(ax(1),'ylim',ylim); set(ax(2),'ylim',ylim); 
export_fig([savePath 'mixed no reward RPE' reward_name],'-pdf')


fnn = fl(AllRPE&inputG);
for i = 1:length(fnn)
    quickPSTHPlotting_formatted_3(fnn{i})
    load(fnn{i},'area');
    title(area)
end

