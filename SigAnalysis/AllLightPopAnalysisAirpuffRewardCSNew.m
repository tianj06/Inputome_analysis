fl = what(pwd);
fl = fl.mat;
for i = 1:length(fl)
    a = load(fl{i},'area');
    brainArea{i} = a.area;
end
%% remove VTA rabies units
VTAind = ismember(brainArea,{'rVTA Type2','r VTA Type3'}); %,'rdopamine'
fl = fl(~VTAind);
N = length(fl);
clear brainArea
%%
sigRCS = zeros(N,1);
direRCS = zeros(N,1);
sigACS = zeros(N,1);
direACS = zeros(N,1);
RCSvalue = zeros(N,1);
TimeWin = 1:500;
resOffset = 1000;
bin = 50;
step = 5;
N_step = 500/step;
Rcslatency = zeros(N,1);
Acslatency = zeros(N,1);
Al = zeros(N,1);
Rl = zeros(N,1);

for i = 1:length(fl)
    if rem(i,100)==0
        disp(sprintf('%0.2f%%',100*i/length(fl)))
    end
%     a = load(fl{i},'area');
%     brainArea{i} = a.area;
    load(fl{i}, 'analyzedData')
    if ~exist('analyzedData', 'var')
        analyzedData = getPSTHSingleUnit(fl{i}); 
        save(fl{i},'-append','analyzedData')
    elseif length(analyzedData.raster)<14
        analyzedData = getPSTHSingleUnit(fl{i}); 
        save(fl{i},'-append','analyzedData')
    end
    rs = analyzedData.raster;
    ucs = rs([11 13 14 12]);
    CS_spikes = cellfun( @(x)1000*mean(x(:,TimeWin+1000),2)-1000*mean(x(:,1001-TimeWin),2),ucs,'UniformOutput',0);
    [~,sigRCS(i)] = ranksum(CS_spikes{1}, CS_spikes{2}); 
    direRCS(i) = mean(CS_spikes{1}) > mean(CS_spikes{2});
    [~,sigACS(i)] = ranksum(CS_spikes{3}, CS_spikes{2}); 
    direACS(i) = mean(CS_spikes{3}) > mean(CS_spikes{2}); 
    [~,sigR50CS(i)] = ranksum(CS_spikes{4}, CS_spikes{2}); 
    load(fl{i},'CS')
    RCSvalue(i) = CS.csValue;
    
        % compute reward CS latency
    r_temp = rs([11,13]);
    p_binWin = [];
    for k = 1:N_step
        tw = resOffset + (step*(k-1)+1:step*(k-1)+bin);
        rw = mean(r_temp{1}(:,tw),2);
        bw = mean(r_temp{2}(:,tw),2);
        p_binWin(k) = ranksum(rw,bw);
    end
    ind = strfind(p_binWin<0.05,[1 1 1 1 1]);
    if ~isempty(ind)
        Rcslatency(i) = (ind(1)-1)*step+25;
    else
        Rcslatency(i) = nan;
    end
    
    % compute airpuff CS latency
    r_temp = rs([14,13]);
    p_binWin = [];
    for k = 1:N_step
        tw = resOffset + (step*(k-1)+1:step*(k-1)+bin);
        rw = mean(r_temp{1}(:,tw),2);
        bw = mean(r_temp{2}(:,tw),2);
        p_binWin(k) = ranksum(rw,bw);
    end
    ind = strfind(p_binWin<0.05,[1 1 1 1 1]);
    if ~isempty(ind)
        Acslatency(i) = (ind(1)-1)*step+25;
    else
        Acslatency(i) = nan;
    end
    
    Rl(i) = freeUSlatency(rs{11},500,5,50,1000);
    Rl2(i) = freeUSlatency(rs{11},500,5,30,1000);

    Al(i) = freeUSlatency(rs{14},500,5,50,1000);
    Al2(i) = freeUSlatency(rs{14},500,5,30,1000);
