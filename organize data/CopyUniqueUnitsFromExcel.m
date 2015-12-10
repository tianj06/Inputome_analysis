function CopyUniqueUnitsFromExcel
homepath = 'C:\Users\uchidalab\Dropbox (Uchida Lab)\lab\FunInputome\rabies\rabies_PPTg\';
desFormattedDataPath = [homepath 'uniqueUnits\'];
desPlotPath = [homepath 'unique units plotting\'];
SourcePlottingPath = 'C:\analysis\plottings\'; %[homepath 'plotting\'];
SourceFormattedDataPath = ['C:\analysis\formatted\']%[homepath 'formatted\'];
dataFiles = rdir([SourceFormattedDataPath '*.mat']);
dataFiles = {dataFiles.name};
plotFiles = rdir([SourcePlottingPath '*.tif']);
plotFiles = {plotFiles.name};
%% read excelsheet about units infor
excelDoc = ['C:\Users\uchidalab\Dropbox (Uchida Lab)\lab\Ryan thesis\CyrusFinal.xlsx'];
[~,sheets] = xlsfinfo( excelDoc );
for i =1%length(sheets)
    [num txt all] = xlsread(excelDoc,sheets{i});
    % num: 1st colum Tetrode 3rd colum unit ID
    % txt: 1st row, variable name; 2colum date
    AnimalName = sheets{i};
    for j = 1:size(num,1)
        % extract recording time information
        date = txt{j+1,2};
        Merged = 0;
        if strcmp(date(1),'M')
            Merged =1;
            date(1) = [];
        end
        ind = strfind(date,'/');
        Month = date(1:ind(1)-1);
        if length(Month)==1
            Month = ['0' Month];
        end
        Day = date(ind(1)+1:ind(2)-1);
        if length(Day) ==1
            Day = ['0' Day];
        end
        Year = date(ind(2)+1:end);
        RecordTime = [Year '-' Month '-' Day];
        
        ind = strfind(dataFiles, [AnimalName '_' RecordTime]);
        nameMatch = find(~cellfun('isempty', ind));
        
        % extract unit information
        UnitName= ['TT' num2str(num(j,1)) '_' num2str(num(j,3))];
        ind = strfind(dataFiles, UnitName);
        a = find(~cellfun('isempty', ind));
        
        UnitName= ['TT' num2str(num(j,1)) '_0' num2str(num(j,3))];
        ind = strfind(dataFiles, UnitName);
        b = find(~cellfun('isempty', ind));
        UnitMatch = [a b];
        
        %file with both Unit match and Name match is the right one
        fileIdx = intersect(nameMatch,UnitMatch);
        if Merged
             ind = strfind(dataFiles, 'merged');
             MergeMatch = find(~cellfun('isempty', ind));
             fileIdx = intersect(fileIdx,MergeMatch);
        end
            
        if isempty(fileIdx)
            fn =  [AnimalName '_' RecordTime '*' UnitName];
            disp(['Miss formatted data' fn]);
        else
            [~,filename, ext] = fileparts(dataFiles{fileIdx});
            desFile = [desFormattedDataPath filename ext];
            if ~exist(desFile,'file')
                copyfile(dataFiles{fileIdx}, desFile);
            end
        end
        %% do the same thing with plotting data folder
        ind = strfind(plotFiles, [AnimalName '_' RecordTime]);
        nameMatch = find(~cellfun('isempty', ind));
        
        % extract unit information
        UnitName= ['TT' num2str(num(j,1)) '_' num2str(num(j,3))];
        ind = strfind(plotFiles, UnitName);
        a = find(~cellfun('isempty', ind));
        
        UnitName= ['TT' num2str(num(j,1)) '_0' num2str(num(j,3))];
        ind = strfind(plotFiles, UnitName);
        b = find(~cellfun('isempty', ind));
        UnitMatch = [a b];
        %file with both Unit match and Name match is the right one
        fileIdx = intersect(nameMatch,UnitMatch);
        
        if isempty(fileIdx)
            fn =  [AnimalName '_' RecordTime '*' UnitName];
            disp(['Miss plotting' fn]);
        else
            for k = 1:length(fileIdx)
                [~,filename, ext] = fileparts(plotFiles{fileIdx(k)});
                desFile = [desPlotPath filename ext];
                if ~exist(desFile,'file')
                    copyfile(plotFiles{fileIdx(k)}, desFile);
                end
            end
        end
    end
end
