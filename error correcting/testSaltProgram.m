% get pvalue use salt program
% directory for folder that stores all of the formatted data; MODIFY it by
% your needs
ProcessedDataPath = pwd;% 'D:\Dropbox (Uchida Lab)\lab\FunInputome\ProcessedNeurons\'; 

[dataFile, ProcessedDataPath] = uigetfile([ProcessedDataPath '\*.mat'],...
    'Pick one (or more) MATLAB data file(s).','MultiSelect','on');

% file that you want to write salt result to; MODIFY it by your needs\
homeFolder = 'D:\Dropbox (Uchida Lab)\lab\FunInputome\cellTypeSpecific\PPTgall\';
outputFile = [ homeFolder 'checkLightResults'];
outputProblemFile = [homeFolder 'checkLightErrorFiles'];

%'D:\Dropbox (Uchida Lab)\lab\FunInputome\saltSummaryAll.mat';
% fd = fopen(outputFile,'w');
if ~iscell(dataFile)
    dataFile = {dataFile};
end
%results = cell(length(dataFile),2);
ProblemNeurons = cell(1,1);
k = 1;
%%
results = [];
for i =1:length(dataFile)
    % extract laser pulses with particular frequency
    results{i,1} =  dataFile{i}; % save filename as the first column
    load([ProcessedDataPath filesep dataFile{i}]);
    laserOnset = events.freeLaserOn;
    ILI = diff(laserOnset);
    pulseFreqs = [1 5 10 20 50];
    numFreqs = length(pulseFreqs);

    % now identify pulses
    % a pulse is part of a frequency train if either the preceeding or
    % following ILI is constitent with that frequency.
    preILI = [0; ILI];
    postILI = [ILI; 0];
    pulseFreqInds = cell(numFreqs,1);
    for j = 1:numFreqs
        pulseFreqInds{j} = find( round(1000./preILI) == pulseFreqs(j) | ...
                                 round(1000./postILI) == pulseFreqs(j) );
    end
    %% calculate salt
    acceptablePulseFreqs = [pulseFreqInds{1}; pulseFreqInds{2}];
    LowFreqLaser = laserOnset(acceptablePulseFreqs);
    HighFreqLaser = laserOnset([pulseFreqInds{3}; pulseFreqInds{4}; pulseFreqInds{5}]);
    % salt at low freq 1 and 5Hz stimulation
    results{i,2} =  setup_salt([ProcessedDataPath filesep dataFile{i}],LowFreqLaser);
    % salt at all freq stimulation
    results{i,3} = setup_salt([ProcessedDataPath filesep dataFile{i}],HighFreqLaser);

    %setup_salt([ProcessedDataPath filesep dataFile{i}],laserOnset);

    %% calculate waveform correlation
    % find waveforms contributing to salt
    ll = checkLaser.LaserEvokedPeak;
    jitterRange = [mean(ll(~isnan(ll))) - std(ll(~isnan(ll)))  median(ll(~isnan(ll))) +std(ll(~isnan(ll)))];
     results{i,6}= nanmedian(ll);
    idx = find((ll>jitterRange(1))&(ll<jitterRange(2)));
    SponWV = checkLaser.Raw_Spon_wv;
    EvokedWV = checkLaser.Raw_wv;
    if (~isempty(idx))&&(length(idx)>5)&&(size(SponWV,1)>5)
        EvokedTimingWV = EvokedWV(idx,:,:);
        try
            results{i,4} = calculateWVcorrelation(SponWV,EvokedWV);
            results{i,5} = calculateWVcorrelation(SponWV,EvokedTimingWV);
        catch
             ProblemNeurons(k) = dataFile(i);
             k = k+1;
        end
    else
        ProblemNeurons(k) = dataFile(i);
        results{i,4} = nan;
        results{i,5} = nan;
        k = k+1;
    end
    %fprintf(fd,'%s\t%1.3f\n\r', dataFile{i}, tempP);
end
%fclose(fd)
results = cell2table(results);
results.Properties.VariableNames={'filename','psaltLow','psalthigh',...
    'WVcorrAll','WVcorrSpecific','latency'};

save(outputFile, 'results');
save(outputProblemFile, 'ProblemNeurons')
%%
%ix=cellfun(@isempty,results);
%results(ix)={nan}; 
% saltP = cell2mat(results(:,[2 3]));
% y =  cell2mat(results(:,5));
% latency =cell2mat(results(:,6));
% nanSalt = isnan(y);
% saltP(nanSalt) = nan;
% x = saltP;
% x(x==0) = 0.001;
% x = log10(x);


figure;
subplot(3,1,1)
title('salt Pvalue dist (log)')
hist(log10(results.psaltLow))
subplot(3,1,2)
title('wave correlation distribution')
hist(results.WVcorrSpecific)
subplot(3,1,3)
title('latency distribution')
hist(results.latency)
saveas(gcf,[homeFolder 'marginalDistributionLightParameter'])

%%
xx = log10(results.psaltLow);
xx(xx==-Inf)=-3;
figure;
subplot(2,2,1)
scatter(xx,results.WVcorrSpecific)
xlabel('Psalt')
xlim([-3.5 0])
ylabel('wv corr')
subplot(2,2,2)
scatter(results.latency,results.WVcorrSpecific)
xlabel('latency')
ylabel('wv corr')
subplot(2,2,3)
scatter(xx,results.latency)
xlabel('Psalt')
xlim([-3.5 0])
ylabel('latency')

subplot(2,2,4)
scatter3(xx,results.WVcorrAll,results.latency)
ylim([0 1])
xlabel('log10(saltP)')
ylabel('WV correlation')
zlabel('spike latency')
saveas(gcf,[homeFolder 'scatterplotLightParameter'])

%%
xx = max([results.psaltLow results.psalthigh],[],2);
ind = find((results.WVcorrAll>=0.9)&(xx<=0.001)&(results.latency<=10));
length(ind)
ind(1) = [];
identifyDataNames = table2cell(results(ind,'filename'));
save([homeFolder 'identifyiedNeuron1'],'identifyDataNames')


ind = find((results.WVcorrAll>=0.9)&(xx<=0.001)&(results.latency<=6));
length(ind)

identifyDataNames = table2cell(results(ind,'filename'));
save([homeFolder 'identifyiedNeuron2'],'identifyDataNames')