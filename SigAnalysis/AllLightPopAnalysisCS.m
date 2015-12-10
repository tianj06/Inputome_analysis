%path1 = pwd;
%path2 = 'C:\Users\uchidalab\Dropbox (Uchida Lab)\lab\FunInputome\rabies\analysis2015Fall\newLight\';
fl = what(pwd);
fl = fl.mat;
%fl = getfiles_OnlyInOnePath (path1,path2);
%%
for i = 1:length(fl)
    a = load(fl{i},'area');
    brainArea{i} = a.area;
    newCodingResults = CompuateValueRelatedResponseNew(fl{i},1);
    EventSig = CompuateResponsiveNeurons(fl{i},1);
    %load(fl{i},'EventSig','newCodingResults')
    ResSig(i,:) = EventSig;
    ValueClass(i,:) = newCodingResults(1,[1 2 3 5 6 7]);
    ValueDir(i,:) = newCodingResults(2,[1 2 3 5 6 7]);
end

[G,areaName]=grp2idx(brainArea);

%% merge some areas
% PPTg: PPTg (all animals other than PPTg_an), PPTg_an('Laurel', 'Kittentail')
% LH: LH_po ('Waterlily','Rice') LH_psth('Aubonpain') LH_an (all others)
% areaSetting1: PPTg only posterior; LH only anterior
brainArea(ismember(brainArea,{'LH_an'})) = {'LH'};

% areaSetting2: PPTg all; LH all
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
[G,areaName]=grp2idx(brainArea);
Results = [ResSig ValueDir];
Results.brainArea = brainArea';
%% seperate the data by short latency and long latency
llatency = nan(length(fl),1); % VTA neurons doesn't have latency are nans
for i = 1:length(fl)
    load(fl{i},'lightResult')
    if exist('lightResult','var')
        llatency(i) = lightResult.latency; 
    end
    clear lightResult
end
%%
results_short = Results(llatency<=6|isnan(llatency),:);
results_long = Results(llatency>6|isnan(llatency),:);
savePath = 'C:\Users\uchidalab\Documents\GitHub\Inputome_analysis\SigAnalysis\';
writetable(Results,[savePath 'CSresults.txt'],'Delimiter',',');

writetable(results_short,[savePath 'results_short2.txt'],'Delimiter',',');
writetable(results_long,[savePath 'results_long2.txt'],'Delimiter',',');

%plot_pop_summary_fromAnalyzedPanel(fl(CSsig&(~csValue)&(G==6)),savePath)

%% reward prediction error coding 

% plot overall overlapping between each metric
varNames = ResSig.Properties.VariableNames;
figure;
bar(100*varfun(@nanmean,ResSig,'OutputFormat','uniform'),0.5)
ylim([0 100])
set(gca,'xtickLabel',varNames)
ylabel('percent of Neurons')
%%
ResSig.Area = brainArea';
averageSigNeuron = varfun(@nanmean,ResSig,'GroupingVariables','Area');
figure;
for i = 3:5
    subplot(1,3,i-2)
    bar(100*averageSigNeuron{:,i})
    titleText = varNames{i-2};
    set(gca,'xtickLabel',averageSigNeuron{:,1})
    ylim([0 100])
    title(titleText)
end

figure;
bar(100*averageSigNeuron{:,3:5})
set(gca,'xtickLabel',averageSigNeuron{:,1})
legend(varNames)

%suptitle('Significant (both pos and neg)')
%set(gcf,'units','normalized','outerposition',[0 0 1 1],'PaperPositionMode','auto')
%saveas(gcf,[savePath 'Significant (both pos and neg)'],'tif')



%% CS plot
CS = [ResSig(:,1) ValueDir(:,1)];
CS.csValue(CS.CSsig==0)=0;
CS.brainArea = brainArea';
writetable(CS,'CSresults.txt','Delimiter',',');


CSresults = grpstats(CS, {'brainArea','csValue'},'sum');
writetable(CSresults,'CSresults.txt','Delimiter',' ');
figure;
for i = 1:9
    subplot(3,3,i)
    a = sig{:,i};
    b = dir{:,i};
    ind = (~isnan(a))&(~isnan(b));
    c = a(ind)&(b(ind)==1);   
    bar(100*grpstats(c,G(ind)));
    titleText = sig.Properties.VariableNames{i};
    set(gca,'xtickLabel',areaName)
    ylim([0 100])
    title(titleText)
end
suptitle('Significant positive')
set(gcf,'units','normalized','outerposition',[0 0 1 1],'PaperPositionMode','auto')
saveas(gcf,[savePath 'Significant positive'],'tif')
%% inhibition
figure;
for i = 1:9
    subplot(3,3,i)
    a = sig{:,i};
    b = dir{:,i};
    ind = (~isnan(a))&(~isnan(b));
    c = a(ind)&(b(ind)==-1);   
    bar(100*grpstats(c,G(ind)));
    titleText = sig.Properties.VariableNames{i};
    set(gca,'xtickLabel',areaName)
    ylim([0 100])
    title(titleText)
end
suptitle('Significant negative')
set(gcf,'units','normalized','outerposition',[0 0 1 1],'PaperPositionMode','auto')
saveas(gcf,[savePath 'Significant negative'],'tif')