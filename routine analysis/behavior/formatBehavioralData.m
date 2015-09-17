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

% Output: saveFile (optional) returns the filename of the saved .mat file
% Example:
%  formatVGlut2LHData(pwd,'TT2_3.mat');

% Vinod Rao
function  [events responses sf] = formatBehavioralData(dataPath,savePath,saveBatchFile)

%% Check data and filenames
% this checks to make sure the required file types are in the folder.
% this may not be necessary. Consider eliminating.

% dataPath = '/Users/vinod3000/Documents/UchidaLab/Data/ArchVS_D1/mouseA/2013-03-31_11-33-05';
% spike_file = 'TT2_3.mat';

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

%check for lick file - something with a 64 or a 25 in the name
rigHide = 0;
rigMitsuko = 0;
if ~isempty(dir('CSC64*'))
    lickFile = dir('CSC64*');
    rigMitsuko = 1;
elseif ~isempty(dir('CSC25*'))
    lickFile = dir('CSC25*');
    rigHide = 1;
else
    error('No file containg licks (assume CSC64 or CSC25) in %s.',dataPath');
end

lickFile = lickFile.name;
% if isstruct(lickFile) %if multiple files, pick the smallest filesize (presumably downsampled).
%     temp = struct2cell(lickFile);
%     temp = cell2mat(temp(3,:));
%     [~,ind] = min(temp);
%     lickFile = lickFile(ind).name;
% end    

if nargin<2
    inds = find(dataPath==filesep,2,'last');
    %savePath = [dataPath(1:inds(1)) 'processed'];
    savePath = ['D:\Dropbox (Uchida Lab)\lab\FunInputome\processed'];
    saveFile = [savePath dataPath(inds(1):end) 'behavior.mat'];
end
if nargin<3
    saveBatchFile = [savePath(1:find(savePath==filesep,1,'last')), 'batchdata.dat'];
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
    digOdor3 = 15;   %90% cue
    digOdor2 = 13;  %0% cue
    digOdor1 = 14;   %50%cue
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
timestamps_shift2 = [zeros(1,2) events.Timestamps(1:end-2)];
freeRewardInds = find( TTLs(:,digWater ) & ...
                       (events.Timestamps - timestamps_shift2 > 3000)' );  %extra sanity check to make sure two events previous did not happen within last 3sec
freeAirpuffInds = find(TTLs(:,digAirpuff )& ...
                        (events.Timestamps - timestamps_shift2 > 3000)' ); 
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
    if TTLs(tempind,digOdor1) %Cwater
        odorOn(i) = events.Timestamps(tempind);
        odorOff(i) = events.Timestamps(tempind+1);
        odorID(i) = 1;
        if TTLs(tempind+2,digWater)
            rewardOn(i) = events.Timestamps(tempind+2);
            trialType(i) = ttCwaterUwater;
        else
            trialType(i) = ttCwaterUnothing;
        end
    elseif TTLs(tempind,digOdor2) %Cuncertain
        odorOn(i) = events.Timestamps(tempind);
        odorOff(i) = events.Timestamps(tempind+1);
        odorID(i) = 2;
        if TTLs(tempind+2,digWater)
            rewardOn(i) = events.Timestamps(tempind+2);
            trialType(i) = ttCuncertainUwater;
        else
            trialType(i) = ttCuncertainUnothing;
        end
    elseif TTLs(tempind,digOdor3)  %Cnothing
        odorOn(i) = events.Timestamps(tempind);
        odorOff(i) = events.Timestamps(tempind+1);
        odorID(i) = 3;
        if TTLs(tempind+2,digWater)
            rewardOn(i) = events.Timestamps(tempind+2);
            trialType(i) = ttCnothingUwater;
        else
            trialType(i) = ttCnothingUnothing;
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
        rewardOn(i) = events.Timestamps(tempind+2);
        trialType(i) = ttUwater;
    elseif TTLs(tempind,digAirpuff) %free airpuff
        airpuffOn(i) = events.Timestamps(tempind+2);
        trialType(i) = ttUairpuff;
    else
        sprintf('No correct type for trial %d.',i)
        keyboard
    end
end

%% detect licks

%load the lickdata
licks = struct('Timestamps', 'Samples');
[licks.Timestamps, licks.Samples] =  Nlx2MatCSC([dataPath filesep lickFile],[1 0 0 0 1],0,1 );
licks.Timestamps = licks.Timestamps/1000;

%compute the sample frequency and low-pass filter to Nyquist corresponding
%to 20Hz, or whatever is defined in maxfreq
maxfreq = 20;
sample_freq = round( 512*10^3/(licks.Timestamps(2)-licks.Timestamps(1)));
[a,b] = butter(3,maxfreq/(sample_freq/2),'low');
filtlick = filtfilt(a,b,licks.Samples(:));
timedata = linspace(min(licks.Timestamps),max(licks.Timestamps)+511/512*diff(licks.Timestamps(1:2)),numel(filtlick));

% run the lick threholding gui to select the licks.
% lickTimes = lickThreshold(filtlick, timedata');
%kluge
lickTimes = find(filtlick>0.2*max(filtlick) & circshift(filtlick,[1 1])<0.2*max(filtlick));
lickTimes = timedata(lickTimes);

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
responses.lick = lickTimes;
sf = saveFile;
%save the final celldata
saveCellData(saveFile, events, responses, [], saveBatchFile);
end
%%
