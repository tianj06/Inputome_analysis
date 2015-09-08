function [laserEvokedSpikesLatency, meanLaserWV, seLaserWV,...
    meanNoLaserWV, seNoLaserWV] = extractClusterWaveform(ts,TTname,freeLaserOn,dataPath,laserWindow)
% based on cluster timestamps, extract the mean waveform of lafter laser,
% or spontanous waveform
% input: ts, ms timestamps of spike; freeLaserOn, ms timestamps of laser.
% TTname, such as TT3; dataPath: path contains TT.ntt file
% laserWindow, extract spikes within laserWindow ms of laser onset
if nargin < 5
    laserWindow = 15;
end
    
    spikeTimes = ts*10;
    spikeTS = ts;
    laserEvokedSpikesLatency = nan(length(freeLaserOn),1);
    laserEvokedSpikesTiming = [];
    for m = 1:length(freeLaserOn)
        tempIdx = find((spikeTS>freeLaserOn(m))&(spikeTS<freeLaserOn(m)+laserWindow));
        if ~isempty(tempIdx)
            laserEvokedSpikesLatency(m) = spikeTS(tempIdx(1)) - freeLaserOn(m);
            laserEvokedSpikesTiming = [laserEvokedSpikesTiming spikeTimes(tempIdx(1))]; 
        end
    end
    % extract the waveform of laser evoked spikes
    if exist([dataPath filesep TTname '.ntt'],'file')
        [t,LaserWV] = LoadTT_NeuralynxNT_old([dataPath filesep TTname '.ntt'], laserEvokedSpikesTiming,1);
        % get some random spikes
        [t,NoLaserWV] = LoadTT_NeuralynxNT_old([dataPath filesep TTname '.ntt'], spikeTimes(1:100:length(spikeTimes)),1);
    elseif exist([dataPath filesep TTname '.dat'],'file')
        [t,LaserWV] = LoadingEngineIntan4([dataPath filesep TTname '.dat'], laserEvokedSpikesTiming/10000,1);
        % get some random spikes
        [t,NoLaserWV] = LoadingEngineIntan4([dataPath filesep TTname '.dat'], spikeTimes(100:100:length(spikeTimes))/10000,1);
    else
        error('cannot find TT files')
    end
    % compute average and stderr waveform for laser-triggered spikes
    meanLaserWV = squeeze(mean(LaserWV,1))';
    seLaserWV = squeeze(std(LaserWV,0,1)./sqrt(size(LaserWV,1)))';
    % compute average and stderr waveform for non-laser-triggered spikes
    meanNoLaserWV = squeeze(mean(NoLaserWV,1))';
    seNoLaserWV = squeeze(std(NoLaserWV,0,1)./sqrt(size(NoLaserWV,1)))';

