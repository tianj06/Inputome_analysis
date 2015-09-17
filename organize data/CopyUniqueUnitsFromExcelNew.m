%CopyUniqueUnitsFromExcelNew  excel format 2013-07-16_00-00-10	TT2_01
homePath = 'C:\Users\uchidalab\Dropbox (Uchida Lab)\lab\FunInputome\rabies\rabies_Striatum\';
desFormattedDataPath = [homePath 'uniqueUnits\'];
desPlotPath = [homePath 'uniqueUnitsPlotting\'];
SourcePlottingPath = [homePath 'plotting\'];
SourceFormattedDataPath = [homePath 'formatted\'];
%dataFiles = {dataFiles.name};
plotFiles = rdir([SourcePlottingPath '*\*.tif']);
plotFiles = {plotFiles.name};

missingFormatted = cell(1,1);
missingPlotting = cell(1,1);
%% read excelsheet about units infor
excelDoc = 'C:\Users\uchidalab\Dropbox (Uchida Lab)\lab\FunInputome\rabies\NeuronFinalSt.xlsx';
[~,sheets] = xlsfinfo( excelDoc );
for i = 5%length(sheets)
    [num, txt, ~] = xlsread(excelDoc,sheets{i});
    if ~isempty(num)
        a = num2str(num);
        for j = 1:size(txt,1)
            txt{j,2} = ['TT' a(j,1) '_0' a(j,2)];
        end
    end
    AnimalName = sheets{i};
    for j = 1:size(txt,1)
        % extract recording time information
        filename = [AnimalName '_' txt{j,1} '_' txt{j,2} '_formatted.mat'];
        if exist([SourceFormattedDataPath filename],'file')
            desFile = [desFormattedDataPath filename];
            if ~exist(desFile,'file')
                copyfile([SourceFormattedDataPath filename], desFile);
            end
        else
            missingFormatted = [missingFormatted ; filename];
        end
        %% do the same thing with plotting data folder

        filename1 = [AnimalName '_' txt{j,1} '_' txt{j,2} 'Light.tif'];
        filename2 = [AnimalName '_' txt{j,1} '_' txt{j,2} 'PSTH.tif'];
        scourceFile1 = [SourcePlottingPath filename1]; % AnimalName '\' 
        scourceFile2 = [SourcePlottingPath  filename2]; % AnimalName '\'
       
        if ~exist(scourceFile1,'file')
            missingPlotting = [missingPlotting; filename1];
        else
            desFile = [desPlotPath filename1];           
            if ~exist(desFile,'file')
                copyfile(scourceFile1, desFile);
            end
        end
        
        if ~exist(scourceFile2,'file')
            missingPlotting = [missingPlotting; filename2];
        else
            desFile = [desPlotPath filename2];           
            if ~exist(desFile,'file')
                copyfile(scourceFile2, desFile);
            end
        end
    end
end
