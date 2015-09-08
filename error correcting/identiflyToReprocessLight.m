ProcessedDataPath = 'D:\Dropbox (Uchida Lab)\lab\FunInputome\ProcessedNeurons\'; 

[dataFile, ProcessedDataPath] = uigetfile([ProcessedDataPath '*.mat'],...
    'Pick one (or more) MATLAB data file(s).','MultiSelect','on');
% fd = fopen(outputFile,'w');
if ~iscell(dataFile)
    dataFile = {dataFile};
end
results = cell(length(dataFile),2);
reformatNeurons = cell(1,1);
k = 1;
%%
for i =1:length(dataFile)
    load([ProcessedDataPath filesep dataFile{i}]);
    SponWV = checkLaser.Raw_Spon_wv;
    EvokedWV = checkLaser.Raw_wv;
    if (size(SponWV,2)~=4) || (size(EvokedWV,2)~=4)
        reformatNeurons(k) = dataFile(i);
        k = k+1;
    end
end

%%
savePath = 'D:\Dropbox (Uchida Lab)\lab\FunInputome\Plottings\';
errorFiles = cell(1,1);
k = 1;
%%
for i = 42:length(reformatNeurons)
    try
        plotLaserResponse_SingleNeuron(reformatNeurons{i},ProcessedDataPath);
    catch ME
        errorFiles{k,1} = reformatNeurons{i};
        errorFiles{k,2} = ME.message;
        k = k+1;
    end
    set(gcf,'units','normalized','outerposition',[0 0 1 1])
    idx = strfind(reformatNeurons{i},'_');
    fileName = reformatNeurons{i}(1:idx(5)-1);
    saveas(gcf,[savePath fileName 'Light'],'tif')
    close all;
end