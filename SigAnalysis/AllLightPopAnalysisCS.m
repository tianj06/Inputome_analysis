fl = what(pwd);
fl = fl.mat;
for i = 1:length(fl)
    a = load(fl{i},'area');
    brainArea{i} = a.area;
end
for i = 1:length(fl)
    load(fl{i},'EventSig','newCodingResults')
    ResSig(i,:) = EventSig;
    ValueClass(i,:) = newCodingResults(1,[1 2 3 5 6 7]);
    ValueDir(i,:) = newCodingResults(2,[1 2 3 5 6 7]);
end
[G,areaName]=grp2idx(brainArea);

%%
oldnames = {'Striatum','LH','VS','PPTg','RMTg','VP','St','DA','VTA3','VTA2','Ce'};
newnames = {'Dorsal striatum','Lateral hypothalamus','Ventral striatum',...
    'PPTg','RMTg','Ventral pallidum','Dorsal striatum','Dopamine','VTA type3',...
    'VTA type2','Central amygdala'};
oldbrain = brainArea;
for i = 1:length(oldnames)
    idx = ismember(oldbrain,oldnames{i});
    brainArea(idx) = newnames(i);
end

Results = [ResSig ValueDir];
Results.brainArea = brainArea';
%%
writetable(Results,'results.txt','Delimiter',',');

savePath = 'D:\Dropbox (Uchida Lab)\lab\FunInputome\rabies\allIdentified\Analysis\psthPlottings\check\';

plot_pop_summary_fromAnalyzedPanel(fl(CSsig&(~csValue)&(G==6)),savePath)

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