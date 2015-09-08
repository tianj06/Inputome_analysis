formattedDataPath = 'C:\analysis\formatted\';

%externalDrives = setdiff( getdrives, {'c:\','d:\'});
rawPath = {'F:\Mouse Data\'};

figureSavePath = 'C:\analysis\plottings\unitsummary\';

fl = what(formattedDataPath);
fl = fl.mat;
% a = load('errorProcess');
% fl = a.errorProcess;
% fl = fl(:,1);

notProcess = {};
k = 1;
errorProcess = {};
n = 1;
for i = 2: length(fl)
    filename = [formattedDataPath fl{i}];
    [~,fn] = fileparts(filename);
    if ~exist([ figureSavePath fn(1:end-10) 'summary.jpg'],'file')

        [animalName, folderName, unitName] = extractAnimalFolderFromFormatted(fn);
        initialDate = datenum(2015, 2, 1);
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