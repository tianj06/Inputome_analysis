savepath = 'C:\Users\uchidalab\Dropbox (Uchida Lab)\lab\FunInputome\rabies\allIdentified\newLight\';
homeFolder = ['C:\Users\uchidalab\Dropbox (Uchida Lab)\lab\FunInputome\rabies\rabies_'];

for i = 1:length(allLightFiles.FileName)
    brainArea = allLightFiles.Area{i};
    fn = allLightFiles.FileName{i};
    formattedpath = [homeFolder brainArea '\uniqueUnits\'];
    copyfile([formattedpath fn],[savepath fn]);
end