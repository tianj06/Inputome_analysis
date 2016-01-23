fl = what(pwd);
fl = fl.mat;
% light identification
formattedpath = 'C:\Users\uchidalab\Dropbox (Uchida Lab)\lab\Ryan thesis\PPTgAllunits';
lowsalt = 0.01;
highsalt = 0.01;
plotflag = 1;
[lightfiles, lightlatency,lightjitter]= ...
    SelectLightResponsiveUnits('PPTg',formattedpath,lowsalt, highsalt,0);

finalLight = lightfiles(lightlatency<6);
lightLabel = ismember(fl,finalLight);
longlightLabel = ismember(fl,lightfiles);
% AAV vs Rabies label
for i = 1:length(fl)
    animals{i} = extractAnimalFolderFromFormatted(fl{i});
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
% %% remove cyrus
% cyrusLabel = ismember(animals,{'Cyrus'});
% animals = animals(~cyrusLabel);
% lightLabel = lightLabel(~cyrusLabel);
% fl = fl(~cyrusLabel);

AAVlabel = ismember(animals,{'ATG','Bruno','Cyrus'});
AAVlight = lightLabel&AAVlabel';
rabieslight = lightLabel&(~AAVlabel');
AAVlightL = longlightLabel&AAVlabel';
rabieslightL = longlightLabel&(~AAVlabel');
%% plotting sorted roc
filelist = fl;
smoothPSTH = zeros(length(filelist),10,5001);
rocPSTH = zeros(length(filelist),10,50);
lickPSTH = zeros(length(filelist),10,5001);
rawPSTH = zeros(length(filelist),10,5001);

for i = 1:length(filelist)
    load([formattedpath '\' filelist{i}], 'analyzedData')
    analyzedData = remove_too_few_trials(analyzedData,5);
    smoothPSTH(i,:,:) = analyzedData.smoothPSTH(1:10,:);
    rocPSTH(i,:,:) = analyzedData.rocPSTH(1:10,:);
    lickPSTH(i,:,:) = analyzedData.rawLick(1:10,:);
    rawPSTH(i,:,:) = analyzedData.rawPSTH(1:10,:);
    %
end
%%
auROCvalue = rocPSTH(:,[1 2 7 4 9],:);
auROCvalue = permute(auROCvalue,[2 1 3]);
cueResponse = nanmean(squeeze(rocPSTH(:,1,11:30)),2);
[~,plotorder] = sort(cueResponse);



figure('Position',[200 200 1000 787]);
subplot(1,6,1)
b = zeros(length(AAVlight),4);
b(AAVlight(plotorder),4) = 0.97;
b(rabieslight(plotorder),4) = 0.5;

imagesc(1-b,[0 1])
colormap(gca,'jet') 

axis off
titleText = {'90% reward','50% reward','no reward','Airpuff','free Reward'};

for j = 1:5
    subplot(1,6,j+1)
    plotValue = squeeze(auROCvalue(j,:,:));
    hold on;
    imagesc(plotValue(plotorder,:),[0 1]);
    colormap yellowblue
    axis(gca,'tight','ij');
    set(gca,'XTick',[10.5:10:50],'XTickLabel',{'0','1','2','3'})
    ylabel('Neuron'); xlabel('Time (s)');
    title(titleText{j});
end

%% Principle component analysis
proc = permute (rocPSTH(:,[1 2 7],10:40), [1,3,2]);
N = length(fl);
temp = squeeze(reshape(proc,N,1,[]));
[eigvect,proj,eigval] = princomp(temp);
nPC = 4;
PCs = eigvect(:,1:nPC);
PCs = reshape(PCs,[],3,nPC);
colorset= [  0 	0 	255;%blue  
             30 	144 	255;%light blue  
             128 	128 128;]/255; % grey
figure;
for i = 1:nPC
    subplot(1,nPC,i)
    for j = 1:3
        plot(squeeze(PCs(:,j,i)),'color',colorset(j,:))
        hold on;
    end
    %set(gca,'xtick',[1:10:30],'xticklabel',{'0','1','2'})
    title(sprintf('PC %d var: %0.1f%%', i,100*eigval(i)/sum(eigval)))
    xlabel('Time - odor (s)')
end

% project neurons to first 3 PCs
figure;
subplot(2,1,1)
scatter(proj(:,1),proj(:,2),'k')
hold on;
scatter(proj(AAVlight,1),proj(AAVlight,2),'Facecolor','b')
scatter(proj(rabieslight,1),proj(rabieslight,2),'Facecolor','r')
xlabel('PC1');ylabel('PC2');vline(0);hline(0);legend('all','AAV','rabies')


subplot(2,1,2)
scatter(proj(:,1),proj(:,3),'k')
hold on;
scatter(proj(AAVlight,1),proj(AAVlight,3),'Facecolor','b')
scatter(proj(rabieslight,1),proj(rabieslight,3),'Facecolor','r')
xlabel('PC1');ylabel('PC3');vline(0);hline(0);legend('all','AAV','rabies')
%%
% plot PC histogram
bins = -3:0.2:3;
figure;
PCid = 2;
p(:,1) = hist(proj(:,PCid),bins)/N;
m(:,1) = median(proj(:,PCid));
p(:,2) = hist(proj(AAVlight,PCid),bins)/sum(AAVlight);
m(:,2) = median(proj(AAVlight,PCid));
p(:,3) = hist(proj(rabieslight,PCid),bins)/sum(rabieslight);
m(:,3) = median(proj(rabieslight,PCid));

titles = {'all','AAV','rabies'};
for i = 1:3
    subplot(3,1,i)
    bar(bins,p(:,i))
    hold on; vline(m(i))
    title(titles{i})
    xlabel(['PC' num2str(PCid)])
    ylabel('prob.')
    xlim([-2 2])
end
% joint histogram PC1 and PC2
%%
edges{1} = -3:0.2:3;
edges{2} = -2:0.2:2;
figure;
subplot(2,2,1)
n1 = hist3(proj(:,[1,2]),'Edges',edges)/N;
imagesc('XData',edges{1},'YData',edges{2},'CData',n1,[0 0.12])
colormap(hot);xlim([-3 3]);ylim([-2 2])
xlabel('PC1');ylabel('PC2');title('all')
subplot(2,2,2)
n1 = hist3(proj(AAVlight,[1,2]),'Edges',edges)/sum(AAVlight);
imagesc('XData',edges{1},'YData',edges{2},'CData',n1,[0 0.12])
colormap(hot);xlim([-3 3]);ylim([-2 2])
xlabel('PC1');ylabel('PC2');title('AAV')
subplot(2,2,3)
n1 = hist3(proj(rabieslight,[1,2]),'Edges',edges)/sum(rabieslight);
imagesc('XData',edges{1},'YData',edges{2},'CData',n1,[0 0.12])
colormap(hot);xlim([-3 3]);ylim([-2 2])
xlabel('PC1');ylabel('PC2');title('rabeis')


%% plot pure reward, mixed and pure expectation
Tus.pureReward = Tus.sig50Rvs50OM&(~Tus.sigExp)&(~Tus.sig50OM);
Tus.pureExp = Tus.sig90Reward&(~Tus.sig50Rvs50OM)&Tus.EXPsign;
Tus.RPE = Tus.sig50R&Tus.sigExp&Tus.RPEsign;
Tus.pureRewardWithCue = Tus.pureReward&(TCS.sig90vsbslong>0.05)&(TCS.sig50vsbslong>0.05);

Tus.pureExpDir = double(Tus.sig90Reward&(~Tus.sig50Rvs50OM)).*Tus.EXPsign;
Tus.pureRPEDir = double(Tus.sig50R&(~Tus.sigExp)).*Tus.RPEsign;
Tus.mixed = Tus.sig50Rvs50OM&(~Tus.pureReward)&(~Tus.RPE);
Tus.other = (~Tus.sig50Rvs50OM)&(~Tus.pureExp);

Tus.RPE = Tus.sig50R&Tus.sigExp&Tus.RPEsign;
Tus.RPEsign = Tus.RPEsign.*Tus.RPE;
Tus.RPEsign(Tus.RPEsign==2) = -1;
RewardRPE = Tus.RPE;
CSposNegRPE = double((Tus.RPEsign.*TCS.csValue >0)&(Tus.OM50sign.*TCS.csValue >0));
CSposRPE = double(Tus.RPEsign.*TCS.csValue >0);
JoinedRPE = table(CSposRPE,CSposNegRPE,RewardRPE);
%%
groups = {true(length(fl),1), rabieslight,AAVlight, rabieslightL,AAVlightL};
groupTitles = {'All neurons','InputsS','VGlut2S','Inputs','VGlut2'};

r = Tus{:,{'pureRewardWithCue','pureReward','pureExp','mixed'}};
bardata = zeros(length(groups),4);
for i = 1:length(groups)
    bardata(i,:) = mean(r(groups{i},:));
end
figure;
bar(bardata')
set(gca,'xticklabel',{'pureRewardNoCue','pureReward','pureExp','mixed'})
legend(groupTitles)
prettyP('','','','','a')

r = JoinedRPE{:,{'RewardRPE','CSposRPE','CSposNegRPE'}};
bardata = zeros(length(groups),3);
for i = 1:length(groups)
    bardata(i,:) = mean(r(groups{i},:));
end
figure;
bar(bardata')
set(gca,'xticklabel',{'reward RPE','reward+CS RPE','complete'})
legend(groupTitles)
prettyP('','','','','a')

%%
% early CS value
r = TCS.csValue;
bardata = zeros(length(groups),3);
for i = 1:length(groups)
    bardata(i,1) = mean(r(groups{i})==1);
    bardata(i,2) = mean(r(groups{i})==-1);
end
figure;
bar(bardata,'stacked')
set(gca,'xticklabel',groupTitles)
legend({'Cue Pos','Cue Neg'})
ylim([0 1])
prettyP('','','','','a')

%% plot mean psth response for each group
for i = 1:length(groups)
    ax = plotAveragePSTH_analyzed_filelist(fl(groups{i}));
    title(groupTitles{i})
    set(ax(1),'ylim',[0 30])
    set(ax(2),'ylim',[0 30])
end

%% time course value coding before reward
for i = 1:length(fl)
    load(fl{i},'newCodingResults')
    if ~exist('newCodingResults','var')
        newCodingResults = CompuateValueRelatedResponseNew(fl{i},1);
    end
    CSvalue(i,:) = newCodingResults(1,[1 2 3]);
    CSdir(i,:) = newCodingResults(2,[1 2 3]);
    clear newCodingResults
end

% plot percent of neurons showing sig value coding before reward
figure;
xvalues = {'CS','Early delay','Late delay'};
for i = 1:length(groups)
    valueKeys = {'csValue','EarlydelayValue','delayValue'};
    r = CSdir{groups{i},valueKeys};
    bardata = zeros(3,2);
    bardata(:,1) =  mean(r==1);
    bardata(:,2) =  mean(r==-1);
    subplot(2,3,i)
    bar(bardata,'stacked')
    set(gca,'xticklabel',xvalues)
    title(groupTitles{i})
    legend({'Cue Pos','Cue Neg'})
    ylim([0 1])
    prettyP('','','','','a')
end

% figure;
% for i = 1:length(groups)
%     valueKeys = {'csValue','EarlydelayValue','delayValue'};
%     r = CSdir{groups{i},valueKeys};
%     bardata = [];
%     bardata(1) =  mean((r(:,1)==1)); % first positive
%     bardata(2) =  mean((r(:,1)==1)& (r(:,2)==1)); % stay positive
%     bardata(3) =  mean((r(:,1)==1)& (r(:,2)==-1)); % becomes negative
% 
%     subplot(1,5,i)
%     bar(bardata)
%     set(gca,'xticklabel',{'Pos first','stay Pos','Pos to Neg'})
%     title(groupTitles{i})
%     %legend({'All Pos','Pos to Neg'})
%     ylim([0 1])
%     prettyP('','','','','a')
% end


%% plot baseline
bl = squeeze(mean(rawPSTH(:,1,1:1000),3));
edge = 0:2:70;
figure;
histogram(bl(groups{2}),edge, 'Normalization','probability')
xlabel('Spikes/s')
title('inputS baseline')

figure;
histogram(bl(groups{3}),edge, 'Normalization','probability')
xlabel('Spikes/s')
title('vGlut2S baseline')

ranksum(bl(groups{2}),bl(groups{3}))

figure;
histogram(bl(groups{1}),edge, 'Normalization','probability')
xlabel('Spikes/s')
title('All units baseline')
%% population ROC plots with different baseline range
titleText = {'50% reward','omission 50% reward'};
plotdata = rocPSTH(:,[2 6],:);
figure;
for j = 1:2
    subplot(1,2,j)
    plotValue = squeeze(plotdata(groups{3}&bl<10,j,:));
    if j==1
        [~,plotorder] = sort(sum(plotValue(:,11:20),2));
    end
    hold on;
    imagesc(plotValue(plotorder,:),[0 1]); %
    colormap yellowblue
    axis(gca,'tight','ij');
    set(gca,'XTick',[10.5:10:50],'XTickLabel',{'0','1','2','3'})
    ylabel('Neuron'); xlabel('Time (s)');
    title(titleText{j});
end
%% the following block of code is adapted from AllLightPopAnalysisAirpuffRewardCSNew

% CS analysis
direRCS = RCSvalue;
direRCS(direRCS==-1) = 0;
tempIdx = [];
tempIdx(:,1) = RCSvalue&sigACS&(direACS==direRCS); %RewadPuffSame
tempIdx(:,2) = RCSvalue&sigACS&(direACS~=direRCS); % RewardPuffOppo
tempIdx(:,3) = RCSvalue&(~sigACS); %rewardOnly
tempIdx(:,4) = (~sigRCS)&(~sigR50CS')&sigACS; %puffOnly
tempIdx(:,5) = (sigACS|sigRCS|sigR50CS')&(~(tempIdx(:,1)|tempIdx(:,2)...
    |tempIdx(:,3)|tempIdx(:,4))); %others

%
figure;
titleText = {'Salience','Value','RewardOnly','PuffOnly','Other'};

for i = 1:5
    subplot(2,3,i)
    gm = groupedmean(tempIdx(:,i), groups);
    barh(gm); set(gca,'ytickLabel',groupTitles);xlim([0 1])
    title(titleText{i})
end

figure;
res = [];
plotdata  = [];
for i = 1:length(groups)
    subplot(2,3,i)
    res(:,1,1) = tempIdx(:,1)&direRCS==1;
    res(:,1,2) = tempIdx(:,1)&direRCS==0;
    res(:,2,1) = tempIdx(:,2)&direRCS==1;
    res(:,2,2) = tempIdx(:,2)&direRCS==0;
    res(:,3,1) = tempIdx(:,3)&direRCS==1;
    res(:,3,2) = tempIdx(:,3)&direRCS==0;
    res(:,4,1) = tempIdx(:,4)&direACS==1;
    res(:,4,2) = tempIdx(:,4)&direACS==0;
    plotdata(i,:,:) = squeeze(mean(res(groups{i},:,:)))';
    bar(squeeze(mean(res(groups{i},:,:))),'stacked');
    legend('pos','neg')
    title(groupTitles{i});ylim([0 1]);xlim([0 5])
    set(gca,'xtickLabel',titleText)
end

figure;
for i = 1:4
    subplot(2,2,i)
    barh(squeeze(plotdata(:,:,i)))
    set(gca,'yticklabel',groupTitles);xlim([0 1])
    title(titleText{i})
end

% plot latency
ind = find(RCSvalue==1);
bin = 0:20:500;
figure;
for i = 1:5
    tempG{i} = groups{i}(ind);
end
plotHistByGroup_cellarray(Rcslatency(ind),bin,tempG,groupTitles)
% among all RCSvalue neurons, 96.1% have latency smaller than 500
sum(Rcslatency(ind)<500)/length(ind)
% among all non RCSvalue neurons, 42.0% have latency smaller than 500
sum(Rcslatency(~RCSvalue)<500)/sum(~RCSvalue)



% figure;
% ind = find(sigACS&(direACS==0)); % &(direACS==0)
% plotHistByGroup(Acslatency(ind),bin,G(ind),plotAreas)
% 
% sum(Acslatency(ind)<500)/length(ind)

%% the following code is adapted from AllLightPopAnalysisAirpuffRewardUSNew
sigReward = WaterVsBefore&WaterVsNothing;
sigPuff = PuffVsBefore&PuffVsNothing;

tempIdx = [];
tempIdx(:,1) = sigReward&sigPuff&(direAUS==direRUS); %RewadPuffSame
tempIdx(:,2) = sigReward&sigPuff&(direAUS~=direRUS); % RewardPuffOppo
tempIdx(:,3) = sigReward&(~sigPuff); %rewardOnly
tempIdx(:,4) = (~sigReward)&sigPuff; %puffOnly
figure;
titleText = {'salience','Value','RewardOnly','PuffOnly'};

for i = 1:4
    subplot(2,2,i)
    barh(groupedmean(tempIdx(:,i),groups)); set(gca,'ytickLabel',groupTitles);xlim([0 1])
    title(titleText{i})
end

figure;
res = [];
for i = 1:length(groups)
    subplot(2,3,i)
    res(:,1,1) = tempIdx(:,1)&direRUS==1;
    res(:,1,2) = tempIdx(:,1)&direRUS==0;
    res(:,2,1) = tempIdx(:,2)&direRUS==1;
    res(:,2,2) = tempIdx(:,2)&direRUS==0;
    res(:,3,1) = tempIdx(:,3)&direRUS==1;
    res(:,3,2) = tempIdx(:,3)&direRUS==0;
    res(:,4,1) = tempIdx(:,4)&direAUS==1;
    res(:,4,2) = tempIdx(:,4)&direAUS==0;
    plotdata(i,:,:) = squeeze(mean(res(groups{i},:,:)))';
    bar(squeeze(mean(res(groups{i},:,:))),'stacked');
    legend('pos','neg')
    title(groupTitles{i});ylim([0 1]);xlim([0 5])
    set(gca,'xtickLabel',titleText)
end

figure;
for i = 1:4
    subplot(2,2,i)
    barh(squeeze(plotdata(:,:,i)))
    set(gca,'yticklabel',groupTitles);xlim([0 1])
    title(titleText{i})
end


tempIdx = [];
tempIdx(:,1) = sigReward&(direRUS==1); % reward pos
tempIdx(:,2) = sigReward&(direRUS==0); % reward neg
tempIdx(:,3) = sigPuff&(direAUS==1); % airpuff pos
tempIdx(:,4) = sigPuff&(direAUS==0); % airpuff neg
figure;
titleText = {'reward pos','reward neg','airpuff pos','airpuff neg'};

[G,areaName]=grp2idx(brainArea);
for i = 1:4
    subplot(2,2,i)
    barh(grpstats(tempIdx(:,i),G')); set(gca,'ytickLabel',areaName);xlim([0 1])
    title(titleText{i})
end
%%
puffNans = find(isnan(freePuff));
waterNans = find(isnan (freeWater));
notNans = find((~isnan(freePuff))&(~isnan(freeWater)));
sigReward = freeWater(notNans);
sigPuff = freePuff(notNans);
dirFreePuff = dirFreePuff(notNans)';
dirFreeWater = dirFreeWater(notNans)';

%%
tempIdx = [];
tempIdx(:,1) = sigReward&sigPuff&(dirFreePuff==dirFreeWater); %RewadPuffSame
tempIdx(:,2) = sigReward&sigPuff&(dirFreePuff~=dirFreeWater); % RewardPuffOppo
tempIdx(:,3) = sigReward&(~sigPuff); %rewardOnly
tempIdx(:,4) = (~sigReward)&sigPuff; %puffOnly
figure;
titleText = {'salience','Value','RewardOnly','PuffOnly'};
for i = 1:5
    tempG{i} = groups{i}(notNans);
end
for i = 1:4
    subplot(2,2,i)
    barh(groupedmean(tempIdx(:,i),tempG)); set(gca,'ytickLabel',groupTitles);xlim([0 1])
    title(titleText{i})
end

figure;
res = [];
for i = 1:length(tempG)
    subplot(2,3,i)
    res(:,1,1) = tempIdx(:,1)&dirFreeWater==1;
    res(:,1,2) = tempIdx(:,1)&dirFreeWater==0;
    res(:,2,1) = tempIdx(:,2)&dirFreeWater==1;
    res(:,2,2) = tempIdx(:,2)&dirFreeWater==0;
    res(:,3,1) = tempIdx(:,3)&dirFreeWater==1;
    res(:,3,2) = tempIdx(:,3)&dirFreeWater==0;
    res(:,4,1) = tempIdx(:,4)&dirFreePuff==1;
    res(:,4,2) = tempIdx(:,4)&dirFreePuff==0;
    plotdata(i,:,:) = squeeze(mean(res(tempG{i},:,:)))';
    bar(squeeze(mean(res(tempG{i},:,:))),'stacked');
    legend('pos','neg')
    title(groupTitles{i});ylim([0 1]);xlim([0 5])
    set(gca,'xtickLabel',titleText)
end
figure;
for i = 1:4
    subplot(2,2,i)
    barh(squeeze(plotdata(:,:,i)))
    set(gca,'yticklabel',groupTitles);xlim([0 1])
    title(titleText{i})
end

freeWaterResponse = squeeze(mean(rawPSTH(:,9,3001:3500),3))-squeeze(mean(rawPSTH(:,9,2501:3000),3));
freePuffResponse = squeeze(mean(rawPSTH(:,10,3001:3500),3))-squeeze(mean(rawPSTH(:,10,2501:3001),3));
figure;
i = 3;
scatter(freeWaterResponse(groups{i}),freePuffResponse(groups{i}))
hold on; vline(0);hline(0)
xlabel('free water');ylabel('free puff');title(groupTitles{i})

