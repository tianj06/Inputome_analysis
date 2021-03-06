
for i = 1:length(fl)
    load([allunitPath '\' fl{i}], 'analyzedData')
    brainArea(i) = load([allunitPath '\' fl{i}], 'area');
    analyzedData = remove_too_few_trials(analyzedData,5);
    smoothPSTH(i,:,:) = analyzedData.smoothPSTH(1:10,:);
    rawpsthAll(i,:,:) = analyzedData.rawPSTH(1:10,:);
    %
end
brainArea = {brainArea.area};
%%
oldnames = {'Striatum','LH','VS','PPTg','RMTg','VP','STh'};
newnames = {'Dorsal striatum','Lateral hypothalamus','Ventral striatum',...
    'PPTg','RMTg','Ventral pallidum','Subthalamic'};
oldbrain = brainArea;
for i = 1:length(oldnames)
    idx = ismember(oldbrain,oldnames{i});
    brainArea(idx) = newnames(i);
end

%%
plotAreas = {'Ventral striatum','Dorsal striatum','Ventral pallidum','Subthalamic',...
    'Lateral hypothalamus','RMTg','PPTg'}; % ,,'rdopamine','VTA type3', 'VTA type2','Dopamine'
%plotAreas = fliplr(plotAreas);

G = orderAreaGroup(brainArea, plotAreas);

normalized = 1;
bin = 250;

colorset= [  0 	0 	255;%blue  
             30 	144 	255;%light blue  
             128 	128 128;
             255 0 0
             0 0 0]/255; % grey
         
plotTrialType = [1:bin; bin+1:2*bin; 6*bin+1:7*bin;3*bin+1:4*bin];
figure;
for i = 1:10
    idx = G==i;
    plotdata = rawpsthAll(idx,:);
    if normalized
        for j = 1:sum(idx)
            plotdata(j,:) = normalize01(plotdata(j,:));
        end
    end
    plotdata = mean(plotdata);
    subplot(3,4,i)
    for j = 1:size(plotTrialType,1)
        data = smooth(plotdata(plotTrialType(j,:)),5);
        x  = linspace(-1,4,bin);
        hold on;
        plot(x, data, 'color',colorset(j,:))
        title(area(i))
    end
end
savePath = 'C:\Users\uchidalab\Dropbox (Uchida Lab)\lab\FunInputome\writing\Figures\';
%export_fig([savePath 'average response by area normalized.pdf'])