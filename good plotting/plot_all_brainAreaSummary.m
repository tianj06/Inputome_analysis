
brainAreas = {'Ce', 'LH','VS','PPTg','Striatum','VP','RMTg'};
lowsalt =  [0.01, 0.01,0.01,0.01,0.01,0.01,0.01];
highsalt = [0.01, 0.01,1, 0.01, 1,0.01,1];
for i = 1:length(brainAreas)
    brainArea = brainAreas{i};
    formattedpath = ['C:\Users\uchidalab\Dropbox (Uchida Lab)\lab\FunInputome\rabies\rabies_' brainArea '\uniqueUnits\'];
    cd(formattedpath)
    SelectLightResponsiveUnits(brainArea,formattedpath, lowsalt(i), highsalt(i),1)
    close all;
end