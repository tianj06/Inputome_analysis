fl = what(pwd);
fl = fl.mat;

llatency = nan(length(fl),1); % VTA neurons doesn't have latency are nans
rdate = nan(length(fl),1);
%brainArea = {};
for i = 1:length(fl)
    load(fl{i},'lightResult','rabiesDate','area')
    if exist('lightResult','var')
        llatency(i) = lightResult.latency; 
    end
    if exist('rabiesDate','var')
        rdate(i) = rabiesDate; 
    end
    %brainArea{i} = area;
    clear lightResult rabiesDate
end
brainArea(ismember(brainArea,{'LH_an','LH_psth','LH_po'})) = {'LH'};
brainArea(ismember(brainArea,{'PPTg_an','PPTg'})) = {'PPTg'};

%% change  the name of brain areas
oldnames = {'Striatum','LH','VS','PPTg','RMTg','VP','DA','VTA3','VTA2','STh'};
newnames = {'Dorsal striatum','Lateral hypothalamus','Ventral striatum',...
    'PPTg','RMTg','Ventral pallidum','Dopamine','VTA type3',...
    'VTA type2','Subthalamic'};
oldbrain = brainArea;
for i = 1:length(oldnames)
    idx = ismember(oldbrain,oldnames{i});
    brainArea(idx) = newnames(i);
end

%%
[G L] = grp2idx(brainArea');
% only examine input neurons
inputG = [1 2 3 4 5 6 10];
inputIdx = ismember(G,inputG);
l = llatency(inputIdx);
d = rdate(inputIdx);
inputAreas = { 'PPTg','RMTg','Lateral hypothalamus','Subthalamic',...
   'Ventral pallidum','Ventral striatum','Dorsal striatum'};
inputLabel = brainArea(inputIdx);
figure;
for i = 1:length(inputG)
    plot(l(strcmp(inputLabel,inputAreas{i})),i,'ko')
    hold on;
end
set(gca,'yticklabel',inputAreas)
prettyP('','','','','a')
xlabel('Latency (ms)')
vline(6,'k--')
%%

figure;
jitterStep = 0.4;
for i = 1:length(inputG)
    days = d(strcmp(inputLabel,inputAreas{i})); 
    y = i*ones(length(days),1) + rand(length(days),1)*jitterStep;
    plot(days,y,'ko')
    hold on;
end
set(gca,'ytick',[1:7],'yticklabel',inputAreas)
prettyP('','','','','a')
xlabel('Latency (ms)')
vline(10.5,'k--')