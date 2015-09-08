fl = errorFiles(:,1);
[animalNames, folderNames, unitNames] =cellfun(@extractAnimalFolderFromFormatted,fl,'UniformOutput',0);

TTIDs = cellfun(@(x) x(3), unitNames);

[uni_Folder, ia,ic ]= unique(folderNames);

Rawpath = 'K:\St\';
errorF = [];
k = 1;
for i = 3:5%length(uni_Folder)   
    ani_name = animalNames{ia(i)};
    tempTT_ID = TTIDs(ic==i);
    TTs = unique(tempTT_ID);
    cd([Rawpath ani_name '\' uni_Folder{i}])
    newFolder = [uni_Folder{i}(1:11) '00-00-10'];
    saveFolder = [Rawpath ani_name '\' newFolder];
    if ~exist(saveFolder)
        mkdir(saveFolder)
    end
    try
        for j = 1:length(TTs)
            get_all_snippets_tetrode_Nlyx(str2double(TTs(j)),nan,nan,saveFolder)
        end
    catch
         errorF{k} = [saveFolder str2double(TTs(j))];
         k = k+1;
    end
end