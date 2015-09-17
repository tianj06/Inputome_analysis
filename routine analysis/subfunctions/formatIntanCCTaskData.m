% saveFile = formatVGlut2LHData(dataPath, spike_file)
%  Organizes behavioral and spike data into the common format and saves a
%  .mat file
% Inputs: dataPath is a full path to the data directory
%         spike_file is the name of the clustered time stamps in a .mat
%           file.  No directory name needed.
%         savePath (optional) is the full path to the save data directory.
%           Default is '.../VGlut2LH_Expt/ProcessedNeurons'
%         saveBatchFile (optional) is the full path and filename of the
%           batch file to append to.  Default is '.../VGlut2LH_Expt/batch.dat'
% Output: saveFile (optional) returns the filename of the saved .mat file
% Example:
%  formatVGlut2LHData(pwd,'TT2_3.mat');

% Vinod Rao
function saveFile = formatIntanCCTaskData(dataPath,spike_file,savePath,saveBatchFile)

%% Check data and filenames
% this checks to make sure the required file types are in the folder.
% this may not be necessary. Consider eliminating.

% dataPath = '/Users/vinod3000/Documents/UchidaLab/Data/ArchVS_D1/mouseA/2013-03-31_11-33-05';
% spike_file = 'TT2_3.mat';
% dataPath = pwd;
if nargin <1
    dataPath = pwd;
end

if dataPath(end)==filesep, dataPath = dataPath(1:end-1); end %remove any end slashes
if ~exist('spike_file','var')
    ephysFlag = 0;
else
    ephysFlag = 1;
end    
critFiles = {'digital_data.dat','analog_data.dat'};
if ephysFlag
    critFiles = [critFiles, spike_file, 'events.dat'];
end
% if ~iscell(spike_file)
%     spike_file = {spike_file};
% end
if nargin >=2
    if strcmp(spike_file{1}(end),'t')
        MClust35 = 0;
    else
        MClust35 = 1;
    end
end
if nargin<2 || isempty(spike_file)
    temp = dir('TT*.t');
    if isempty(temp)
        temp = dir('TT*.mat');
        MClust35 = 1;
    else
        MClust35 = 0;
    end
    temp = struct2cell(temp);
    temp = temp(1,:);
    cellList = false(length(temp),1);
    for i = 1:length(temp)
        if length(temp{i})<=10
            cellList(i) = true;
        end
    end
    spike_file = temp(cellList)';
    if isempty(spike_file)
        return;
    end
end
for i = 1:length(critFiles)
    if ~exist([dataPath filesep critFiles{i}],'file')
        error('%s is not present in %s', critFiles{i}, dataPath);
    end
