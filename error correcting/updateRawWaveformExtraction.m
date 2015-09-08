% to extract raw waveforms from failed file by updating cluster waveforms
rawPath = ''  % rawdata path where the original TT?.dat or TT?.ntt file is stored
filename = 'D:\Dropbox (Uchida Lab)\lab\FunInputome\rabies\rabies_PPTg\formatted\Biscuit_2014-11-05_00-00-00_TT3_01_formatted.mat';
load filename
[~,fn] = fileparts(filename);
[animalName, folder, TTname] = extractAnimalFolderFromFormatted(fn)
[laserEvokedSpikesLatency, meanLaserWV, seLaserWV,...
meanNoLaserWV, seNoLaserWV] = extractClusterWaveform(responses.spike,TTname(1:3),events.freeLaserOn,dataPath);
responses.meanLaserWaveform=meanLaserWV;
responses.meanNoLaserWaveform = meanNoLaserWV;
responses.stderrLaserWaveform = seLasefrWV;
responses.stderrNoLaserWaveform = seNoLaserWV;
save(filename,'-append','resposnes')

