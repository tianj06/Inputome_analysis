plottingPath = 'D:\Dropbox (Uchida Lab)\lab\FunInputome\cellTypeSpecific\PPTgall\plotting\';
savePath = 'D:\Dropbox (Uchida Lab)\lab\FunInputome\cellTypeSpecific\PPTgall\plotting\loose\';

if istable(identifyDataNames)
    identifyDataNames = table2cell(identifyDataNames);
end
fileNames = identifyDataNames;
overwrite = 0;
for i = 1:length(fileNames)
    fn = fileNames{i};
    fn = fn(1:end-14);
    lightFigure = [fn 'Light.tif'];
    if exist([ plottingPath lightFigure])
        if (~exist([ savePath lightFigure]))||overwrite
              copyfile([ plottingPath lightFigure], [savePath lightFigure])
        end
    else
        disp([ plottingPath lightFigure])
    end
    PSTHFigure = [fn 'PSTH.tif'];
    if exist([ plottingPath PSTHFigure])
        if (~exist([ savePath PSTHFigure]))||overwrite
            copyfile([ plottingPath PSTHFigure], [savePath PSTHFigure])
        end
    else
        disp([ plottingPath PSTHFigure]);
    end
end
