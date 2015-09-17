% saveFile = formatVGlut2LHData(dataPath, spike_file)
%  Organizes behavioral and spike data into the common format and saves a
%  .mat file
% Inputs: dataPath is a full path to the data directory
%         spike_file is the name of the clustered time stamps in a .mat
%           file.  If a cell array of spike_files are inputted this will 
%           generate the save data for each file name.  No directory name 
%           needed.
%         savePath (optional) is the full path to the save data directory.
%           Default is '.../VGlut2LH_Expt/ProcessedNeurons'
%         saveBatchFile (optional) is the full path and filename of the
%           batch file to append to.  Default is '.../VGlut2LH_Expt/batch.dat'
% Output: saveFile (optional) returns the filename of the saved .mat file
% Example:
%  formatVGlut2LHData(pwd,'TT2_3.mat');

% Vinod Rao
function saveFile = formatNlynxCCtaskData(dataPath,spike_file,savePath,saveBatchFile)

%% Check data and filenames
% this checks to make sure the required file types are in the folder.
% this may not be necessary. Consider eliminating.

% dataPath = 'F:\rabies\ultrafly\2014-06-24_12-57-27';
% spike_file = 'TT1_01.t';
if nargin <1
    dataPath = pwd;
end

if dataPath(end)==filesep, dataPath = dataPath(1:end-1); end %remove any end slashes
if ~exist('spike_file','var')
    ephysFlag = 0;
else
    ephysFlag = 1;
end

