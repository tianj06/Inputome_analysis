function plotLaserResponse_SingleNeuron_AfterSnippets(dataFile,dataPath,RawPath)
%% load the data
if nargin<2 || isempty(dataPath)
    dataPath = pwd;
end

if iscell(dataFile)  %if multiple files were chosen, call this function once per file
    for i = 1:length(dataFile)
        plotLaserResponse_SingleNeuron(dataFile{i},dataPath,RawPath);
    end
    return
end
load([dataPath filesep dataFile]);

%% Parse name to define raw path
idx = strfind(dataFile,'_');
TTidx = str2double(dataFile(idx(4)-1));
if nargin < 3
    RawPath ='F:\Mouse Data\'; % ' % 
    if ~exist(RawPath,'dir')
        RawPath =  'F:\rabies\';
        if ~exist(RawPath,'dir')
          error('The raw path is not specified. Please check that drive is plugged in and names are correct. \nRawPath: %s\nFilename: %s', RawPath, dataFile);
        end
    end
end
if ~strcmp(RawPath(end),filesep)
    RawPath = [RawPath filesep];
end
RawPath = [RawPath ...
           dataFile(1:idx(1)-1) filesep ... animal name
           dataFile(idx(1)+1:idx(3)-1) filesep]; %date_time

%% 
laserOnset = events.freeLaserOn;
%laserOnset = laserOnset(1:200);
if isinteger (responses.spike)
    responses.spike = double(responses.spike);
    save([dataPath dataFile],'-append','responses');
end

laserEvokedSpikesLatency = nan(length(laserOnset),1);
laserEvokedSpikesTiming = [];
LaserSpikeIdx = [];
TS = responses.spike*10;
for i = 1:length(laserOnset)
    tempIdx = find((responses.spike >laserOnset(i))&(responses.spike <laserOnset(i)+15));
    if ~isempty(tempIdx)
        laserEvokedSpikesLatency(i) = responses.spike(tempIdx(1)) - laserOnset(i);
        laserEvokedSpikesTiming = [laserEvokedSpikesTiming TS(tempIdx(1))]; 
        LaserSpikeIdx = [LaserSpikeIdx i];
    end
end
%% extract waveform
TTfile = [RawPath 'TT' num2str(TTidx) '.dat'];

[t,LaserWV] = LoadingEngineIntan4(TTfile, laserEvokedSpikesTiming/10000,1);
% get some random spikes
N = 500;
st = floor(length(TS)/N);
if st == 0
    ind = 1:length(TS);
else
    ind = 1:st:length(TS);
end
[t,Raw_Spon_wv] = LoadingEngineIntan4(TTfile, TS(ind)/10000,1);

Raw_wv = nan(length(laserOnset),4,32);
Raw_wv(LaserSpikeIdx,:,:) = LaserWV;
LaserEvokedPeak = laserEvokedSpikesLatency;

