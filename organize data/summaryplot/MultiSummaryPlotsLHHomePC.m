animalRabiesDate = 'C:\Users\Hideyuki\Dropbox (Uchida Lab)\lab\FunInputome\animalRabiesDate.xlsx';
T = readtable(animalRabiesDate,'Sheet','sheet1');

formattedDataPath = 'C:\Users\Hideyuki\Dropbox (Uchida Lab)\lab\FunInputome\rabies\rabies_LH\new\';
analyzedDataPath = 'C:\Users\Hideyuki\Dropbox (Uchida Lab)\lab\FunInputome\rabies\rabies_LH\analysis\'

%externalDrives = setdiff( getdrives, {'c:\','C:\Users\Hideyuki\'});
rawPath = {'J:\rabies\'}; %,'O:\LH\','M:\rabies\','K:\rabies\AllData\'

figureSavePath = 'C:\Users\Hideyuki\Dropbox (Uchida Lab)\lab\FunInputome\rabies\rabies_LH\unitSummary\';

fl = what(formattedDataPath);
fl = fl.mat;
% a = load('errorProcess');
% fl = a.errorProcess;
% fl = fl(:,1);

notProcess = {};
k = 1;
errorProcess = {};
n = 1;
for i = 1:length(fl)
    filename = [formattedDataPath fl{i}];
    [~,fn] = fileparts(filename);
    if ~exist([ figureSavePath fn(1:end-10) 'summary.jpg'],'file')

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
                unitsummary(filename,initialDate,rawdataPath)
                 set(gcf,'units','normalized','outerposition',[0 0 1 1],'PaperPositionMode','auto')
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
end 