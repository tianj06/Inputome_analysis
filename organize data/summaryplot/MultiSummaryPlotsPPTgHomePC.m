animalRabiesDate = 'D:\Dropbox (Uchida Lab)\lab\FunInputome\animalRabiesDate.xlsx';
T = readtable(animalRabiesDate,'Sheet','sheet1');

formattedDataPath = 'D:\Dropbox (Uchida Lab)\lab\FunInputome\rabies\rabies_PPTg\formatted\';
analyzedDataPath = 'D:\Dropbox (Uchida Lab)\lab\FunInputome\rabies\rabies_PPTg\analysis\'
load([analyzedDataPath 'allPSTH.mat'])
load([analyzedDataPath 'checkLightResults.mat'])

%externalDrives = setdiff( getdrives, {'c:\','d:\'});
rawPath = {'K:\rabies\AllData\','N:\rabiesPPTg\','N:\rabiesRMTg\','N:\rabiesVTA\'};

figureSavePath = 'D:\Dropbox (Uchida Lab)\lab\FunInputome\rabies\rabies_PPTg\unitSummary\';

% fl = rdir(formattedDataPath);
% fl = {fl.name};
a = load('errorProcess');
fl = a.errorProcess;
fl = fl(:,1);

notProcess = {};
k = 1;
errorProcess = {};
n = 1;
for i = 1: length(fl)
    filename = [formattedDataPath fl{i}];
    [~,fn] = fileparts(filename);
    [animalName, folderName, unitName] = extractAnimalFolderFromFormatted(fn);
    ind=find(ismember(lower(T.AnimalName),lower(animalName)));
    temp = T.Rabies{ind};
    idx = strfind(temp, '/');
    m = str2num(temp(1:idx(1)-1));
    d = str2num(temp(idx(1)+1:idx(2)-1));
    y = str2num(temp(idx(2)+1:end));
    initialDate = datenum(y, m, d);
    %
    rawfind = 0;
    for j = 1:length(rawPath)
        if exist([rawPath{j} animalName '\'])
            rawdataPath = [rawPath{j} animalName];
            rawfind = 1;
        end
    end
    if rawfind 
        try
            unitsummary(filename,fl,initialDate,rawdataPath)
            saveas(gcf,[ figureSavePath fn(1:end-10) 'summary'],'jpg')
        catch EM
            errorProcess{n,1} = fn;
            errorProcess{n,2} = EM.message;
            n = n+1;
        end
    else
        notProcess{k} = filename;
        k = k+1;
    end
    close all;
end 