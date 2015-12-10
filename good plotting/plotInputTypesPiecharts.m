% plot pie chart of response in all areas

Tus.pureReward = Tus.sig50Rvs50OM&(~Tus.sigExp)&(~Tus.sig50OM);
Tus.pureExp = Tus.sig90Reward&(~Tus.sig50Rvs50OM)&Tus.EXPsign;
Tus.pureRewardWithCue = Tus.pureReward&(TCS.sig90vsbslong>0.05)&(TCS.sig50vsbslong>0.05);
Tus.pureRewardSomeCue = Tus.pureReward&(~Tus.pureRewardWithCue);

Tus.brainArea = brainArea';
Tus.mixed = Tus.sig50Rvs50OM&(~Tus.pureReward);
Tus.other = (~Tus.sig50Rvs50OM)&(~Tus.pureExp);
%%
noPlotArea = ismember(areaName,{'rVTA Type2','r VTA Type3','rdopamine'});

inputArea = areaName(~noPlotArea);

colorMatrix = [1 0 0;      %// red
          0 1 0;      %// green
          0 0 1;      %// blue
          .5 .5 .5];
figure;
for i = 1:length(inputArea)
    brainInd = strcmp(Tus.brainArea, inputArea{i});
    tempT = Tus(brainInd,{'pureRewardWithCue','pureRewardSomeCue','mixed','pureExp'});
    perc = mean(tempT{:,:});
    perc(perc==0) = 0.001;
    perc = [perc, 1-sum(perc)];
    subplot(3,4,i)
    pie(perc)
    title(inputArea{i})
end

subplot(3,4,12)
pie([0.2,0.2,0.2,0.2,0.2], {'pureRewardWithCue','pureRewardSomeCue','mixed','pureExp','other'})

figure;
vtaAreaIdx = ismember(areaName,{'Dopamine','VTA type2','VTA type3','rVTA Type2','r VTA Type3','rdopamine'});
inputArea = areaName(~vtaAreaIdx);
brainInd = ismember(Tus.brainArea, inputArea);
tempT = Tus(brainInd,{'pureRewardWithCue','pureRewardSomeCue','mixed','pureExp'});
perc = mean(tempT{:,:});
perc(perc==0) = 0.001;
perc = [perc, 1-sum(perc)];
pie(perc)
legend('pureRewardWithCue','pureRewardSomeCue','mixed','pureExp','other')
%%
plotRPE = table();
plotRPE.allRPE = JoinedRPE.CSposNegRPE;
plotRPE.PosNotAll = JoinedRPE.CSposRPE&(~JoinedRPE.CSposNegRPE);
plotRPE.RewardNotOther = JoinedRPE.RewardRPE&(~JoinedRPE.CSposRPE);

figure;
for i = 1:length(inputArea)
    brainInd = strcmp(Tus.brainArea, inputArea{i});
    tempT = plotRPE(brainInd,{'allRPE','PosNotAll','RewardNotOther'});
    perc = mean(tempT{:,:});
    perc(perc==0) = 0.001;
    perc = [perc, 1-sum(perc)];
    subplot(3,4,i)
    pie(perc)
    title(inputArea{i})
end

subplot(3,4,12)
pie([0.2,0.2,0.2,0.4], {'allRPE','PosNotAll','RewardNotOther','other'})



figure;
vtaAreaIdx = ismember(areaName,{'Dopamine','VTA type2','VTA type3','rVTA Type2','r VTA Type3','rdopamine'});
inputArea = areaName(~vtaAreaIdx);
brainInd = ismember(Tus.brainArea, inputArea);
tempT = plotRPE(brainInd,{'allRPE','PosNotAll','RewardNotOther'});
perc = mean(tempT{:,:});
perc(perc==0) = 0.001;
perc = [perc, 1-sum(perc)];
pie(perc)
legend('allRPE','PosNotAll','RewardNotOther','other')