savePath = 'C:\Users\uchidalab\Dropbox (Uchida Lab)\lab\FunInputome\rabies\analysis2015Fall\allunits\';
brainAreas = {'Ce', 'LH','VS','PPTg','Striatum','VP','RMTg'};
homeFolder = ['C:\Users\uchidalab\Dropbox (Uchida Lab)\lab\FunInputome\rabies\rabies_'];
k = 1;
for i = 1:length(brainAreas)
    area = brainAreas{i};
    formattedpath = [homeFolder area '\uniqueUnits\'];
    cd(formattedpath)
    fl = what(formattedpath);
    fl = fl.mat;
    for j = 1:length(fl)
        fn = fl{j};
        copyfile([formattedpath fn],[savePath fn])
        save(fn,'-append','area')
    end
end