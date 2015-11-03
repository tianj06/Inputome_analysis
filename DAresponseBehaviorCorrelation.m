fl = what(pwd);
fl = fl.mat;
cueWindow = [1000:2000];
behaWindow = [1000:3000];
for i = 1:length(fl)
%     analyzedData = getPSTHSingleUnit(fl{i}); 
%     save(fl{i},'analyzedData','-append');
    load(fl{i},'analyzedData')
    DAcue{i} = 1000* mean(analyzedData.raster{1}(:,cueWindow),2);
    BehavCue{i} = 1000* mean(analyzedData.rasterLick{1}(:,behaWindow),2);
end

c = zeros(length(fl),1);
for i = 1:length(fl)
    [c(i),p(i)]= corr(DAcue{i} , BehavCue{i});
end

figure;
hist(c)
binCenters = -0.4:0.1:0.8;
Nsig = 100*histc(c((p <.05)),binCenters)/length(p);     
Ninsig = 100*histc(c((p >=.05)),binCenters)/length(p);     

hBar= bar(binCenters,[Nsig Ninsig],1,'stack');
set(hBar,{'FaceColor'},{[.3 .3 .3];'w'});  
prettyP('','','','','a')
xlabel('correlation lick DA cue')
ylabel('percent of neurons')
titleText = sprintf('DAWin %d to %d ms; LickWin %d to %d ms',cueWindow(1),...
    cueWindow(end),behaWindow(1),behaWindow(end))
title(titleText)

figure; 
for i = 1:length(fl)
    if i <=30
        subplot(5,6,i)
        scatter( BehavCue{i},DAcue{i})
    end
    [c(i),p(i)]= corr(DAcue{i} , BehavCue{i});
end
