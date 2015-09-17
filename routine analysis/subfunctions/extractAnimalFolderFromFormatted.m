function [animalName, folderName, unitName] = extractAnimalFolderFromFormatted(fname)

    idx = strfind(fname,'_');
    animalName = fname(1:idx(1)-1);
    folderName = fname(idx(1)+1:idx(3)-1);
    unitName = fname(idx(3)+1:idx(5)-1);
end