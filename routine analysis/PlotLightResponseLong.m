homePath = 'D:';%'C:\Users\Hideyuki';
savePath =[homePath '\Dropbox (Uchida Lab)\lab\FunInputome\Plottings\'];
%'D:\Dropbox (Uchida Lab)\lab\FunInputome\VTARabiesLight\plotting\';
ProcessedDataPath = [homePath '\Dropbox (Uchida Lab)\lab\FunInputome\ProcessedNeurons\']; 
%% 

 [dataFile, ProcessedDataPath] = uigetfile([ProcessedDataPath '*.mat'],...
    'Pick one (or more) MATLAB data file(s).','MultiSelect','on');
if ~iscell(dataFile)
    dataFile = {dataFile};
end
errorFiles = cell(1,1);
k = 1;

plotrange = 50;
%%
for i = 1:length(dataFile)
    idx = strfind(dataFile{i},'_');
    fileName = dataFile{i}(1:idx(5)-1);
    animalName = fileName(1:idx(1)-1);
    load(dataFile{i})
    figure;   
    subplot(2,1,1)
     title(fileName)
    [~,r,psth] = plotPSTH(responses.spike, events.freeLaserOn, plotrange, ...
        plotrange, 'plottype','raster', 'smooth','n','axes',gca);
    subplot(2,1,2)
    plot(-plotrange:plotrange, smooth(psth,2))
end

