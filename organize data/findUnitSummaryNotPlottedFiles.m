figureList = rdir('D:\Dropbox (Uchida Lab)\lab\FunInputome\rabies\rabies_PPTg\unitSummary\**\**\*.jpg');

figureList = { figureList.name};

figureList = figureList';
[~,idx]=unique(figureList);

figureList = figureList(idx);

[~,figureName,~] = cellfun(@fileparts,figureList,'UniformOutput', false);

removeExtra =  @(x) [x(1:end-7) '_formatted.mat'];

NamefromFigure = cellfun(removeExtra,figureName,'UniformOutput', false);

fileName = what('D:\Dropbox (Uchida Lab)\lab\FunInputome\rabies\rabies_PPTg\formatted\');
fileName = fileName.mat;

fileNotPlotted = setdiff(fileName,NamefromFigure);