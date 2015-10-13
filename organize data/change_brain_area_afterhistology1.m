% change the brain area of specific animal after Mitsuko finished histology
fl = what(pwd);
fl = fl.mat;
animalNames = {};
brainAreras = {};
for i = 1:length(fl)
    fn = fl{i};
    [animalName,~,~] = extractAnimalFolderFromFormatted(fn);
    animalNames{i} = animalName;
    load(fn,'area')
    brainArea{i} = area;
end
[G,areaName]=grp2idx(brainArea);
%% change a specific area name to a new name
ind = find(G==find(strcmp(areaName,'St')));
for i = 1:length(ind)
    area = 'Striatum';
    fl{ind(i)}
    save(fl{ind(i)},'-append','area');
end 
%%
% Loon is in vSt instead of dSt
changeFileIndex = find(strcmp(animalNames,'Loon'));
for i = 1:length(changeFileIndex)
    area = 'VS';
    save(fl{changeFileIndex(i)},'-append','area');
end

% Zoes is in RMTg instead of PPTg
changeFileIndex = find(strcmp(animalNames,'Zoes'));
for i = 1:length(changeFileIndex)
    area = 'RMTg';
    save(fl{changeFileIndex(i)},'-append','area');
end

% Dimsum is in vSt instead of VP
changeFileIndex = find(strcmp(animalNames,'Dimsum'));
for i = 1:length(changeFileIndex)
    area = 'VS';
    save(fl{changeFileIndex(i)},'-append','area');
end

% Panera is in STh instead of Ce
changeFileIndex = find(strcmp(animalNames,'Panera'));
for i = 1:length(changeFileIndex)
    area = 'STh';
    save(fl{changeFileIndex(i)},'-append','area');
end

% anterior PPTg (Laurel and Kittentail); might have VTA
changeFileIndex = find(ismember(animalNames,{'Laurel', 'Kittentail'}));
for i = 1:length(changeFileIndex)
    area = 'PPTg_an';
    fl{changeFileIndex(i)}
    save(fl{changeFileIndex(i)},'-append','area');
end


changeFileIndex = find(ismember(animalNames,{'Waterlily','Rice'}));
for i = 1:length(changeFileIndex)
    area = 'LH_po';
    fl{changeFileIndex(i)}
    save(fl{changeFileIndex(i)},'-append','area');
end

changeFileIndex = find(ismember(animalNames,{'Aubonpain'}));
for i = 1:length(changeFileIndex)
    area = 'LH_psth';
    fl{changeFileIndex(i)}
    save(fl{changeFileIndex(i)},'-append','area');
end

changeFileIndex = find(ismember(animalNames,{'Cramelcafe', 'Dominos', 'Koreana',...
    'Mcdonald', 'Oishii','Vokka', 'Xfinity'}));
for i = 1:length(changeFileIndex)
    area = 'LH_an';
    fl{changeFileIndex(i)}
    save(fl{changeFileIndex(i)},'-append','area');
end
%% print animals in each area
for i = 1:length(areaName)
    disp(areaName{i})
    unique(animalNames(G==i))
end