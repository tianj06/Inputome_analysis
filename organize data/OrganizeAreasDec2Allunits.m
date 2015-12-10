fl = what(pwd);
fl = fl.mat;
animalNames = {};
brainAreras = {};
for i = 1:length(fl)
    fn = fl{i};
    [animalName,~,~] = extractAnimalFolderFromFormatted(fn);
    animalNames{i} = animalName;
end
[G,areaName]=grp2idx(brainArea);

changeFileIndex = find(ismember(animalNames,{'Heath','Iris'}));
for i = 1:length(changeFileIndex)
    area = 'VS';
    save(fl{changeFileIndex(i)},'-append','area');
end

%%
brainAreras = {};
for i = 1:length(fl)
    fn = fl{i};
    load(fn,'area')
    brainArea{i} = area;
end
%%

