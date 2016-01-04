fl = what(pwd);
fl = fl.mat;
for i = 1:length(fl)
    a = load(fl{i},'area');
    brainArea{i} = a.area;
end
%% remove VTA rabies units
VTAind = ismember(brainArea,{'rVTA Type2','r VTA Type3','rdopamine'});
fl = fl(~VTAind);
N = length(fl);
clear brainArea
%%
sigPuff = [];
sigRCS = zeros(N,1);
direRCS = zeros(N,1);
sigACS = zeros(N,1);
direACS = zeros(N,1);
RCSvalue = zeros(N,1);
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
    % comopute airpuff response
    rs = analyzedData.raster;
    urs = rs([4 7]); 
    % extract US response (subtract by iti baseline)
    TimeWin = 1:500;
    US_spikes = cellfun( @(x)1000*mean(x(:,TimeWin+3000),2),urs,'UniformOutput',0);
    [~,sigPuff(i)] = ranksum(US_spikes{1}, US_spikes{2}); 
    direPuff(i) = mean(US_spikes{1}) > mean(US_spikes{2});
    
    ucs = rs([11 13 14 12]);
    CS_spikes = cellfun( @(x)1000*mean(x(:,TimeWin+1000),2)-1000*mean(x(:,1001-TimeWin),2),ucs,'UniformOutput',0);
    [~,sigRCS(i)] = ranksum(CS_spikes{1}, CS_spikes{2}); 
    direRCS(i) = mean(CS_spikes{1}) > mean(CS_spikes{2});
    [~,sigACS(i)] = ranksum(CS_spikes{3}, CS_spikes{2}); 
    direACS(i) = mean(CS_spikes{3}) > mean(CS_spikes{2}); 
    
    [~,sigR50CS(i)] = ranksum(CS_spikes{4}, CS_spikes{2}); 

    load(fl{i},'CS')
    RCSvalue(i) = CS.csValue;
end
direPuff = direPuff';
sigPuff = sigPuff';
%%
brainArea(ismember(brainArea,{'LH_an','LH_psth','LH_po'})) = {'LH'};
brainArea(ismember(brainArea,{'PPTg_an','PPTg'})) = {'PPTg'};

% change  the name of brain areas
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

ind = ismember(brainArea,{'Dopamine','VTA type3',...
    'VTA type2'});
brainArea(ind) = {'VTA'};

% reward responsive units
sigReward = Tus.sig50Rvs50OM & Tus.sig50R;
direReward = Tus.Rewardsign;% 1, >0 else 0

%% US analysis
tempIdx = [];
tempIdx(:,1) = sigReward&sigPuff&(direPuff==direReward); %RewadPuffSame
tempIdx(:,2) = sigReward&sigPuff&(direPuff~=direReward); % RewardPuffOppo
tempIdx(:,3) = sigReward&(~sigPuff); %rewardOnly
tempIdx(:,4) = (~Tus.sig50Rvs50OM)&(~Tus.sig50R)&sigPuff; %puffOnly
figure;
titleText = {'Saliency','Value','RewardOnly','PuffOnly'};

