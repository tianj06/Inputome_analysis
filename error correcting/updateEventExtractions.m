% fix the wrong event files for old mitsuko's data
function updateEventExtractions(fn,rawDataPath)

% fn formatted data name
% rawDataPath folder contains original data file
% version 1, fit free water all time [100,100,100,86,0,0]
[animalName, folder, ~] = extractAnimalFolderFromFormatted(fn);
if ~strcmp(rawDataPath(end), filesep)
    rawDataPath = [rawDataPath filesep];
end
%% Load events from Events.nev
events = struct('Timestamps', 'Ttls');
[events.Timestamps, events.Ttls] = ...
    Nlx2MatEV([rawDataPath animalName '\' folder '\Events.nev'],[1 0 1 0 0] ,0 ,1 );

% now parse into the correct codes
TTLs = events.Ttls';
temp = zeros(length(TTLs),16);
for i = 1:length(TTLs)
    temp(i,:) = dec2binvec(TTLs(i),16);
end
TTLs = temp;
TTLs = fliplr(TTLs); %de2bi yields big bits on right so need to flip order
events.Timestamps = events.Timestamps./1000; %convert to ms
%% special treatment for odor laser on session
%TTLs(1:500,[12 16]) = zeros(500,2);
%% only needed for new Neuralynx data
reduntIdx = find(diff(events.Timestamps)==0);
if ~isempty(reduntIdx)
    events.Timestamps(reduntIdx+1) = [];
    TTLs (reduntIdx+1,:) = [];
end
%%

digLaser = 11; % or 11
digOdor4 = 12;  %airpuff cue
digOdor3 = 15;   %10% cue
digOdor2 = 13;  %50% cue
digOdor1 = 14;   %90%cue
digWater = 10;
digAirpuff = 9;% and 6

if sum(TTLs(:,9)==1)/sum(size(TTLs,1)) > 0.3  
    TTLs(:,9) = ~TTLs(:,9);
end
if sum(TTLs(:,6)==1)/sum(size(TTLs,1)) > 0.3  
    TTLs(:,6) = ~TTLs(:,6);
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
            tempRewardOn = events.Timestamps(tempind+2);
            if tempRewardOn - odorOn(i) < 2500      
                rewardOn(i) = events.Timestamps(tempind+2);
                trialType(i) = ttCuncertainUwater;
            else
                trialType(i) = ttCuncertainUnothing;
            end
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
            tempRewardOn = events.Timestamps(tempind+2);
            if tempRewardOn - odorOn(i) < 2500     
                rewardOn(i) = events.Timestamps(tempind+2);
                trialType(i) = ttCwaterUwater;
            else
                trialType(i) = ttCwaterUnothing;
            end
        else
            trialType(i) = ttCwaterUnothing;
        end
    elseif TTLs(tempind,digOdor4)   %Cairpuff
        odorOn(i) = events.Timestamps(tempind);
        odorOff(i) = events.Timestamps(tempind+1);
        odorID(i) = 4;
        if TTLs(tempind+2,digAirpuff)
            tempRewardOn = events.Timestamps(tempind+2);
            if tempRewardOn - odorOn(i) < 2500            
                airpuffOn(i) = events.Timestamps(tempind+2);
                trialType(i) = ttCairpuffUairpuff;
            else
                trialType(i) = ttCairpuffUnothing;
            end
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
%%

a = [round(sum(trialType==ttCwaterUwater)/sum(odorID==3)*100)
round(sum(trialType==ttCuncertainUwater)/sum(odorID==1)*100)
round(sum(trialType==ttCnothingUwater)/sum(odorID==2)*100)
round(sum(trialType==ttCairpuffUairpuff)/sum(odorID==4)*100)
sum(trialType==ttUwater)
sum(trialType==ttUairpuff)
]';
%% setup events structure
if max(abs(a(1:4) - [90 50 10 90]))>15 || a(5)>40 || a(6) > 40
    a
    fn
else
    events = setupEvents(ntrials, odorOn, odorOff, odorID, [], [], rewardOn, airpuffOn, ...
                     [], [], trialType, [], [], freeLaserOn);
    save(fn,'-append','events')
end
%%