end
if nargin<3
    savePath = ['C:\Users\uchidalab\Dropbox (Uchida Lab)\lab\FunInputome\ProcessedNeurons\']; %'C:\analysis\formatted\';%C:\Users\uchidalab\
end
if nargin<4
    saveBatchFile = [savePath(1:find(savePath==filesep,1,'last')), 'batchdata.dat'];
end
%% Load behavioral digital events
% These won't be used directly to populate the structures
% Rather, the event data will be reorganized to make a decimal value in the
% same format as the electrophys rig.  Later this will be used to compare
% the timing

% % Define constants to refer to columns

% BLANK = 1;
% ODOR1 = 2;
% ODOR2 = 3;
% ODOR3 = 4;
% ODOR4 = 5;
% WATER = 6;
% AIRPUFF_NOSE = 7;
% AIRPUFF_LEAK = 8; 

% Load data behavioral event data
filename = [dataPath filesep 'digital_data.dat'];
fid = fopen(filename);
behavEventData = fread(fid)	;	% read the first 6 bytes ('%FREAD')
fclose(fid);
behavEventData = reshape(behavEventData,8,[])';

% Detect changes, as digital data is encoded every ms.
diffs = sum(abs(diff(behavEventData)),2); %this returns a non-zero value if any
                               %columns of digidata change between two rows
diffs = [0; diffs];                 %for proper alignment
behavEventTimes = find(diffs);      %in ms 
sampling_rate = 1000;
behavEventData = behavEventData(behavEventTimes,:);  % #events x 8 matrix

% Reorganize data to create a decimal code in the following order:
%[anyodor, water, airpuff_nose]
btemp = cat(2, sum(behavEventData(:,2:5),2)>0, ...  %concatenate odor1-4
              behavEventData(:,6), ...             %water
              behavEventData(:,7));              %airpuff_nose 
temp = zeros(length(btemp),8);
for i = 1:length(btemp)
    temp(i,:) = dec2binvec(btemp(i),8);
end
behavCode = temp;

if ~isempty(abs(diff(behavEventTimes)-500)<10)
    sampling_rate = 500;
    behavEventTimes = behavEventTimes*2;
end
%% Load and organize events from Ephys setup
%cf read_events.m
% Define constants referring to the columns
AIRPUFF_NOSE = 1; %NB: 0 = closed, 1 = open
ANYODOR = 2;
LASER_ARCH = 3; %#ok<NASGU>
LASER_CHR2 = 4;
AIRPUFF_LEAK = 5; %#ok<NASGU>   NB: 0 = open, 1 = closed      #ok<NASGU>
WATER = 6;

% Load the event data from the Ephys setup
filename = [dataPath filesep 'events.dat'];
fid = fopen(filename);
ephysEventData = fread(fid,inf,'single','s');
fclose(fid);
ephysEventData = reshape(ephysEventData,3,[])'; %col1=decimal port code; col2=time stamps; col3=trialType
ephysEventTimes = ephysEventData(:,2)./10; %convert to ms

% ephysEventData(1659:end,3) = 0;
% ephysEventData(1659:end,1) = ephysEventData(1659:end,1) -8;


temp = zeros(length(ephysEventData),8);
for i = 1:length(ephysEventData(:,1))
    temp(i,:) = dec2binvec(ephysEventData(i,1),8);
end
ephysEvents = temp;
ephysEvents = ephysEvents(:, 3:end); % cols 1-2 are irrelevant. remove them.

% Remove redundant events - two events that are simultaneous but listed
% separately
redundant = find(diff(ephysEventTimes)<=1); 
ephysEventData(redundant,:) = []; %eliminate those redundant rows
ephysEventTimes(redundant) = [];
ephysEvents(redundant,:) = [];
%ephysEvents(1526:end,2) = 0;

    %this identifies the first of two lines with a timestamp <5ms different
% check extra redundant signal
b_odorTimes = behavEventTimes(logical(sum(behavEventData(:,2:5),2)));
e_odorTimes = ephysEventTimes(logical(ephysEvents(:,ANYODOR))&(ephysEventData(:,3)));
%b_odorTimes(32) = [];
% b_odorTimes = b_odorTimes(20:220);
% e_odorTimes = e_odorTimes(20:220);
%sanity check that behavioral rig and ephys rig have the same number of
%odor deliveries
%b_odorTimes = b_odorTimes(3:end);
%b_odorTimes = b_odorTimes(1:228);
%e_odorTimes(end) =[];
% b_odorTimes(diff(b_odorTimes)<2000) = [];
%b_odorTimes = b_odorTimes(1:end-1);
%e_odorTimes(371:end)=[];
if length(b_odorTimes) ~= length(e_odorTimes)
    disp('Behavioral setup and Ephys setup have different numbers of odor deliveries.');
    [wrongiti,wrongidx] = min(diff(e_odorTimes));
    display(['the smallest iti is' num2str(wrongiti) 'ms'])
    wrongEvent = find(ephysEventTimes == e_odorTimes(wrongidx));  
    if abs(ephysEventTimes(wrongEvent+2)-ephysEventTimes(wrongEvent)-1000)<5
        extraEvent = wrongEvent+1;
    elseif abs(ephysEventTimes(wrongEvent+2)-ephysEventTimes(wrongEvent+1)-1000)<5
        extraEvent = wrongEvent;
    end
    ephysEventData(extraEvent,:) = []; %eliminate those redundant rows
    ephysEventTimes(extraEvent) = [];
    ephysEvents(extraEvent,:) = [];
end


% Reorganize data to create decimal code matching above:
%[anyodor, water, airpuff_nose]
etemp = cat(2, ephysEvents(:,ANYODOR),...     
              ephysEvents(:,WATER), ...
              ephysEvents(:,AIRPUFF_NOSE));
temp = zeros(length(etemp),16);
for i = 1:length(etemp)
    temp(i,:) = dec2binvec(etemp(i),16);
end
ephysCode = temp;

%% Load the licking data and organize.
filename = [dataPath filesep 'analog_data.dat'];
fid = fopen(filename);
lickdata = fread(fid,inf,'double');
fclose(fid);
% Find threshold: 
%  - first lowpass filter
difflick = [0; diff(lickdata)];
[a,b] = butter(2,.16,'low');
filtlick = filtfilt(a,b,lickdata);
filtdiff = [0; diff(filtlick)];
%  - then compute a std.dev over each second.  Most 1s-periods should have
%  no licks and so base the threshold off the median.
% t = 1:1000:length(filtdiff);
% movingStd = zeros(length(t),1);
% for i = 1:length(t)
%     if i==length(t), movingStd(i) = std(filtdiff(t(i):end));
%     else movingStd(i) = std(filtdiff(t(i):t(i)+1000)); end
% end
%diffthresh = 40*median(movingStd);
diffthresh = 0.01;
%diffthresh = 0.4;
% now find licks, which are when the signal transitions from below the
% threshold to above the threshold (i.e, the diff()==1)
lickTimes_uncorr = find(filtdiff>diffthresh & ...        %current slope > threshold
                [0;filtdiff(1:end-1)]<diffthresh); %previous slope < threshold

%now excise the licks that occur less than 50ms after another lick
acceptLick = zeros(length(lickTimes_uncorr),1);
for i = 1:length(lickTimes_uncorr)
    if sum(acceptLick)==0
        acceptLick(i) = true;
    else
        acceptLick(i) = lickTimes_uncorr(i)-lickTimes_uncorr(find(acceptLick,1,'last'))>50;
    end
end
lickTimes_uncorr = lickTimes_uncorr(logical(acceptLick));
if sampling_rate == 500
    lickTimes_uncorr = 2*lickTimes_uncorr;
end
% % The commented code below is for plotting/debugging the lick
% ax1 = subplot(211);
% hold off
% plotrange = 70600:173440;
% plot(plotrange,lickdata(plotrange));
% hold on;
% ind = ismember(lickTimes_uncorr,plotrange);
% plot(lickTimes_uncorr(ind),lickdata(lickTimes_uncorr(ind)),'r*')
% ax2 = subplot(212);
% hold off
% plot(plotrange,filtdiff(plotrange));
% hold on;
% plot(lickTimes_uncorr(ind),filtdiff(lickTimes_uncorr(ind)),'r*');
% plot(xlim,[diffthresh diffthresh],'g')
% linkaxes([ax1 ax2],'x');

%% Determine whether the codes are ordered and the timing conversion.

% corr(ephysCode, behavCode); %this shows how well they are correlated.
%   % Because the value is ~1, the event orders are properly aligned
% 
% showPlot = 0;
% if showPlot
%     subplot(211); hold on; %#ok<UNRCH>
%     plot(behavEventTimes-behavEventTimes(1),...
%          ephysEventTimes-ephysEventTimes(1));
%     axis square
%     plot(xlim,ylim,'r');
%     xlabel('Behavioral setup timing (ms)');
%     ylabel('E-phys setup timing (ms)');
%     subplot(212)
%     temp = [diff(behavEventTimes) diff(ephysEventTimes)];
%     slope = temp(:,2)./temp(:,1);
%     plot(slope);
%     ylabel('Slope (no units)')
%     xlabel('Time (ms)')
% end
% % Because the bottom plot is not a flat line, the relationship between the
% % electrophys timing and the behavioral rig timing is NOT strictly linear.
% % Therefore, the behavioral timings for licks will need to be linearly 
% % interpolated.

%% Compute interpolation for lick data
% The lick times must be in terms of the ephys rig times
% The approach is to find the behavior rig times that sandwich each lick,
% and then linearly interpolate.
% Unlike the basic condiioning task, the event numbers don't seem to
% perfectly line up, so i'm just using odor onset as the marker.  
% However, for those licks that are before the first event or after the
% last, extrapolate based on the first or last slope, respectively.
if length(b_odorTimes) == length(e_odorTimes)

lickTimes = zeros(size(lickTimes_uncorr));
firstSlopeFxn = @(x)e_odorTimes(1)+(x-b_odorTimes(1))/diff(b_odorTimes(1:2))*diff(e_odorTimes(1:2));
lastSlopeFxn = @(x)e_odorTimes(end-1)+(x-b_odorTimes(end-1))/diff(b_odorTimes(end-1:end))*diff(e_odorTimes(end-1:end));
for i = 1:length(lickTimes)
    if lickTimes_uncorr(i)<b_odorTimes(1) %early licks
        lickTimes(i) = firstSlopeFxn(lickTimes_uncorr(i));
    elseif lickTimes_uncorr(i)>b_odorTimes(end) %late licks
        lickTimes(i) = lastSlopeFxn(lickTimes_uncorr(i));
    else
        ind = find(b_odorTimes<lickTimes_uncorr(i),1,'last');
        b1 = b_odorTimes(ind);
        b2 = b_odorTimes(ind+1);
        e1 = e_odorTimes(ind);
        e2 = e_odorTimes(ind+1);
        lickTimes(i) = (lickTimes_uncorr(i)-b1)/(b2-b1)... % compute fraction of current behavior event interval at which lick occurs
                       *(e2-e1) ... % scale by the length of the ephys rig interval
                      + e1;         % and finally add to the start of the ephys rig time
    end
end
end
%% Parse the ephysEvents into common format and setup events structure
% ephysEvents([505:568 1240:end],:) = [];
% ephysEventData([505:568 1240:end],:) = [];
% ephysEventTimes([505:568 1240:end]) = [];
odorOn = ephysEventTimes(logical(ephysEvents(:,ANYODOR)));
%odorOn = odorOn(1:end-1);
odorID = ephysEventData(logical(ephysEvents(:,ANYODOR)),3);
%odorID = odorID(1:end-1);
freeRewardInSession = ephysEventTimes(ephysEventData(:,3)==5 & ephysEvents(:,WATER)); % 5 is ephys code for free water trial
freeAirpuffInSession = ephysEventTimes(ephysEventData(:,3)==6 & ephysEvents(:,AIRPUFF_NOSE)); %6 is ephys code for free airpuff trial

nTrials = length(odorOn)+ length(freeRewardInSession)+ length(freeAirpuffInSession);
[trialStart, idx]= sort([odorOn; freeRewardInSession; freeAirpuffInSession]);
odorOnTrials = find(idx<=length(odorOn));
freeRewardTrials = find(idx>length(odorOn)&idx<=length(odorOn)+length(freeRewardInSession));
freeAirpuffTrials = find(idx > length(odorOn)+length(freeRewardInSession));
tempodorOn = nan(nTrials,1);
tempodorOn(odorOnTrials) = odorOn;
tempodorID = nan(nTrials,1);
tempodorID(odorOnTrials) = odorID;
odorOn = tempodorOn;
odorID = tempodorID;

trialType = nan(nTrials,1);
odorOff = nan(nTrials,1);
rewardOn = nan(nTrials,1);
airpuffOn = nan(nTrials,1);
firstLick = nan(nTrials,1);

for i = odorOnTrials'
    ind = find( ~ephysEvents(:,ANYODOR) & ephysEventTimes>odorOn(i), 1);
    odorOff(i) = ephysEventTimes(ind);
        
    ind = find(  ephysEvents(:,WATER) & ...
                 ephysEventTimes-odorOn(i)<2500 & ...
                 ephysEventTimes>odorOn(i), 1);
    if ~isempty(ind)
        rewardOn(i) = ephysEventTimes(ind);
    end
    
    ind = find( ephysEvents(:,AIRPUFF_NOSE) & ...
                ephysEventTimes-odorOn(i)<2500 & ...
                ephysEventTimes>odorOn(i), 1 );
    if ~isempty(ind)
        airpuffOn(i) = ephysEventTimes(ind);
    end
        
    if i<nTrials
        ind = find( lickTimes>odorOn(i) & lickTimes<odorOn(i+1), 1);
    else
        ind = find( lickTimes>odorOn(i) ,1);
    end
    if ~isempty(ind)
        firstLick(i) = lickTimes(ind);
    end
end

% to be consistent with Vinod used
ttCwaterUwater = 1;
ttCwaterUnothing = 2;
ttCuncertainUwater = 3;
ttCuncertainUnothing = 4;
ttCnothingUwater = 5;
ttCnothingUnothing = 6;
ttCairpuffUairpuff = 7;
ttCairpuffUnothing = 8;
ttUwater = 9;
ttUairpuff = 10;

if ~isempty(freeRewardTrials)
    rewardOn(freeRewardTrials) = freeRewardInSession;
    for i = freeRewardTrials'
        if i<freeRewardTrials(end)
            ind = find( lickTimes>trialStart(i) & lickTimes<trialStart(i+1), 1,'first');
        else
            ind = find( lickTimes>trialStart(i) ,1,'first');
        end
        if ~isempty(ind)
        firstLick(i) = lickTimes(ind);
        end
        trialType(i) = ttUwater;
    end
end

if ~isempty(freeAirpuffTrials)
    airpuffOn(freeAirpuffTrials) = freeAirpuffInSession;
    for i = freeAirpuffTrials'
        if i<freeAirpuffTrials(end)
            ind = find( lickTimes>trialStart(i) & lickTimes<trialStart(i+1), 1);
        else
            ind = find( lickTimes>trialStart(i) ,1);
        end
        if ~isempty(ind)
        firstLick(i) = lickTimes(ind);
        end
        trialType(i) = ttUairpuff;
    end
end

for i = odorOnTrials'
    switch odorID(i)
        case 1 % cue 50% reward
            if ~isnan(rewardOn(i))
                trialType(i) =ttCuncertainUwater;
            else
                trialType(i) = ttCuncertainUnothing;
            end
        case 2 % cue nothing
            if ~isnan(rewardOn(i))
                trialType(i) =ttCnothingUwater;
            else
                trialType(i) =ttCnothingUnothing;
            end
        case 3 % cue reward
            if ~isnan(rewardOn(i))
                trialType(i) = ttCwaterUwater;
            else
                trialType(i) = ttCwaterUnothing;
            end
        case 4 % cue airpuff
            if ~isnan(airpuffOn(i))
                trialType(i) = ttCairpuffUairpuff;
            else
                trialType(i) = ttCairpuffUnothing;
            end
    end
end


freeLaserOn = ephysEventTimes(logical(ephysEvents(:,LASER_CHR2)));
freeRewardOutSession = ephysEventTimes(ephysEventData(:,3)==0 & ephysEvents(:,WATER));
freeAirpuffOutSession = ephysEventTimes(ephysEventData(:,3)==0 & ephysEvents(:,AIRPUFF_NOSE));
%% load a spike file

if ~iscell(spike_file)
    spike_file = {spike_file}; 
end

%iterate through the spike files and use saveCellData to make the common
%format file
for m = 1:length(spike_file)

     [a,date] = fileparts(dataPath);
    [~,animalName] = fileparts(a);
     saveFile = [savePath filesep regexprep(animalName,'/','_') '_' date '_' spike_file{m}(1:end-2) '_formatted.mat'];
     
     if MClust35
       TS = load([dataPath,filesep,spike_file{m}]);
     else
       fid = fopen([dataPath,filesep,spike_file{m}],'r','b');  
       H = ReadHeader(fid);
       TS = fread(fid, inf,'uint32');
       fclose(fid)
     end
    if ~isempty(find(diff(TS)<20))
       TS(find(diff(TS)<20)) = [];
   end
   spikeTimes = TS/10;

    %% extract waveforms
    % want average waveform for laser-evoked spikes and non-laser-evoked spikes
    % load spike times and waveforms from the loading engine
    if ~isempty(freeLaserOn)
         laserEvokedSpikesLatency = nan(length(freeLaserOn),1);
         laserEvokedSpikesTiming = [];
        for i = 1:length(freeLaserOn)
            tempIdx = find((spikeTimes>freeLaserOn(i))&(spikeTimes<freeLaserOn(i)+10));
            if ~isempty(tempIdx)
                laserEvokedSpikesLatency(i) = spikeTimes(tempIdx(1)) - freeLaserOn(i);
                laserEvokedSpikesTiming = [laserEvokedSpikesTiming TS(tempIdx(1))]; 
            end
        end
        % extract the waveform of laser evoked spikes
        [t,LaserWV] = LoadingEngineIntan4([dataPath filesep spike_file{m}(1:3) '.dat'], laserEvokedSpikesTiming/10000,1);
        % get some random spikes
        [t,NoLaserWV] = LoadingEngineIntan4([dataPath filesep spike_file{m}(1:3) '.dat'], TS(100:100:length(TS))/10000,1);
        % compute average and stderr waveform for laser-triggered spikes
        meanLaserWV = squeeze(mean(LaserWV,1))';
        seLaserWV = squeeze(std(LaserWV,0,1)./sqrt(size(LaserWV,1)))';
        % compute average and stderr waveform for non-laser-triggered spikes
        meanNoLaserWV = squeeze(mean(NoLaserWV,1))';
        seNoLaserWV = squeeze(std(NoLaserWV,0,1)./sqrt(size(NoLaserWV,1)))';
    else
        meanLaserWV = [];
        seLaserWV = [];
        meanNoLaserWV = [];
        seNoLaserWV = [];
        laserEvokedSpikesLatency = [];
    end
    %% setup events structure
    events = setupEvents(nTrials,odorOn,odorOff,odorID,[],[],...
        rewardOn,airpuffOn,[],firstLick,trialType,[],[], ...
        freeLaserOn,[],'freeRewardOutSession',freeRewardOutSession,...
        'freeAirpuffOutSession',freeAirpuffOutSession,'trialStart',trialStart);

    %% set up response structure, also saving timestamps of laser-evoked spikes
    responses = setupResponses(spikeTimes,lickTimes,[],'laserEvokedSpikesLatency',laserEvokedSpikesLatency, ...
        'meanLaserWaveform',meanLaserWV, 'stderrLaserWaveform',seLaserWV, ...
        'meanNoLaserWaveform',meanNoLaserWV, 'stderrNoLaserWaveform',seNoLaserWV);

    %% save data
    saveCellData(saveFile, events, responses, [], saveBatchFile);
end
