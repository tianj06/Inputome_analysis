function [rocPSTH,lickPSTH,rawPSTH,allfl,areaList] = load_all_rabies_units(brainAreas, homeFolder)
if nargin <2
    homeFolder = ['C:\Users\uchidalab\Dropbox (Uchida Lab)\lab\FunInputome\rabies\rabies_'];
end
k = 1;
for i = 1:length(brainAreas)
    brainArea = brainAreas{i};
    formattedpath = [homeFolder brainArea '\uniqueUnits\'];
    cd(formattedpath)
    fl = what(formattedpath);
    fl = fl.mat;
    for j = 1:length(fl)
        load(fl{j}, 'analyzedData')
        analyzedData = remove_too_few_trials(analyzedData,5);
        rocPSTH(k,:,:) = analyzedData.rocPSTH(1:10,:);
        lickPSTH(k,:,:) = analyzedData.rawLick(1:10,:);
        rawPSTH(k,:,:) = analyzedData.rawPSTH(1:10,:);
        allfl{k} = fl{j};
        areaList{k} = brainArea;
        k = k+1;
    end
end