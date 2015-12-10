homePath = 'C:\Users\uchidalab\Dropbox (Uchida Lab)\lab\FunInputome\rabies\rabies_VTA\';
load([homePath 'rabiesType1.mat'])
for i = 1:length(rabies_type1)
    load([homePath 'formatted\' rabies_type1{i}],'analyzedData','rabiesDate');
    analyzedData = remove_too_few_trials(analyzedData,5);
    rawlick(i,:,:) = analyzedData.rawLick;
    [a,b,~] = extractAnimalFolderFromFormatted(rabies_type1{i});
    sessionName{i} = [a b];
    rdate(i) = rabiesDate;
end

[C,ia,~] = unique(sessionName);
%%
%ia = 1:length(rabies_type1);
trialTypes = [11 12 7];
timeWin = 2001:3000;
al = squeeze(mean(rawlick(ia,trialTypes,timeWin),3));
%validSession = al(:,1)>2;

grp = rdate(ia) <= 9;

early_mean = mean(al(grp&validSession',:));
early_std = std(al(grp&validSession',:));

late_mean = mean(al(~grp&validSession',:));
late_std = std(al(~grp&validSession',:));

figure;
barwitherr([early_std; late_std]',[early_mean; late_mean]')


%%
figure;
plot(rdate(ia),al,'o')
