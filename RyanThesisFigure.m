fl = what(pwd)
fl = fl.mat;
% light identification
formattedpath = 'C:\Users\uchidalab\Dropbox (Uchida Lab)\lab\Ryan thesis\PPTgAllunits';
lowsalt = 0.01;
highsalt = 0.01;
plotflag = 1;
[lightfiles, lightlatency,lightjitter]= ...
    SelectLightResponsiveUnits('PPTg',formattedpath,lowsalt, highsalt,0);

finalLight = lightfiles(lightlatency<7);
lightLabel = ismember(fl,finalLight);
% AAV vs Rabies label
for i = 1:length(fl)
    animals{i} = extractAnimalFolderFromFormatted(fl{i});
end
AAVlabel = ismember(animals,{'ATG','Bruno','Cyrus'});
%% plotting sorted roc
filelist = fl;
smoothPSTH = zeros(length(filelist),10,5001);
rocPSTH = zeros(length(filelist),10,50);
lickPSTH = zeros(length(filelist),10,5001);
rawPSTH = zeros(length(filelist),10,5001);

for i = 1:length(filelist)
    load([formattedpath '\' filelist{i}], 'analyzedData')
    analyzedData = remove_too_few_trials(analyzedData,5);
    smoothPSTH(i,:,:) = analyzedData.smoothPSTH(1:10,:);
    rocPSTH(i,:,:) = analyzedData.rocPSTH(1:10,:);
    lickPSTH(i,:,:) = analyzedData.rawLick(1:10,:);
    rawPSTH(i,:,:) = analyzedData.rawPSTH(1:10,:);
    %
end
%%
auROCvalue = rocPSTH(:,[1 2 7 4 9],:);
auROCvalue = permute(auROCvalue,[2 1 3]);
cueResponse = nanmean(squeeze(rocPSTH(:,1,11:30)),2);
[~,plotorder] = sort(cueResponse);

AAVlight = lightLabel&AAVlabel';
rabieslight = lightLabel&(~AAVlabel');

figure('Position',[200 200 1000 787]);
subplot(1,6,1)
b = zeros(length(AAVlight),4);
b(AAVlight(plotorder),4) = 0.97;
b(rabieslight(plotorder),4) = 0.6;

imagesc(1-b,[0 1])
colormap(gca,'jet') 

axis off
titleText = {'90% reward','50% reward','no reward','Airpuff','free Reward'};

for j = 1:5
    subplot(1,6,j+1)
    plotValue = squeeze(auROCvalue(j,:,:));
    hold on;
    imagesc(plotValue(plotorder,:),[0 1]);
    colormap yellowblue
    axis(gca,'tight','ij');
    set(gca,'XTick',[10.5:10:50],'XTickLabel',{'0','1','2','3'})
    ylabel('Neuron'); xlabel('Time (s)');
    title(titleText{j});
end

% clustering all