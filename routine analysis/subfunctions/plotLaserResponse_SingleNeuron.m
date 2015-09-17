function plotLaserResponse_SingleNeuron(dataFile,dataPath,RawPath)
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
%% determine the reference wire
%any reference electrode should have a uniquely small, near zero std dev
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
%% choose the wire with the largest deviation and find its .ncs file
[~,extremeWire] = max( max(abs(responses.meanNoLaserWaveform),[],1) );
NCSnumber = 4*(TTidx-1)+extremeWire; 
CSCfile = [RawPath 'CSC' num2str(NCSnumber) '.ncs'];
if ~exist(CSCfile)
    CSCfile =  [RawPath 'CSC' num2str(NCSnumber) '.dat'];
    intan = 1;  % recorded using Intan Rig
else
    intan = 0;
    refOn = false;
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

%% align the timestamps between CSC and TT files
% get a chunck of data in a CSC file with the information of spikes
if intan&&refOn
    [DelayValue TimeShift RawWV] = alignSpikesCSCfile(responses.spike, {CSCfile,refCSCfile},1);
else
    [DelayValue TimeShift RawWV] = alignSpikesCSCfile(responses.spike, CSCfile);
end
 meanRawWV = nanmean(RawWV);
if max(meanRawWV) > abs( min(meanRawWV))
    useMax = 1;
    thresh = 0.4*max(meanRawWV);
else
    useMax = 0;
    thresh = 0.4*abs( min(meanRawWV));
end
display(['median error' num2str(median(DelayValue))])

if median(DelayValue) < 0.5    % after correction, time shift is smaller than 0.2ms
    if (abs(TimeShift) > 0.1)||(~exist('TimeAlign','var')) % there is indeed a need to update
        TimeAlign.DelayValue = DelayValue;
        TimeAlign.TimeShift = TimeShift;
        % update the respones.spike file
        responses.spike = responses.spike-TimeShift;
        save([dataPath dataFile],'-append','responses');
        save([dataPath dataFile],'-append','TimeAlign');
    end
else
    error('problem with timeshift correction')
end 
%% select time windows for the pulse trains
% there is a long train at the beginning and end of the task
ILI = diff(laserOnset);
idx = find(ILI>600*1000); % blocks of laser should be seperated at least 10min away
if ~isempty(idx)
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

%% extract raw waveform around laser time
filtWVs = [];
[filtWV, intTS, sampfreq] = readCSCfile(CSCfile, blockedges);
badWire = [];
for i = 1:length(allCSCfile)
    if ~isnan(allCSCfile{i})       
        [temp, intTS, sampfreq] = readCSCfile(allCSCfile{i}, blockedges);
        filtWVs(i,:) = temp;
    else
        badWire = [badWire i];
    end
end

if refOn
    filtWV  = filtWV -  filtWVs(refWire,:);
    filtWVs = filtWVs -  repmat(filtWVs(refWire,:), 4,1); 
end

if ~isempty(badWire)
    filtWVs(badWire,:) = zeros(length(badWire),size(filtWVs,2));
end
clear temp

%% label the laser pulses according to pulse frequency
% first identify laser pulse frequencies
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
for i = 1:numFreqs
    pulseFreqInds{i} = find( round(1000./preILI) == pulseFreqs(i) | ...
                             round(1000./postILI) == pulseFreqs(i) );
end


%% gather waveforms of the evoked spikes
% identify the first spike after laser
% Extract this from the filtered waveform and interpolated ts above.
%  not the responses.meanLaserWaveform - based off .ntt file and coarser resolution.
% also the ntt file consistently estimates the waves estimates the changes
% a few ms (3-4) earlier than the .ncs file.  Jeremiah and Sebastian did
% some control experiments arguing that the .ncs file's timing was more
% accurate.
% these will be aligned to the extremum of each waveform

spikesPostLaser = nan(length(laserOnset),1);
latency = nan(length(laserOnset),1);
%loop over each laser pulses
evokedSpikeWaveforms = nan(length(laserOnset),4,32);
%thresh = 3*std(filtWV); %this includes the actual spikes so this should be well above baseline
for i = 1:length(laserOnset)
     temp = find( responses.spike > laserOnset(i) &  ...
                 responses.spike <= laserOnset(i) + 15, 1, 'first' );
    if ~isempty(temp)
         [prevTSind, ~]= searchclosest(intTS, responses.spike(temp)); 
         tempC= filtWV(prevTSind-16:prevTSind+15);
         if useMax   % align by peak
             [peakV, peakI] = max(tempC);
             evokedSpikeWaveforms(i,:,:) = filtWVs(:, prevTSind-32+peakI:prevTSind-1+peakI);
         else % align by valley
             [peakV, peakI] = min(tempC);
             evokedSpikeWaveforms(i,:,:) = filtWVs(:, prevTSind-32+peakI:prevTSind-1+peakI);
         end
         spikesPostLaser(i) = responses.spike (temp);
         % calculate the precise latency of spike evoked by laser using
         % peak as the timing of spike
         latency(i) = intTS(prevTSind-15+peakI)-laserOnset(i);
    end
