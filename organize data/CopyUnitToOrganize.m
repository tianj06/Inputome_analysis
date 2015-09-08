function CopyUnitToOrganize
desPlotPath = 'C:\Users\jutian\Dropbox (Uchida Lab)\lab\Habenula Arch\PlottingByTetrode\';%'D:\Dropbox (Uchida Lab)\lab\FunInputome\PlottingByTetrode\';
SourcePlottingPath = 'C:\Users\jutian\Dropbox (Uchida Lab)\lab\Habenula Arch\Plottings\';%'D:\Dropbox (Uchida Lab)\lab\FunInputome\Plottings\';
SourceCheckClusterPath = 'C:\Users\jutian\Dropbox (Uchida Lab)\lab\Habenula Arch\Data\';%'D:\Dropbox (Uchida Lab)\lab\FunInputome\Data\';
%% copy plotted light response or PSTH
fileNames = rdir(SourcePlottingPath);
fileNames = {fileNames.name};
for i = 1:length(fileNames)
    [~,fn, ext] = fileparts(fileNames{i});
    ind = strfind(fn,'_');
    AnimalName = fn(1:ind(1)-1);
    TTName = fn(ind(3)+1:ind(4)-1);
    desPath = [desPlotPath AnimalName filesep TTName filesep];
    desFile = [desPath fn(ind(1)+1:end) ext];
    if ~exist(desPath,'dir')
        mkdir(desPath);
    end
    if ~exist(desFile,'file')
            copyfile(fileNames{i},desFile)
    end
end

%% copy check cluster results
fileNames = rdir([SourceCheckClusterPath '**\**\*.fig']);
fileNames = {fileNames.name};
errorIdx = [];
for i = 1:length(fileNames)
    fn = fileNames{i};
    ind = strfind(fn,filesep);
    AnimalName = fn(ind(end-2)+1:ind(end-1)-1);
    RecordDate =  fn(ind(end-1)+1:ind(end)-1);
    TTName = fn(ind(end)+2:end-5);
    UnitName =  fn(ind(end)+2:end-4);
    desPath = [desPlotPath AnimalName filesep TTName filesep];
    desFile = [desPath  RecordDate '_c' UnitName '.jpg'];
    if ~exist(desPath,'dir')
        mkdir(desPath);
    end
    if ~exist(desFile,'file')
            %copyfile(fileNames{i},desFile)
        try 
            openfig(fileNames{i},'new','invisible')
            saveas(gcf,desFile)
            close all
        catch
            errorIdx = [errorIdx i];
        end
    end
end
errorIdx

end