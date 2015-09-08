function lightResult = checkLaserSingleUnit(dataFile)

% extract laser pulses with particular frequency
    load(dataFile);
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
    lowSaltP =  setup_salt(dataFile,LowFreqLaser);
    % salt at all freq stimulation
    highSaltP = setup_salt(dataFile,HighFreqLaser);

    %setup_salt([ProcessedDataPath filesep dataFile{i}],laserOnset);

    %% calculate waveform correlation
    % find waveforms contributing to salt
    ll = checkLaser.LaserEvokedPeak;
    jitterRange = [mean(ll(~isnan(ll))) - std(ll(~isnan(ll)))  median(ll(~isnan(ll))) +std(ll(~isnan(ll)))];
    latency= nanmedian(ll);
    idx = find((ll>jitterRange(1))&(ll<jitterRange(2)));
    SponWV = checkLaser.Raw_Spon_wv;
    EvokedWV = checkLaser.Raw_wv;
    if (~isempty(idx))&&(length(idx)>5)&&(size(SponWV,1)>5)
        EvokedTimingWV = EvokedWV(idx,:,:);
        wvCorrAll = calculateWVcorrelation(SponWV,EvokedWV);
        wvCorrSpecific = calculateWVcorrelation(SponWV,EvokedTimingWV);
    else
        wvCorrAll = nan;
        wvCorrSpecific = nan;
    end
    lightResult.lowSaltP = lowSaltP;
    lightResult.highSaltP = highSaltP;
    lightResult.wvCorrAll = wvCorrAll;
    lightResult.wvCorrSpecific = wvCorrSpecific;
    lightResult.latency = latency;