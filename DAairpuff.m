fl = what(pwd);
fl = fl.mat;
for i = 1:length(fl)
    load(fl{i},'area');
    brainArea{i} = area;
end

DAind = strcmp(brainArea,'DA');
fl = fl(DAind);

for i = 1:length(fl)
    load(fl{i},'analyzedData');
    rawPSTH(i,:,:) = analyzedData.rawPSTH(1:14,:);
end
%%
timeWin = [1:600];
b = mean(rawPSTH(:,10,3000+timeWin),3) - mean(rawPSTH(:,10,timeWin),3); % puff
timeWin = [1:600];
a = mean(rawPSTH(:,9,3000+timeWin),3)- mean(rawPSTH(:,9,timeWin),3); % reward
removeIdx = isnan(a)|isnan(b);
a = a(~removeIdx);
b = b(~removeIdx);
figure;
scatter(a,b)
[r,p]=corr(a,b);
xlabel('free reward')
ylabel('free airpuff')
title(sprintf('0-600ms - baseline r = %0.3f p = %0.3f',r,p))

timeWin = [1:600];
a = mean(rawPSTH(:,10,3000+timeWin),3)- mean(rawPSTH(:,10,timeWin),3); % reward
b = mean(rawPSTH(:,1,timeWin),3);
removeIdx = isnan(a)|isnan(b);
figure;
scatter(a(~removeIdx),b(~removeIdx))
[r,p]=corr(a(~removeIdx),b(~removeIdx));
xlabel('free airpuff')
ylabel('baseline')
title(sprintf('0-600ms - baseline r = %0.3f p = %0.3f',r,p))


timeWin = 1:600;
b = mean(rawPSTH(:,10,3000+timeWin),3) - mean(rawPSTH(:,10,timeWin),3); % puff
timeWin = 1:600;
a = mean(rawPSTH(:,11,1000+timeWin),3)- mean(rawPSTH(:,11,timeWin),3); % reward
removeIdx = isnan(a)|isnan(b);
a = a(~removeIdx);
b = b(~removeIdx);
figure;
scatter(a,b)
[r,p]=corr(a,b);
xlabel('reward cue 1-600')
ylabel('free airpuff 1-600')
title(sprintf('r = %0.3f p = %0.3f',r,p))