% for i = 1:20:100
%     figure;plot(squeeze(Raw_Spon_wv(i,:,:))')
% end
%% label the laser pulses according to pulse frequency
% first identify laser pulse frequencies
ILI = diff(laserOnset);
pulseFreqs = 1000./unique(round(ILI));
pulseFreqs = round(sort(pulseFreqs(pulseFreqs >= 1),'ascend')); %only frequencies above 1Hz are part of trains
if ~isempty(diff(pulseFreqs)<1)
    pulseFreqs(diff(pulseFreqs)<1) = [];
end
numFreqs = length(pulseFreqs);

% now identify pulses
% a pulse is part of a frequency train if either the preceeding or
% following ILI is constitent with that frequency.
preILI = [0; ILI];
postILI = [ILI; 0];
pulseFreqInds = cell(numFreqs,1);
responsesProb = [];
for i = 1:numFreqs
    pulseFreqInds{i} = find( round(1000./preILI) == pulseFreqs(i) | ...
                             round(1000./postILI) == pulseFreqs(i) );
    responsesProb(i) = length(intersect( pulseFreqInds{i}, LaserSpikeIdx))/length(pulseFreqInds{i});                      
                         
end
%% Run the salt program
acceptablePulseFreqs = [pulseFreqInds{1}; pulseFreqInds{2};];
LasersTS = events.freeLaserOn(acceptablePulseFreqs);
 p_salt = setup_salt([dataPath filesep dataFile],LasersTS);
 
%% extract raw traces to preprare for plotting
wireStdErr = mean(responses.stderrNoLaserWaveform);
refWire = find( wireStdErr < 0.2*median(wireStdErr) );
intan = 0;
if ~isempty(refWire)
    refOn = true;
    refNCSnumber = 4*(TTidx-1)+refWire;
    refCSCfile = [RawPath 'CSC' num2str(refNCSnumber) '.ncs'];
    if ~exist(refCSCfile)
            refCSCfile = [RawPath 'CSC' num2str(refNCSnumber) '.dat'];
            intan = 1; % recorded using Intan Rig
    end
else
    refOn = false;
end


[~,extremeWire] = max( max(abs(responses.meanNoLaserWaveform),[],1) );
NCSnumber = 4*(TTidx-1)+extremeWire; 
CSCfile = [RawPath 'CSC' num2str(NCSnumber) '.ncs'];
if ~exist(CSCfile)
    CSCfile =  [RawPath 'CSC' num2str(NCSnumber) '.dat'];
    intan = 1;  % recorded using Intan Rig
end
for i = 1:4
    if intan
        allCSCfile{i} = [RawPath 'CSC' num2str(4*(TTidx-1)+i) '.dat'];
    else
        allCSCfile{i} = [RawPath 'CSC' num2str(4*(TTidx-1)+i) '.ncs'];
        fileSize = dir(allCSCfile{i});
        fileSize = fileSize.bytes;
        if fileSize < 10^7
            allCSCfile{i} = nan;
        end
    end
end

ILI = diff(laserOnset);
idx = find(ILI>60000); 
if ~isempty(idx)
    idx = idx(1);
    blockedges = [laserOnset(1) laserOnset(idx); ...
               laserOnset(idx+1) laserOnset(end)];
    blockedges = blockedges + 500.*[-1 1; -1 1]; %append some time around the edges
else
    blockedges = [laserOnset(1) laserOnset(end)];
    blockedges = blockedges + 500.*[-1 1]; 
end
if intan
    fid = fopen(CSCfile);
    sr = fread(fid,1,'double','s'); % skip the sr
    t0 = fread(fid,1,'single',4,'s');
    fclose(fid);
    t0 = t0/10;
else
    t0 = Nlx2MatCSC(CSCfile, [1 0 0 0 0], 0, 3, 1);
    t0 = t0/1000;
end
if blockedges(1) < t0
    blockedges(1) = t0;
end

% extract raw waveform around laser time
filtWVs = [];
[filtWV, intTS, sampfreq] = readCSCfile(CSCfile, blockedges);
%badWire = [];
for i = 1:length(allCSCfile)
    if ~isnan(allCSCfile{i})       
        [temp, intTS, sampfreq] = readCSCfile(allCSCfile{i}, blockedges);
        filtWVs(i,:) = temp;
    else
        badWire = [badWire i];
    end
end

if refOn
    if ~isnan(allCSCfile{refWire})       
        [temp, intTS, sampfreq] = readCSCfile(allCSCfile{refWire}, blockedges);
        filtWV  = filtWV -  temp;
    else
        badWire = [badWire i];
    end
end

% if ~isempty(badWire)
%     filtWVs(badWire,:) = zeros(length(badWire),size(filtWVs,2));
% end
clear temp
%% make some plottings
figure;
set(gcf,'Position',[440 98 652 700]);
p=panel();
p.pack('v',[0.05 1]);
p(2).pack('h',2);
p(2,2).pack('v',3);
%on the left side plot some waveforms aligned to laser
% first select some freelaser trials 
%  only use laser pulses from the shortest two (i.e., 1Hz and 5Hz)
%  frequencies and include half from first block and half from second block

acceptablePulseFreqs = [pulseFreqInds{1}];
plotLaserOnset = laserOnset(acceptablePulseFreqs);
N = 20; % number of raw trace to plot
Bin = floor(length(plotLaserOnset)/N);
plotTW = [-2 15]; % raw trace plotting window for each laser, ms
k = 0;
plotData = [];
plotLatency = LaserEvokedPeak(acceptablePulseFreqs);
for i = 2:Bin:length(plotLaserOnset)
    k = k+1; 
    ind = find(responses.spike>plotLaserOnset(i),1,'first');
    LaserEvokedSpiks(k) =plotLatency(i);
    [~, prevTSind] = min(abs(intTS-plotLaserOnset(i)));
    plotidx = prevTSind + round(plotTW*sampfreq/1000);
    x = linspace(plotTW(1),plotTW(2),diff(plotidx)+1);
    plotData(k,:) = filtWV(plotidx(1):plotidx(2)) + 400*(k-1);
end

%finally ploth
p(2,1).select();
yMark = 400*(0:k-1);
LaserEvokedSpiks(find(LaserEvokedSpiks>15))= nan;
clear temp_idx
plot(x,plotData(:,:))
hold on; scatter(LaserEvokedSpiks,yMark,'*')
title(['wire ' num2str(extremeWire)])

p(2,2,1).pack('h',4)

Nevoked = find(~isnan(Raw_wv(:,1,1)));
if Nevoked==1
    meanSW = squeeze(Raw_Spon_wv);
    stdSW = squeeze(Raw_Spon_wv);
else
    meanEW = squeeze(nanmean(Raw_wv));
    stdEW = squeeze(nanstd(Raw_wv));
end
Nspon = find(~isnan(Raw_Spon_wv(:,1,1)));
if Nspon ==1
    meanSW = squeeze(Raw_Spon_wv);
    stdSW = squeeze(Raw_Spon_wv);
else
    meanSW = squeeze(nanmean(Raw_Spon_wv));
    stdSW = squeeze(nanstd(Raw_Spon_wv));
end
WVcorr = [];

if ~isempty(Nevoked)
    yl(1) = 1.2*min(min(meanEW));
    yl(2) = 1.2*max(max(meanEW));
    for i = 1:4
        p(2,2,1,i).select();
        WVcorr(i) = corr(meanEW(i,:)',meanSW(i,:)');
        errorbar_patch(1:32, meanEW(i,:), stdEW(i,:),'k');
        hold on;
        errorbar_patch(1:32, meanSW(i,:), stdSW(i,:),'b');    
        title(['wire' num2str(i)]);
        axis tight
        ylim(yl);
        axH = gca;
%         if i ==1
%             legend('Evoked','Spontanous')
%         end
    end
else
    WVcorr = nan(1,4);
end
p(2,2,2).select();
plot(pulseFreqs, responsesProb,'o-');
ylim([0 1]);
title(sprintf('Total percent evoked = %3.1f%%',100*mean(responsesProb)));

p(2,2,3).select();
postLaseSpikeTime = zeros(length(laserOnset),31);
for i=1:length(laserOnset)
    idx = find((responses.spike>laserOnset(i)-15)& (responses.spike<(laserOnset(i)+15)));
    nearestspikes=responses.spike(idx);
    if ~isempty(nearestspikes)
         k=k+1;
         postLaseSpikeTime(i,round(nearestspikes-laserOnset(i))+16)=1;
    end
end
xbar = -15:15;
bar(xbar, sum(postLaseSpikeTime));
title('Spike distr after Laser');
xlabel('(ms)');
xlim([-15 15]);
%finally put some text near the top
% filename, Correlation, Salt results
p(1).select();
set(gca,'Visible','off');
xlim([0 100]); ylim([0 100])
if size(Raw_Spon_wv,1)>10&&...
         size(Raw_wv,1)>10
    str = sprintf('File: %s\nCorrelation: %5.3f\nSalt p-val: %5.3f',dataFile,...
             nanmean(WVcorr),p_salt);
     str = strrep(str,'_','\_');
     text(50,30,str,'HorizontalAlignment','Center');
end



%%
checkLaser.Raw_Spon_wv = Raw_Spon_wv;
checkLaser.Raw_wv = Raw_wv;
checkLaser.responsesProb = responsesProb;
checkLaser.LaserEvokedPeak = LaserEvokedPeak;
checkLaser.p_salt = p_salt;
save([dataPath dataFile],'-append','checkLaser');
end
