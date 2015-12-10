figurePath = 'C:\analysis\unitsummary\';
a = rdir([figurePath '*.jpg']);
a = {a.name};
[~,figureName,~] = cellfun(@fileparts,a,'UniformOutput', false);
for i = 1:length(figureName)
    f = figureName{i};
    f = [f(1:end-7) '_formatted'];
    [animalName, ~, unitName]  =extractAnimalFolderFromFormatted(f);
    newPath = [figurePath animalName '\' unitName(1:3) '\' ];
    if ~exist(newPath)
        mkdir(newPath)
    end
    movefile([figurePath figureName{i} '.jpg'],[newPath  figureName{i} '.jpg'])
end

%%
figurePath = 'C:\Users\Hideyuki\Dropbox (Uchida Lab)\lab\FunInputome\plotting animals finished\';
a = rdir([figurePath '*.tif']);
a = {a.name};
[~,figureName,~] = cellfun(@fileparts,a,'UniformOutput', false);
for i = 1:length(figureName)
    f = figureName{i};
    numind = regexp(f,'\d','end');
    f = [f(1:numind(end)) '_formatted'];
    [animalName, ~, unitName]  =extractAnimalFolderFromFormatted(f);
    %newPath = [figurePath animalName '\' unitName(1:3) '\' ];
    newPath = [figurePath animalName '\'];
    if ~exist(newPath)
        mkdir(newPath)
    end
    movefile(a{i},[newPath  figureName{i} '.tif'])
end