end

evokedSpikes = spikesPostLaser(~isnan(spikesPostLaser));

% now count spikes sorted by pulse frequency, and compute the fractions
frxnSpikesEvoked = zeros(numFreqs,1);
for i = 1:numFreqs
    frxnSpikesEvoked(i) = sum(~isnan(spikesPostLaser(pulseFreqInds{i})))/length(pulseFreqInds{i});
end


%% Find waveforms for a random sample of non-evoked spikes
%first make a sample of non-evoked spikes
% this requires eliminating all evoked spikes and only using spikes that
% were either first or second run of laser pulses. The pulses during the
% task were not extracted. 

% by Ju
nonEvokedSpikeTimes = setdiff(responses.spike,spikesPostLaser);
goodind = [];
for i = 1:size(blockedges)
goodind = [goodind; find( nonEvokedSpikeTimes > blockedges(i,1) & nonEvokedSpikeTimes < blockedges(i,2))];
end
nonEvokedSpikeTimes = nonEvokedSpikeTimes(goodind);
if length(nonEvokedSpikeTimes) < length(evokedSpikes)
    nonEvokedSpikeSamp = nonEvokedSpikeTimes;  %if too few spikes, just use all the non-evoked spikes
else                                           %otherwise, get a random sample of length(evokedSpikes)
    shuffOrder = randperm(length(nonEvokedSpikeTimes));
    nonEvokedSpikeSamp = nonEvokedSpikeTimes(shuffOrder(1:length(evokedSpikes)));
end

%now find the index of the spike extreme and the accompanying waveform as
%above
nonEvokedSpikeWaveforms = nan(length(nonEvokedSpikeSamp),4,32);
noSpikesFound_nonEvoked = [];
for i = 1:length(nonEvokedSpikeSamp)
    [prevTSind, ~]= searchclosest(intTS,nonEvokedSpikeSamp(i));
     tempC= filtWV(prevTSind-16:prevTSind+15);
     if useMax   % align by peak
         [peakV, peakI] = max(tempC);
         nonEvokedSpikeWaveforms(i,:,:) = filtWVs(:, prevTSind-32+peakI:prevTSind-1+peakI);
     else % align by valley
         [peakV, peakI] = min(tempC);
         nonEvokedSpikeWaveforms(i,:,:) = filtWVs(:, prevTSind-32+peakI:prevTSind-1+peakI);
     end
end
%% Run the salt program
acceptablePulseFreqs = [pulseFreqInds{1}; pulseFreqInds{2};];
LasersTS = events.freeLaserOn(acceptablePulseFreqs);
 p_salt = setup_salt([dataPath filesep dataFile],LasersTS);

%% now plot
%this is Ju-style
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
plotLatency = latency(acceptablePulseFreqs);
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

Nevoked = find(~isnan(evokedSpikeWaveforms(:,1,1)));
if Nevoked==1
    meanSW = squeeze(nonEvokedSpikeWaveforms);
    stdSW = squeeze(nonEvokedSpikeWaveforms);
else
    meanEW = squeeze(nanmean(evokedSpikeWaveforms));
    stdEW = squeeze(nanstd(evokedSpikeWaveforms));
end
Nspon = find(~isnan(nonEvokedSpikeWaveforms(:,1,1)));
if Nspon ==1
    meanSW = squeeze(nonEvokedSpikeWaveforms);
    stdSW = squeeze(nonEvokedSpikeWaveforms);
else
    meanSW = squeeze(nanmean(nonEvokedSpikeWaveforms));
    stdSW = squeeze(nanstd(nonEvokedSpikeWaveforms));
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
plot(pulseFreqs, frxnSpikesEvoked,'o-');
ylim([0 1]);
title(sprintf('Total percent evoked = %3.1f%%',100*mean(frxnSpikesEvoked)));

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
if size(nonEvokedSpikeWaveforms,1)>10&&...
         size(evokedSpikeWaveforms,1)>10
    str = sprintf('File: %s\nCorrelation: %5.3f\nSalt p-val: %5.3f',dataFile,...
             nanmean(WVcorr),p_salt);
     str = strrep(str,'_','\_');
     text(50,30,str,'HorizontalAlignment','Center');
end


%%
checkLaser.Raw_Spon_wv = nonEvokedSpikeWaveforms;
checkLaser.Raw_wv = evokedSpikeWaveforms;
checkLaser.responsesProb = frxnSpikesEvoked;
checkLaser.LaserEvokedPeak = latency;
checkLaser.p_salt = p_salt;
save([dataPath dataFile],'-append','checkLaser');
end
