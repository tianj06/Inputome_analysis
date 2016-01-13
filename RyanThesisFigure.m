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
groups = {1:length(fl), rabieslight,AAVlight, rabieslightL,AAVlightL};
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

%% plot mean response
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

%%
figure;
for i = 1:length(groups)
    valueKeys = {'csValue','EarlydelayValue','delayValue'};
    r = CSdir{groups{i},valueKeys};
    bardata = zeros(3,2);
    bardata(:,1) =  mean(r==1);
    bardata(:,2) =  mean(r==-1);
    subplot(2,3,i)
    bar(bardata,'stacked')
    set(gca,'xticklabel',valueKeys)
    title(groupTitles{i})
    legend({'Cue Pos','Cue Neg'})
    ylim([0 1])
    prettyP('','','','','a')
end

figure;
for i = 1:length(groups)
    valueKeys = {'csValue','EarlydelayValue','delayValue'};
    r = CSdir{groups{i},valueKeys};
    bardata = [];
    bardata(1) =  mean((r(:,1)==1)); % first positive
    bardata(2) =  mean((r(:,1)==1)& (r(:,2)==1)); % stay positive
    bardata(3) =  mean((r(:,1)==1)& (r(:,2)==-1)); % becomes negative

    subplot(1,5,i)
    bar(bardata)
    set(gca,'xticklabel',{'Pos first','stay Pos','Pos to Neg'})
    title(groupTitles{i})
    %legend({'All Pos','Pos to Neg'})
    ylim([0 1])
    prettyP('','','','','a')
end

