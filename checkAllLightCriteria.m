homepath = 'C:\Users\uchidalab\Dropbox (Uchida Lab)\lab\FunInputome\rabies\analysis2015Fall\newLight\';
fl = what(homepath);
fl = fl.mat;
brainArea = {};
for i = 1:length(fl)
    %analyzedData = getPSTHSingleUnit(lihgtfiles{i}); 
    %save(lihgtfiles{i},'-append','analyzedData');
    load([homepath fl{i}],'lightResult','checkLaser','area')
    brainArea{i} = area;
    llatency(i) = lightResult.latency; 
    llowSalt(i) = lightResult.lowSaltP; 
    lhightSalt(i) = lightResult.highSaltP; 
    lwvcorr(i) = lightResult.wvCorrAll; 
    ljitter(i) = nanstd(checkLaser.LaserEvokedPeak);
    p(i) = checkLaser.p_inhibit;
end
RMTgIdx = strcmp(brainArea,'RMTg');

figure;
hist(llatency(RMTgIdx))
title('latency')

figure;
hist(llowSalt(RMTgIdx))
title('low salt')

figure;
hist(lhightSalt(RMTgIdx))
title('high salt')

figure;
hist(lwvcorr)
title('wave correlation')

figure;
hist(p)

plot_pop_summary_fromAnalyzed(fl(RMTgIdx&lhightSalt<0.01))
plot_pop_summary_fromAnalyzed(fl(RMTgIdx))