[G,areaName]=grp2idx(brainArea);
for i = 1:4
    subplot(2,2,i)
    barh(grpstats(tempIdx(:,i),G')); set(gca,'ytickLabel',areaName);xlim([0 1])
    title(titleText{i})
end

figure;
for i = 1:length(areaName)
    subplot(3,3,i)
    res(:,1,1) = tempIdx(:,1)&direReward==1;
    res(:,1,2) = tempIdx(:,1)&direReward==0;
    res(:,2,1) = tempIdx(:,2)&direReward==1;
    res(:,2,2) = tempIdx(:,2)&direReward==0;
    res(:,3,1) = tempIdx(:,3)&direReward==1;
    res(:,3,2) = tempIdx(:,3)&direReward==0;
    res(:,4,1) = tempIdx(:,4)&direPuff==1;
    res(:,4,2) = tempIdx(:,4)&direPuff==0;
    bar(squeeze(mean(res(G==i,:,:))),'stacked');
    legend('pos','neg')
    title(areaName{i});ylim([0 1]);xlim([0 5])
    set(gca,'xtickLabel',titleText)
end


tempIdx = [];
tempIdx(:,1) = sigReward&(direReward==1); % reward pos
tempIdx(:,2) = sigReward&(direReward==0); % reward neg
tempIdx(:,3) = sigPuff&(direPuff==1); % airpuff pos
tempIdx(:,4) = sigPuff&(direPuff==0); % airpuff neg
figure;
titleText = {'reward pos','reward neg','airpuff pos','airpuff neg'};

[G,areaName]=grp2idx(brainArea);
for i = 1:4
    subplot(2,2,i)
    barh(grpstats(tempIdx(:,i),G')); set(gca,'ytickLabel',areaName);xlim([0 1])
    title(titleText{i})
end
%% CS analysis
tempIdx = [];
tempIdx(:,1) = sigRCS&sigACS&(direACS==direRCS); %RewadPuffSame
tempIdx(:,2) = sigRCS&sigACS&(direACS~=direRCS); % RewardPuffOppo
tempIdx(:,3) = sigRCS&(~sigACS); %rewardOnly
tempIdx(:,4) = (~sigRCS)&(~sigR50CS')&sigACS; %puffOnly

direRCS = RCSvalue;
direRCS(direRCS==-1) = 0;
tempIdx = [];
tempIdx(:,1) = RCSvalue&sigACS&(direACS==direRCS); %RewadPuffSame
tempIdx(:,2) = RCSvalue&sigACS&(direACS~=direRCS); % RewardPuffOppo
tempIdx(:,3) = RCSvalue&(~sigACS); %rewardOnly
tempIdx(:,4) = (~sigRCS)&(~sigR50CS')&sigACS; %puffOnly

%%
figure;
titleText = {'Saliency','Value','RewardOnly','PuffOnly'};

[G,areaName]=grp2idx(brainArea);
for i = 1:4
    subplot(2,2,i)
    barh(grpstats(tempIdx(:,i),G')); set(gca,'ytickLabel',areaName);xlim([0 1])
    title(titleText{i})
end

figure;
res = [];
for i = 1:length(areaName)
    subplot(3,3,i)
    res(:,1,1) = tempIdx(:,1)&direRCS==1;
    res(:,1,2) = tempIdx(:,1)&direRCS==0;
    res(:,2,1) = tempIdx(:,2)&direRCS==1;
    res(:,2,2) = tempIdx(:,2)&direRCS==0;
    res(:,3,1) = tempIdx(:,3)&direRCS==1;
    res(:,3,2) = tempIdx(:,3)&direRCS==0;
    res(:,4,1) = tempIdx(:,4)&direACS==1;
    res(:,4,2) = tempIdx(:,4)&direACS==0;
    bar(squeeze(mean(res(G==i,:,:))),'stacked');
    legend('pos','neg')
    title(areaName{i});ylim([0 1]);xlim([0 5])
    set(gca,'xtickLabel',titleText)
end

tempIdx = [];
tempIdx(:,1) = RCSvalue&(direRCS==1); % reward pos
tempIdx(:,2) = RCSvalue&(direRCS==0); % reward neg
tempIdx(:,3) = sigACS&(direACS==1); % airpuff pos
tempIdx(:,4) = sigACS&(direACS==0); % airpuff neg
figure;
titleText = {'reward pos','reward neg','airpuff pos','airpuff neg'};

[G,areaName]=grp2idx(brainArea);
for i = 1:4
    subplot(2,2,i)
    barh(grpstats(tempIdx(:,i),G')); set(gca,'ytickLabel',areaName);xlim([0 1])
    title(titleText{i})
end
%%
puffOMlen = [];
pufflen = [];
for i = 1:length(fl)
    load(fl{i},'analyzedData')
    puffOMlen(i) = size(analyzedData.raster{8},1);
    pufflen(i) = size(analyzedData.raster{4},1);
end
%% 
for i = 1:length(fl)
    brainArea{i} = a.area;
    load(fl{i}, 'analyzedData')
    if ~exist('analyzedData', 'var')
        analyzedData = getPSTHSingleUnit(fl{i}); 
        save(fl{i},'-append','analyzedData')
    end
    % comopute airpuff response
    rs = analyzedData.raster;
    urs = rs([4 7]); 
    % compute airpuff delay response
    TimeWin = 1:500;
    US_spikes_delay = cellfun( @(x)1000*mean(x(:,TimeWin+2500),2),urs,'UniformOutput',0);
    [~,sigDelayPuff(i)] = ranksum(US_spikes_delay{1}, US_spikes_delay{2}); 
    % compute airpuff and omission response
    urs = rs([4 7 8]); 
    US_spikes = cellfun( @(x)1000*mean(x(:,TimeWin+3000),2),urs,'UniformOutput',0);
    [~,sigPuff(i)] = ranksum(US_spikes{1}, US_spikes{2}); 
    % 2) compare puff vs delay, sig different
    [~,sigPuffvsDelay(i)] = signrank(US_spikes{1}, US_spikes_delay{1}); 
    if ~isempty(US_spikes{3})
        [~,sigPuffOM(i)] = ranksum(US_spikes{3}, US_spikes{1});
        [~,sigPuffOMvsNothing(i)] = ranksum(US_spikes{2}, US_spikes{3});        
    else
        sigPuffOM(i) = 0;
        sigPuffOMvsNothing(i) = 0;
    end
end
%% evaluate marginally airpuff expectation response: 1) delay time response 2) omission response
n(1) = sum(sigPuff&sigPuffOMvsNothing);
n(2) = sum(sigPuff&~sigPuffOMvsNothing);
n(3) = sum(~sigPuff&sigPuffOMvsNothing);
figure;
bar(n)
set(gca,'xticklabel',{'US and delay','US but not delay','no US only delay'})
ylabel('# neuron')
%% use different way to compute airpuff response: 1) compare puff vs om, om not different from delay
n(1) = sum(sigPuff&sigPuffvsDelay);
n(2) = sum(sigPuff&~sigPuffvsDelay);
n(3) = sum(~sigPuff&sigPuffvsDelay);
figure;
bar(n)
set(gca,'xticklabel',{'cond1','cond2','cond3'})
ylabel('# neuron')
prettyP('','','','','a')
%   A0, A   Desired and actual circle areas
%               A = [A1 A2] or [A1 A2 A3]
%   I0, I   Desired and actual intersection areas
%               I = I12 or [I12 I13 I23 I123]
A = [sum(sigPuff) sum(sigPuffvsDelay) sum(sigPuffOM)];
I = [sum(sigPuff&sigPuffvsDelay) sum(sigPuff&sigPuffOM) ...
    sum(sigPuffvsDelay&sigPuffOM) sum(sigPuff&sigPuffvsDelay&sigPuffOM)];
figure; venn(A,I)
legend('puff us vs nothing us','puff us vs delay puff','puff us vs omission')

A = [sum(sigPuff) sum(sigPuffvsDelay) sum(sigPuffOMvsNothing)];
I = [sum(sigPuff&sigPuffvsDelay) sum(sigPuff&sigPuffOMvsNothing) ...
    sum(sigPuffvsDelay&sigPuffOMvsNothing) sum(sigPuff&sigPuffvsDelay&sigPuffOMvsNothing)];
figure; venn(A,I)
legend('puff us vs nothing us','puff us vs delay puff','puff us vs omission')
%%
for i = 1:length(fl)
    a = load(fl{i},'area');
    brainArea{i} = a.area;
    load(fl{i}, 'analyzedData')
    puff = analyzedData.raster{4};
    puffom = analyzedData.raster{8};
    nothing = analyzedData.raster{7};
    pretrigger = 1000;
    posttrigger = 4000;
    rocBin = 100;
    binNum = (pretrigger + posttrigger)/rocBin;
    for k = 1:binNum
        p = sum(puff(:,rocBin*(k-1)+1:rocBin*k),2);
        o = sum(puffom(:,rocBin*(k-1)+1:rocBin*k),2);
        n = sum(nothing(:,rocBin*(k-1)+1:rocBin*k),2);
        try 
            puff_nothing_roc(i,k) = auROC(p,n);
            puff_om_roc(i,k) = auROC(p,o);
            puffom_nothing_roc(i,k) = auROC(o,n);
        catch
            puff_nothing_roc(i,k) = nan;
            puff_om_roc(i,k) = nan;
            puffom_nothing_roc(i,k) = nan;
        end
    end 
    puffbl(i,:) = analyzedData.rocPSTH(4,:);
    puffombl(i,:) = analyzedData.rocPSTH(8,:);
    nothingbl(i,:) = analyzedData.rocPSTH(7,:);
end
%%
orderAreas = {'Dopamine','VTA type2','VTA type3','PPTg','RMTg','Subthalamic',...
    'Lateral hypothalamus','Ventral pallidum','Dorsal striatum','Ventral striatum'
    };
orderAreasNames = {'Dopamine','VTA type2','VTA type3','PPTg','RMTg','Subthalamic',...
    'Lateral hypothalamus','Ventral pallidum','Dorsal striatum','Ventral striatum'
    };

oldbrain = brainArea;
grp = nan(1,length(brainArea));
for i = 1:length(orderAreas)
    idx = ismember(brainArea,orderAreas{i});
    grp(idx) = i;
end
[~,plot_order] = sort(grp);
clustlines = nan(3,length(unique(grp))-1);
for i = 1:10-1
    temp = sum(grp<=i) + 0.5;
    clustlines(1:2,i) = [temp;temp];
end
clustlines = clustlines(:); %now verticalize


figure;
data_plot = {puffbl,puffombl,nothingbl};
titleTexts = {'airpuff','airpuff omission','nothing'};
for i = 1:3
    subplot(1,3,i)
    imagesc(data_plot{i}(plot_order,:),[0 1]);
    xlines = cat(1,repmat(xlim',[1,10-1]), nan(1,10-1));
    xlines = xlines(:);
    hold on;plot(xlines,clustlines,'r');
    colormap yellowblue
    axis(gca,'tight','ij');
    set(gca,'XTick',[10.5:10:50],'XTickLabel',{'0','1','2','3'})
    ylabel('Neuron'); xlabel('Time (s)');
    title(titleTexts{i});
    set(gca,'Box','off','TickDir','out','TickLength',[0.02 0.025])
end

figure;
data_plot = {puff_om_roc, puff_nothing_roc,puffom_nothing_roc};
titleTexts = {'airpuff vs airpuff omission','airpuff vs nothing','airpuff omission vs nothing'};
for i = 1:3
    subplot(1,3,i)
    imagesc(data_plot{i}(plot_order,:),[0 1]);
    xlines = cat(1,repmat(xlim',[1,10-1]), nan(1,10-1));
    xlines = xlines(:);
    hold on;plot(xlines,clustlines,'r');
    colormap yellowblue
    axis(gca,'tight','ij');
    set(gca,'XTick',[10.5:10:50],'XTickLabel',{'0','1','2','3'})
    ylabel('Neuron'); xlabel('Time (s)');
    title(titleTexts{i});
    set(gca,'Box','off','TickDir','out','TickLength',[0.02 0.025])
end