end
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
% ind = ismember(brainArea,{'Dopamine','VTA type3',...
%     'VTA type2'});
% brainArea(ind) = {'VTA'};
%% CS analysis
direRCS = RCSvalue;
direRCS(direRCS==-1) = 0;
tempIdx = [];
tempIdx(:,1) = RCSvalue&sigACS&(direACS==direRCS); %RewadPuffSame
tempIdx(:,2) = RCSvalue&sigACS&(direACS~=direRCS); % RewardPuffOppo
tempIdx(:,3) = RCSvalue&(~sigACS); %rewardOnly
tempIdx(:,4) = (~sigRCS)&(~sigR50CS')&sigACS; %puffOnly
tempIdx(:,5) = (sigACS|sigRCS|sigR50CS')&(~(tempIdx(:,1)|tempIdx(:,2)...
    |tempIdx(:,3)|tempIdx(:,4))); %others

%%
figure;
titleText = {'Salience','Value','RewardOnly','PuffOnly','Other'};
plotAreas = {'Ventral striatum','Dorsal striatum','Ventral pallidum','Subthalamic',...
    'Lateral hypothalamus','RMTg','PPTg','VTA type3', 'VTA type2','Dopamine'}; % 
plotAreas = fliplr(plotAreas);
G = orderAreaGroup(brainArea, plotAreas);
for i = 1:5
    subplot(2,3,i)
    barh(grpstats(tempIdx(:,i),G')); set(gca,'ytickLabel',plotAreas);xlim([0 1])
    title(titleText{i})
end

figure;
res = [];
for i = 1:length(plotAreas)
    subplot(3,4,i)
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
    title(plotAreas{i});ylim([0 1]);xlim([0 5])
    set(gca,'xtickLabel',titleText)
end


figure;
for i = 1:4
    temp = squeeze(res(:,i,:));
    tempall = [];
    subplot(2,2,i)
    barh(grpstats(temp,G));set(gca,'ytickLabel',plotAreas);xlim([0 1])
    title(titleText{i})
end



tempIdx = [];
tempIdx(:,1) = RCSvalue&(direRCS==1); % reward pos
tempIdx(:,2) = RCSvalue&(direRCS==0); % reward neg
tempIdx(:,3) = sigACS&(direACS==1); % airpuff pos
tempIdx(:,4) = sigACS&(direACS==0); % airpuff neg
figure;
titleText = {'reward pos','reward neg','airpuff pos','airpuff neg'};

for i = 1:4
    subplot(2,2,i)
    barh(grpstats(tempIdx(:,i),G')); set(gca,'ytickLabel',plotAreas);xlim([0 1])
    title(titleText{i})
end

%% plot latency
plotAreas = {'Ventral striatum','Dorsal striatum','Ventral pallidum','Subthalamic',...
    'Lateral hypothalamus','RMTg','PPTg'}; % 'rdopamine',,'VTA type3', 'VTA type2','Dopamine'
%plotAreas = fliplr(plotAreas);

G = orderAreaGroup(brainArea, plotAreas);
%add free number o
ind = RCSvalue== 1;%  ;  sigACS&(direACS==0)
bin = [0:10:520 inf];
figure;
tempdata = Rcslatency;%Rcslatency
tempdata (~ind) = 10000;  
tempdata (isnan(tempdata)) = 5000; % set a big value so that those neurons
%are not shown in histogram calculation
plotHistByGroup(tempdata,bin,G,plotAreas,120)
% among all RCSvalue neurons, 96.1% have latency smaller than 500
sum(Rcslatency(ind)<500)/length(ind)
% among all non RCSvalue neurons, 42.0% have latency smaller than 500
sum(Rcslatency(~RCSvalue)<500)/sum(~RCSvalue)



figure;
ind = sigACS&(direACS==1); % &(direACS==0)
tempdata = Acslatency;
tempdata (isnan(tempdata)) = 10000; % set a big value so that those neurons
%are not shown in histogram calculation
tempdata (~ind) = 10000;  
plotHistByGroup(tempdata,bin,G,plotAreas)

sum(Acslatency(ind)<500)/length(ind)


figure;
ind = find(sigACS&(direACS==0));
bin = 0:10:500;
plotHistByGroup(Al2(ind),bin,G(ind),plotAreas)

%% plot input with CS responses that are faster than 140ms
for i = 1:8
    ind = G==i&Rcslatency<140&RCSvalue==1;
    if sum(ind)>0
        plot_pop_summary_fromAnalyzedPanel_USplus(fl(ind),savePath,'temp',3)
        title(plotAreas{i})
    end
end
