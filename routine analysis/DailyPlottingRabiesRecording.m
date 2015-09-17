homePath = 'C:\Users\uchidalab\';% 'D:'%'C:\Users\Ju Tian'%'C:\Users\Hideyuki';
savePath =[homePath '\Dropbox (Uchida Lab)\lab\FunInputome\Plottings\'];
%'D:\Dropbox (Uchida Lab)\lab\FunInputome\VTARabiesLight\plotting\';
ProcessedDataPath = [homePath '\Dropbox (Uchida Lab)\lab\FunInputome\ProcessedNeurons\']; 
animalRabiesDate = [homePath '\Dropbox (Uchida Lab)\lab\FunInputome\animalRabiesDate.xlsx'];
T = readtable(animalRabiesDate,'Sheet','Sheet1');

%'D:\Dropbox (Uchida Lab)\lab\FunInputome\rabies\rabies_PPTg\formatted\';
%'D:\Dropbox (Uchida Lab)\lab\FunInputome\cellTypeSpecific\PPTgall\formatted\';
%'D:\Lab\Projects\Functional Inputom\Inputome_formatted_cells\'; 
 % 'D:\Dropbox (Uchida Lab)\lab\FunInputome\VTARabiesLight\formatted\';
%% 

 [dataFile, ProcessedDataPath] = uigetfile([ProcessedDataPath '*.mat'],...
    'Pick one (or more) MATLAB data file(s).','MultiSelect','on');
% ind = find(strcmp('Undefined variable "checkLaser" or class "checkLaser.Raw_Spon_wv".',...
%     errorProcess(:,2)));
% dataFile = errorProcess(ind,1);
% rawPath = {'K:\rabies\AllData\','N:\rabiesPPTg\','N:\rabiesRMTg\','N:\rabiesVTA\'};

rawPath = {'F:\rabies\'};%'F:\Mouse Data\'; %'F:\rabies\';%'M:\rabies\'; %
if ~iscell(dataFile)
    dataFile = {dataFile};
end
errorFiles = cell(1,1);
%%
k = 1;
for i = 1:length(dataFile)
    idx = strfind(dataFile{i},'_');
    fileName = dataFile{i}(1:idx(5)-1);
    animalName = fileName(1:idx(1)-1);
    rawfind = 0;
    for j = 1:length(rawPath)
        if exist([rawPath{j} animalName '\'])
            rawdataPath = rawPath{j};
            rawfind = 1;
        end
    end
    try
     plotSingleCellwithRaster(dataFile{i},ProcessedDataPath)
     set(gcf,'units','normalized','outerposition',[0 0 1 1],'PaperPositionMode','auto');
     saveas(gcf,[savePath fileName 'PSTH'],'tif')
     plotLaserResponse_SingleNeuron(dataFile{i},ProcessedDataPath,rawdataPath);
     set(gcf,'units','normalized','outerposition',[0 0 1 1],'PaperPositionMode','auto')
     saveas(gcf,[savePath fileName 'Light'],'tif') 
     
     analyzedData = getPSTHSingleUnit([ProcessedDataPath dataFile{i}]); 
     save([ProcessedDataPath dataFile{i}],'-append','analyzedData');
    
     lightResult = checkLaserSingleUnit([ProcessedDataPath dataFile{i}]);
     save([ProcessedDataPath dataFile{i}],'-append','lightResult');     
     
    [animalName, folderName, unitName] = extractAnimalFolderFromFormatted(dataFile{i});
    ind=find(ismember(lower(T.AnimalName),lower(animalName)));
    temp = T.Rabies{ind};
    idx = strfind(temp, '/');
    m = str2num(temp(1:idx(1)-1));
    d = str2num(temp(idx(1)+1:idx(2)-1));
    y = str2num(temp(idx(2)+1:end));
    initialDate = datenum(y, m, d);

    unitsummary([ProcessedDataPath dataFile{i}],initialDate,[rawdataPath animalName])
    set(gcf,'units','normalized','outerposition',[0 0 1 1],'PaperPositionMode','auto')
    saveas(gcf,[savePath fileName 'summary'],'tif')
     
    catch EM
        errorFiles{k,1} = dataFile{i};
        errorFiles{k,2} = EM.message;
        k = k+1;
    end
   pause(2)
    close all;
end