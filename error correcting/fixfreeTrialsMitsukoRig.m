function fixfreeTrialsMitsukoRig

dataPath = 'D:\Dropbox (Uchida Lab)\lab\FunInputome\ProcessedNeurons\rabies_VTA\';
animalNames = {'Fettuccine'}; %'Fettuccine', , 'Woodchuck','Xenopus','Zebra'
%animalNames = {'Zinnia','Earwig','Locust','Xerophyla'}; %,
homePath = 'F:\VTA\'; % 'F:\PPTg\'; %

for k = 1:length(animalNames)
    fileList = rdir([dataPath animalNames{k} '*']);
    fileList = {fileList.name};
    for j = 1:length(fileList)
        fn = fileList{j};
        [~,fname,~]=fileparts(fn);
        [animalName, folderName] = extractAnimalFolderFromFormatted(fname);
        originalPath = [homePath animalName '\' folderName '\'];
        events = extractTrialNlyxCCTask(originalPath);
        save(fn,'-append','events');
    end

end