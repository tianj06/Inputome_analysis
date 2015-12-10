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
nfl = fl(G==4);
for i = 1:length(nfl)
    load(nfl{i},'analyzedData')
    rawpsth(i,:,:) = analyzedData.rawPSTH(1:10,:);
    rocpsth(i,:,:) = analyzedData.rocPSTH(1:10,:);
 end
%%
colorSet = [0 	0 	255;%blue  
                   30 	144 	255;%light blue  
                   128 	128 128; % grey
                    0 0 0]/255; % black;
plotTrialType = [1 2 7];
savepath = 'C:\Users\uchidalab\Dropbox (Uchida Lab)\lab\FunInputome\writing\Figures\';
figure('position',[560 251 981 697]);

brainIdx = 1:5:sum(G==4);
psth = rawpsth(brainIdx,:,:);
nsubplot = length(brainIdx);
n = 1;
for j = 1:nsubplot
    subplot(3,3,n);
    for k = 1:length(plotTrialType)
        binSize = 20;
        smoothBin = 300;
        trace = squeeze(psth(j,plotTrialType(k),:));
        bin_trace = mean(reshape(trace(1:5000),binSize,[]));
        plot(linspace(-1,4,5000/binSize),smooth(bin_trace,smoothBin/binSize),'color',colorSet(k,:)); hold on;
        prettyP([-0.9 3.9],'',[0:3],'','a')
    end
    box off
    n = n+1;
end 
%saveas(gcf,[savepath plotAreas{i} '_panel_psth'])
figure;
roctrace = rocpsth(brainIdx,:,:);
n = 1
for j = 1:nsubplot
    subplot(3,3,n);
    imagesc(squeeze(roctrace(j,1,:))',[0 1])
    colormap yellowblue
    box off
    n = n+1;
end 