homepath = 'C:\Users\uchidalab\Dropbox (Uchida Lab)\lab\FunInputome\rabies\rabies_VTA\';
fl_rabies = [homepath 'analysis\vta_light.mat'];
load(fl_rabies)
for i = 1:length(lihgtfiles)
    %analyzedData = getPSTHSingleUnit(lihgtfiles{i}); 
    %save(lihgtfiles{i},'-append','analyzedData');
    load([homepath 'formatted\' lihgtfiles{i}],'lightResult','checkLaser')
    llatency(i) = lightResult.latency; 
    llowSalt(i) = lightResult.lowSaltP; 
    lhightSalt(i) = lightResult.highSaltP; 
    lwvcorr(i) = lightResult.wvCorrAll; 
    ljitter(i) = nanstd(checkLaser.LaserEvokedPeak);
    p(i) = checkLaser.p_inhibit;
end
figure;
hist(llatency)

figure;
hist(llowSalt)

figure;
hist(lhightSalt)

figure;
hist(lwvcorr)

figure;
hist(p)

for i = 1:length(lihgtfiles)
    [name,~,~] = extractAnimalFolderFromFormatted(lihgtfiles{i});
    animalNames{i} = name;
end
unique(animalNames)