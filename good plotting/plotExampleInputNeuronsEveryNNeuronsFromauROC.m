fl = what(pwd);
fl = fl.mat;
%fl = getfiles_OnlyInOnePath (path1,path2);
%%
for i = 1:length(fl)
    a = load(fl{i},'area');
    brainArea{i} = a.area;
end
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
%%
inputAreaG = [1 5 6 7 8 9 13];
nfl = fl(ismember(G,inputAreaG));
nG = G(ismember(G,inputAreaG));
for i = 1:length(nfl)
    load(nfl{i},'analyzedData')
    rawpsth(i,:,:) = analyzedData.rawPSTH(1:10,:);
    rocvalue(i) = mean(analyzedData.rocPSTH(1,11:30));
end
areaCode = [6 1 9 13 5 8 7];
plotOdor = [];
areaPlotIndex = {};
plotAreaCode = [];
STEP = 5;

for area = areaCode
    nIdx = find(nG == area);
    % try to match the order in Figure 2c 
    [~,I] = sort(rocvalue(nIdx),'ascend');
    % if an area has more than 10 neurons, plot every five neurons
    % otherwise, plot every three neurons
    if length(I) > 10
        tempIdx = I(1:STEP:end);
        areaPlotIndex{area} = 1:STEP:length(I);
    else
        tempIdx = I(1:3:end);
        areaPlotIndex{area} = 1:3:length(I);
    end
    N = length(tempIdx);
    plotOdor = [plotOdor; nIdx(tempIdx)];
    plotAreaCode = [plotAreaCode; area*ones(N,1)];
end
%%
colorSet = [0 	0 	255;%blue  
                   30 	144 	255;%light blue  
                   128 	128 128; % grey
                    0 0 0]/255; % black;
plotTrialType = [1 2 7];
savepath = 'C:\Users\uchidalab\Dropbox (Uchida Lab)\lab\FunInputome\writing\Figures\';
figure('position',[560 251 981 697]);

psth = rawpsth(plotOdor,:,:);
nsubplot = 48;
n = 1;
for j = 1:nsubplot
    subplot(8,6,n);
    for k = 1:length(plotTrialType)
        binSize = 20;
        smoothBin = 300;
        trace = squeeze(psth(j,plotTrialType(k),:));
        bin_trace = mean(reshape(trace(1:5000),binSize,[]));
        x = linspace(-1,4,5000/binSize);
        y = smooth(bin_trace,smoothBin/binSize);
        plot(x(5:245),y(5:245),'color',colorSet(k,:)); hold on;
    end
    prettyP([-0.95 3.95],'',[0:3],'','a')
    set(gca,'xticklabel',[])
    title(areaName(plotAreaCode(j)))
    n = n+1;
end 
%saveas(gcf,[savepath plotAreas{i} '_panel_psth'])

%% plot circle in the auROC plots
figure;
for i = 1:length(areaCode)
    subplot(1,7,i)
    N = sum(nG==areaCode(i));
    ind = N-areaPlotIndex{areaCode(i)};
    plot(1,ind+0.5,'ko')
    xlim([0 20])
    ylim([0 N])
    box off
    set(gca,'TickDir','out')
end