load('D:\Dropbox (Uchida Lab)\lab\FunInputome\rabies\analysis2015Fall\allLightFiles.mat')
% change  the name of brain areas
oldnames = {'Striatum','LH','VS','PPTg','RMTg','VP','St','Ce'};
newnames = {'Dorsal striatum','Lateral hypothalamus','Ventral striatum',...
    'PPTg','RMTg','Ventral pallidum','Dorsal striatum','Central amygdala'};
oldbrain = allLightFiles.Area;
for i = 1:length(oldnames)
    idx = ismember(oldbrain,oldnames{i});
    allLightFiles.Area(idx) = newnames(i);
end
%%
plotArea = newnames([6 3 1]); %  [4 5 2 7]
figure;

for k = 1:length(plotArea)
    areaIdx = strcmp(allLightFiles.Area,plotArea{k});
    subplot(2,length(plotArea),k)
    hist(allLightFiles.Latency(areaIdx),0:1:15)
    xlim([0 15])
    title(plotArea{k})
    if k==1
        ylabel('#Neurons')
    end
    subplot(2,length(plotArea),k+length(plotArea))
    hist(allLightFiles.Jitter(areaIdx),0:1:15)
    xlim([0 10])
    xlabel('ms')
    title('Std latency')
    if k==1
        ylabel('#Neurons')
    end
end