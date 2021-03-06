fl = what(pwd);
fl = fl.mat;
for i = 1:length(fl)
    a = load(fl{i},'area');
    brainArea{i} = a.area;
end
% remove VTA rabies units
VTAind = ismember(brainArea,{'rVTA Type2','r VTA Type3','rdopamine'});
fl = fl(~VTAind);
N = length(fl);
clear brainArea
%%
TimeWin = 1:500;
freePuff = zeros(N,1);
freeWater = zeros(N,1);
dirFreeWater = zeros(N,1);
dirFreePuff = zeros(N,1);
timeWindowLatency = 500;
for i = 1:length(fl)
    if rem(i,100)==0
        disp(sprintf('%0.2f%%',100*i/length(fl)))
    end
    a = load(fl{i},'area');
    brainArea{i} = a.area;
    load(fl{i}, 'analyzedData')
    if ~exist('analyzedData', 'var')
        analyzedData = getPSTHSingleUnit(fl{i}); 
        save(fl{i},'-append','analyzedData')
    end
    % comopute airpuff response
    rs = analyzedData.raster;
    urs = rs([9 10]); 
    % free airpuff vs free reward
    US_spikes = cellfun( @(x)1000*mean(x(:,TimeWin+3000),2)-1000*mean(x(:,TimeWin+2500),2),urs,'UniformOutput',0);
    if length(US_spikes{2}) >= 5
        [~,freePuff(i)] = signrank(US_spikes{2});
        dirFreePuff(i) = mean(US_spikes{2})>0;
    else
        freePuff(i) = nan;
        dirFreePuff(i) = nan;
    end
    if length(US_spikes{1}) >= 5
        [~,freeWater(i)] = signrank(US_spikes{1});
        dirFreeWater(i) = mean(US_spikes{1})>0;
    else
        freeWater(i) = nan;
        dirFreeWater(i) = nan;
    end
    
    Rlatency(i) = freeUSlatency(rs{1},timeWindowLatency,5,30);
    Alatency(i) = freeUSlatency(rs{2},timeWindowLatency,5,30);
end
%%
brainArea(ismember(brainArea,{'LH_an','LH_psth','LH_po'})) = {'LH'};
brainArea(ismember(brainArea,{'PPTg_an','PPTg'})) = {'PPTg'};

% change  the name of brain areas
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
% remove nans
nonNans = ~isnan(freeWater);
brainArea1 = brainArea(nonNans);
dirFreeWater = dirFreeWater(nonNans);
Rlatency = Rlatency(nonNans);

nonNans = ~isnan(freePuff);
brainArea2 = brainArea(nonNans);
Alatency = Alatency(nonNans);
dirFreePuff = dirFreePuff(nonNans);

%%
plotAreas = {'Ventral striatum','Dorsal striatum','Ventral pallidum','Subthalamic',...
    'Lateral hypothalamus','RMTg','PPTg'}; % ,,'rdopamine','VTA type3', 'VTA type2','Dopamine'
%plotAreas = fliplr(plotAreas);

G = orderAreaGroup(brainArea1, plotAreas);
ind = dirFreeWater==0; %dirFreeWater==1 freeWater
bin = [0:10:520 inf];
figure;
tempdata = Rlatency;%Rcslatency
tempdata (~ind) = 10000;  
tempdata (isnan(tempdata)) = 5000; % set a big value so that those neurons
%are not shown in histogram calculation
plotHistByGroup(tempdata,bin,G,plotAreas,45)

% among all RCSvalue neurons, 96.1% have latency smaller than 500
sum(Rlatency(ind)<500)/length(ind)
% among all non RCSvalue neurons, 42.0% have latency smaller than 500
sum(Rlatency(isnan(freeWater)|(freeWater==0))<500)/sum(isnan(freeWater)|(freeWater==0))

G = orderAreaGroup(brainArea2, plotAreas);
ind = dirFreePuff==0; %dirFreeWater==1 freeWater
bin = [0:10:520 inf];
figure;
tempdata = Alatency;
tempdata (~ind) = 10000;  
tempdata (isnan(tempdata)) = 5000; % set a big value so that those neurons
%are not shown in histogram calculation
plotHistByGroup(tempdata,bin,G,plotAreas,30)
% among all RCSvalue neurons, 96.1% have latency smaller than 500
sum(Alatency(ind)<500)/length(ind)
% among all non RCSvalue neurons, 42.0% have latency smaller than 500
sum(Alatency(isnan(freeWater)|(freeWater==0))<500)/sum(isnan(freeWater)|(freeWater==0))

