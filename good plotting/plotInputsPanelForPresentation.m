fl = what(pwd);
fl = fl.mat;
N = length(fl);
for i = 1:length(fl)
    load(fl{i},'analyzedData')
    rawPSTH(i,:,:) = analyzedData.rawPSTH(1:10,:);
    rocPSTH(i,:,:) = analyzedData.rocPSTH(1:10,:);
end

for i = 1:length(fl)
    a = load(fl{i},'area');
    brainArea{i} = a.area;
end
% change  the name of brain areas
oldnames = {'Striatum','LH','VS','PPTg','RMTg','VP','St','DA','VTA3','VTA2','Ce'};
newnames = {'Dorsal striatum','Lateral hypothalamus','Ventral striatum',...
    'PPTg','RMTg','Ventral pallidum','Dorsal striatum','Dopamine','VTA type3',...
    'VTA type2','Central amygdala'};
oldbrain = brainArea;
for i = 1:length(oldnames)
    idx = ismember(oldbrain,oldnames{i});
    brainArea(idx) = newnames(i);
end
%%
plotAreas = {'Dorsal striatum','Lateral hypothalamus','Ventral striatum',...
    'PPTg','RMTg','Ventral pallidum','Dorsal striatum','Central amygdala'};
colorSet = [0 	0 	255;%blue  
                   30 	144 	255;%light blue  
                   128 	128 128; % grey
                    0 0 0]/255; % black;
plotTrialType = [1 2 7];
savepath = 'C:\Users\uchidalab\Dropbox (Uchida Lab)\lab\FunInputome\rabies\analysis2015Fall\panel\';

for i = 1:length(plotAreas)
    brainIdx = strcmp(brainArea,plotAreas{i});    
    [~,plotOrder] = sort(sum(squeeze(rocPSTH(brainIdx,1,11:20)),2));
    psth = rawPSTH(brainIdx,:,:);
    psth = psth(plotOrder,:,:);
    nsubplot = min(30,sum(brainIdx));
    figure('position',[560 251 981 697]);
    n = 1;
    for j = 1:nsubplot
        subplot(5,6,n);
        for k = 1:length(plotTrialType)
            binSize = 20;
            smoothBin = 200;
            trace = squeeze(psth(j,plotTrialType(k),:));
            bin_trace = mean(reshape(trace(1:5000),binSize,[]));
            plot(linspace(-1,4,5000/binSize),smooth(bin_trace,smoothBin/binSize),'color',colorSet(k,:)); hold on;
            xlim([-0.9 3.9])
        end
        box off
        n = n+1;
    end 
    saveas(gcf,[savepath plotAreas{i} '_panel_psth'])
end