%check events file - should be named 'Events.nev'
eventFile = [dataPath filesep 'Events.nev'];
if ~exist(eventFile,'file');
    error('''Events.nev'' not found within %s.',dataPath);
end

%check for eye movement file - something with a 64 or a 25 in the name
rigHide = 0;
lickFile = 'CSC64.ncs';
rigMitsuko = 1;

% if ~isempty(dir('CSC64*'))
%     lickFile = dir('CSC64*');
%     rigMitsuko = 1;
% elseif ~isempty(dir('CSC25*'))
%     lickFile = dir('CSC25*');
%     rigHide = 1;
% else
%     error('No file containg licks (assume CSC64 or CSC25) in %s.',dataPath');
% end
if isstruct(lickFile) %if multiple files, pick the smallest filesize (presumably downsampled).
    temp = struct2cell(lickFile);
    temp = cell2mat(temp(3,:));
    [~,ind] = min(temp);
    lickFile = lickFile(ind).name;
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
if nargin<3
    inds = find(dataPath==filesep,2,'last');
    %savePath = [dataPath(1:inds(1)), 'ProcessedNeurons'];
    savePath = ['D:\Dropbox (Uchida Lab)\lab\FunInputome\ProcessedNeurons'];
end
if nargin<4
    saveBatchFile = [savePath(1:find(savePath==filesep,1,'last')), 'batchdata.dat'];
end

if iscell(spike_file)
    if strcmp(spike_file{1}(end-2:end),'mat')
        MClust35 = 1;
    else
        MClust35 = 0;
    end
else
    if strcmp(spike_file(end-2:end),'mat')
        MClust35 = 1;
    else
        MClust35 = 0;
    end
end
%% Load events from Events.nev
events = struct('Timestamps', 'Ttls');
[events.Timestamps, events.Ttls] = ...
    Nlx2MatEV([dataPath filesep 'Events.nev'],[1 0 1 0 0] ,0 ,1 );

% now parse into the correct codes
TTLs = events.Ttls';
temp = zeros(length(TTLs),16);
for i = 1:length(TTLs)
    temp(i,:) = dec2binvec(TTLs(i),16);
end
TTLs = temp;
TTLs = fliplr(TTLs); %de2bi yields big bits on right so need to flip order
events.Timestamps = events.Timestamps./1000; %convert to ms
%% only needed for new Neuralynx data
reduntIdx = find(diff(events.Timestamps)==0);
if ~isempty(reduntIdx)
    events.Timestamps(reduntIdx+1) = [];
    TTLs (reduntIdx+1,:) = [];
end
%%
if rigHide
    digLaser = 11;
    digOdor4 = 12; %airpuff cue
    digOdor3 = 13; 
    digOdor2 = 14;
    digOdor1 = 15;
    digWater = 10;
    digAirpuff = 9;

elseif rigMitsuko
    digLaser = 11; % or 11
    digOdor4 = 12;  %airpuff cue
    digOdor3 = 15;   %10% cue
    digOdor2 = 13;  %50% cue
    digOdor1 = 14;   %90%cue
    digWater = 10;
    digAirpuff = 9;% and 6
end

%% Now parse events

% first define trial starts
%  these are odor onsets whenever they happen
%  but also need to locate free airpuffs and free rewards - that is rewards
%  and airpuffs without previous odor.

%collect odor onsets index
odorOnInds = find(sum(TTLs(:,[digOdor1,digOdor2,digOdor3,digOdor4]),2));
timestamps_shift1 = [zeros(1,1) events.Timestamps(1:end-1)];
odor4TS = events.Timestamps(find(TTLs(:,digOdor4)));
airpuffInd = find(TTLs(:,digAirpuff));
freeRewardInds = find( TTLs(:,digWater) & ...
                       (events.Timestamps - timestamps_shift1 > 3000)' );  %extra sanity check to make sure two events previous did not happen within last 3sec
freeAirpuffInds= [];
for i = 1:length(airpuffInd)
    puffTime = events.Timestamps(airpuffInd(i));
    indCloestOdor4 = find(odor4TS<puffTime,1,'last');
    if isempty(indCloestOdor4)
        freeAirpuffInds = [freeAirpuffInds airpuffInd(i)];
    else
        if puffTime - odor4TS(indCloestOdor4)>2500
            freeAirpuffInds = [freeAirpuffInds airpuffInd(i)];
        end
    end
end

freeAirpuffInds = freeAirpuffInds';
trialStartInds = cat(1,odorOnInds, freeRewardInds, freeAirpuffInds);
trialStartInds = sort(trialStartInds);
trialStartTimes = events.Timestamps(trialStartInds);
ntrials = length(trialStartInds)-1;

%set up trial types - nomenclature is C->'CS', U->'US',
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

%set up variables needed for running setupEvents().
odorOn = nan(ntrials,1);
odorOff = nan(ntrials,1);
odorID = nan(ntrials,1);
trialType = nan(ntrials,1);
rewardOn = nan(ntrials,1);
airpuffOn = nan(ntrials,1);
freeLaserOn = events.Timestamps(logical(TTLs(:,digLaser)));

%iterate through the trials and fill the above variables
for i = 1:ntrials
    tempind = find(events.Timestamps == trialStartTimes(i));
    if TTLs(tempind,digOdor1) %Cuncertain
        odorOn(i) = events.Timestamps(tempind);
        odorOff(i) = events.Timestamps(tempind+1);
        odorID(i) = 1;
        if TTLs(tempind+2,digWater)
            rewardOn(i) = events.Timestamps(tempind+2);
            trialType(i) = ttCuncertainUwater;
        else
            trialType(i) = ttCuncertainUnothing;
        end
    elseif TTLs(tempind,digOdor2) %Cnothing
        odorOn(i) = events.Timestamps(tempind);
        odorOff(i) = events.Timestamps(tempind+1);
        odorID(i) = 2;
        if TTLs(tempind+2,digWater)
            tempRewardOn = events.Timestamps(tempind+2);
            if tempRewardOn - odorOn(i) < 2500            
                trialType(i) = ttCnothingUwater;
                rewardOn(i) = tempRewardOn;
            else
                trialType(i) = ttCnothingUnothing;
            end
        else
            trialType(i) = ttCnothingUnothing;
        end
    elseif TTLs(tempind,digOdor3)  %Cwater
        odorOn(i) = events.Timestamps(tempind);
        odorOff(i) = events.Timestamps(tempind+1);
        odorID(i) = 3;
        if TTLs(tempind+2,digWater)
            rewardOn(i) = events.Timestamps(tempind+2);
            trialType(i) = ttCwaterUwater;
        else
            trialType(i) = ttCwaterUnothing;
        end
    elseif TTLs(tempind,digOdor4)   %Cairpuff
        odorOn(i) = events.Timestamps(tempind);
        odorOff(i) = events.Timestamps(tempind+1);
        odorID(i) = 4;
        if TTLs(tempind+2,digAirpuff)
            airpuffOn(i) = events.Timestamps(tempind+2);
            trialType(i) = ttCairpuffUairpuff;
        else
            trialType(i) = ttCairpuffUnothing;
        end
    elseif TTLs(tempind,digWater)  %free water
        rewardOn(i) = events.Timestamps(tempind);
        trialType(i) = ttUwater;
    elseif TTLs(tempind,digAirpuff) %free airpuff
        airpuffOn(i) = events.Timestamps(tempind);
        trialType(i) = ttUairpuff;
    else
        sprintf('No correct type for trial %d.',i)
        keyboard
    end
end

%% detect licks
%load the lickdata
diffthresh = 200; %12
licks = struct('Timestamps', 'Samples');
[licks.Timestamps, licks.Samples] =  Nlx2MatCSC([dataPath filesep lickFile],[1 0 0 0 1],0,1 );
sample_freq = round( 512*10^6/(licks.Timestamps(2)- licks.Timestamps(1))); 
lick_data = reshape(licks.Samples(:,1:(end-1)),1,[])';

%compute the sample frequency and low-pass filter to Nyquist corresponding
%to 20Hz, or whatever is defined in maxfreq
[a,b] = butter(2,.16,'low');
lowpass_filted_data = filtfilt(a,b,lick_data);
filtdiff = [0; diff(lowpass_filted_data)];

lickIdx = int32(find(filtdiff>diffthresh & ...        %current slope > threshold
                [0;filtdiff(1:end-1)]<diffthresh));
           
lickTimes_uncorr = licks.Timestamps(floor(lickIdx/512)+1)'/1000+ ...
double(1000*(512-rem(lickIdx,512)))/sample_freq;

%lickTimes_uncorr = zeros(length(lickIdx),1);        
% for i = 1:length(lickIdx)
%   timeIdx = floor(lickIdx(i)/512); 
%   if timeIdx == 0
%       lickTimes_uncorr(i) = data.Timestamps(timeIdx+1)/512*lickIdx(i);
%   else
%       lickTimes_uncorr(i) =  data.Timestamps(timeIdx)+(data.Timestamps(timeIdx+1) - data.Timestamps(timeIdx))/512*(rem(lickIdx(i),512)); 
%   end
% end
%lickTimes_uncorr = lickTimes_uncorr/1000; % convert to ms

%now excise the licks that occur less than 50ms after another lick
acceptLick = zeros(length(lickTimes_uncorr),1);
for i = 1:length(lickTimes_uncorr)
    if sum(acceptLick)==0
        acceptLick(i) = true;
    else
        acceptLick(i) = lickTimes_uncorr(i)-lickTimes_uncorr(find(acceptLick,1,'last'))>50;
    end
end
lickTimes = lickTimes_uncorr(logical(acceptLick));
%% excise trials
% consider adding a segment where the user can select a trial number to
% stop analysis on because the animal quit.  
% this could be done by plotting lick rasters
% figure;
% tempcol = {'r','b','g','c'};
% tempodorflag = [odorID==1,odorID==2,odorID==3,odorID==4];
% tempodor = repmat(odorOn,1,4).*tempodorflag;
% tempodor(isnan(tempodor))=0;
% tempodor = mat2cell(tempodor,size(tempodor,1),[1 1 1 1]);
% plotPSTH(lickTimes,tempodor,1000,4000,'plottype','raster','colororder',tempcol);
% hold on;
% plot([0 0], ylim,'k'); plot([1000 1000], ylim, 'k');
% cutoff = input('Enter trial number at which to cut off: ');
% if numel(cutoff)==1 && round(cutoff)==cutoff && cutoff>0 && cutoff<ntrials %if cutoff is a positive integer
%     ntrials = cutoff;
%     odorOn = odorOn(1:cutoff);
%     odorOff = odorOff(1:cutoff);
%     odorID = odorID(1:cutoff);
%     rewardOn = rewardOn(1:cutoff);
%     airpuffOn = airpuffOn(1:cutoff);
%     trialType = trialType(1:cutoff);
% else
%     sprintf('Using the full %d trials.',ntrials)
% end

%% setup events structure
events = setupEvents(ntrials, odorOn, odorOff, odorID, [], [], rewardOn, airpuffOn, ...
                     [], [], trialType, [], [], freeLaserOn);

%% iterating through spike files, produce the waveforms and save the cell data
%make spike_file into a file list
if ~iscell(spike_file)
    spike_file = {spike_file}; 
end

%iterate through the spike files and use saveCellData to make the common
%format file
for i = 1:length(spike_file)
    
    %make a file name based on the folder names
    [a,date] = fileparts(dataPath);
    [~,animalName] = fileparts(a);
    if MClust35
         saveFile = [savePath filesep regexprep(animalName,'/','_') '_' date '_' spike_file{i}(1:end-4) '_formatted.mat'];       
    else
        saveFile = [savePath filesep regexprep(animalName,'/','_') '_' date '_' spike_file{i}(1:end-2) '_formatted.mat'];
    end
    
    %load spikes and convert to ms
    if MClust35
       load([dataPath,filesep,spike_file{i}],'TS');
       spikeTS =TS;
    else
        fid = fopen([dataPath,filesep,spike_file{i}],'r','b');
       H = ReadHeader(fid);
       spikeTS = fread(fid, inf,'uint32');
       fclose(fid)
    end
   if ~isempty(find(diff(spikeTS)<20))
       spikeTS(find(diff(spikeTS)<20)) = [];
   end
   spikeTimes = spikeTS;
    spikeTS = spikeTS./10;

    if ~isempty(freeLaserOn)
         laserEvokedSpikesLatency = nan(length(freeLaserOn),1);
         laserEvokedSpikesTiming = [];
        for m = 1:length(freeLaserOn)
            tempIdx = find((spikeTS>freeLaserOn(m))&(spikeTS<freeLaserOn(m)+15));
            if ~isempty(tempIdx)
                laserEvokedSpikesLatency(m) = spikeTS(tempIdx(1)) - freeLaserOn(m);
                laserEvokedSpikesTiming = [laserEvokedSpikesTiming spikeTimes(tempIdx(1))]; 
            end
        end
        % extract the waveform of laser evoked spikes
        if exist([dataPath filesep spike_file{i}(1:3) '.dat'],'file')
            [t,LaserWV] = LoadingEngineIntan4([dataPath filesep spike_file{i}(1:3) '.dat'], laserEvokedSpikesTiming/10000,1);
            % get some random spikes
            [t,NoLaserWV] = LoadingEngineIntan4([dataPath filesep spike_file{i}(1:3) '.dat'], spikeTimes(1:100:length(spikeTimes))/10000,1);
        else
            [t,LaserWV] = LoadTT_NeuralynxNT_old([dataPath filesep spike_file{i}(1:3) '.ntt'], laserEvokedSpikesTiming,1);
            % get some random spikes
            [t,NoLaserWV] = LoadTT_NeuralynxNT_old([dataPath filesep spike_file{i}(1:3) '.ntt'], spikeTimes(1:100:length(spikeTimes)),1);
        end
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

    
    responses = setupResponses(spikeTS,lickTimes,[], 'laserEvokedSpikesLatency',laserEvokedSpikesLatency,  ...
        'meanLaserWaveform',meanLaserWV, 'stderrLaserWaveform',seLaserWV, ...
        'meanNoLaserWaveform',meanNoLaserWV, 'stderrNoLaserWaveform',seNoLaserWV);
    
    %save the final celldata
    saveCellData(saveFile, events, responses, [], saveBatchFile);
end
%%
