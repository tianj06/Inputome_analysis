function updateRabiesDate(fn, T)

[animalName, folderName, ~] = extractAnimalFolderFromFormatted(fn);
ind=ismember(lower(T.AnimalName),lower(animalName));
temp = T.Rabies{ind};
idx = strfind(temp, '/');
m = str2num(temp(1:idx(1)-1));
d = str2num(temp(idx(1)+1:idx(2)-1));
y = str2num(temp(idx(2)+1:end));
initialDate = datenum(y, m, d);

    
recordDate = datenum(str2num(folderName(1:4)),...
    str2num(folderName(6:7)), str2num(folderName(9:10)));
rabiesDate = recordDate -initialDate;
save(fn,'-append','rabiesDate');