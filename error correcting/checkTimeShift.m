%function plotTimeshiftVsMedianError(dataFile)
% tshift = nan(length(dataFile),1);
% terror = nan(length(dataFile),1);
% 
% for i = 1:length(dataFile)
%     filename = dataFile{i};
%     load(filename)
%     if exist('TimeAlign','var')
%         tshift(i) = TimeAlign.TimeShift(1);
%         terror(i) = median(TimeAlign.DelayValue);
%     end
%     clear TimeAlign
% end
%%
fl = what(pwd);
dataFile = fl.mat;
rawPath = {'F:\LH\','F:\PPTg\','F:\VP\','F:\VTA\','N:\rabiesPPTg\','N:\rabiesRMTg\','N:\rabiesVTA\','M:\rabies\'};
 % rawdata path where the original TT?.dat or TT?.ntt file is stored
TimeAlignErrorProcess = {};
n = 1;
ProcessedDataPath = ['D:\Dropbox (Uchida Lab)\lab\FunInputome\rabies\rabies_PPTg\formatted\'];
savePath = 'D:\Dropbox (Uchida Lab)\lab\FunInputome\Plottings\';
k=1;
for i = 1:length(dataFile)
    filename = dataFile{i};
    load(filename)
    badAlignment = 0;
    if (exist('TimeAlign','var'))
        if median(TimeAlign.DelayValue)>0.5
            badAlignment = 1;
        end
    end
         
    if (~exist('TimeAlign','var'))||badAlignment
        TimeAlignErrorProcess{k} = filename;
        k = k+1;
%         rawfind = 0;
%         for j = 1:length(rawPath)
%             %[ProcessedDataPath,fn] = fileparts(filename);
%             fn = filename;
%             [animalName, folderName, TTname] = extractAnimalFolderFromFormatted(fn);
%             if exist([rawPath{j} animalName '\' folderName], 'dir')
%                 rawdataPath = rawPath{j};
%                 rawfind = 1;
%                 dataPath = [rawPath{j} animalName '\' folderName];
%                 rawHomePath = rawPath{j};
%             end
%         end
%         if rawfind
%             try
%                 [laserEvokedSpikesLatency, meanLaserWV, seLaserWV,...
%                 meanNoLaserWV, seNoLaserWV] = extractClusterWaveform(responses.spike,TTname(1:3),events.freeLaserOn,dataPath);
%                 responses.meanLaserWaveform=meanLaserWV;
%                 responses.meanNoLaserWaveform = meanNoLaserWV;
%                 responses.stderrLaserWaveform = seLaserWV;
%                 responses.stderrNoLaserWaveform = seNoLaserWV;
%                 save(filename,'-append','responses')
% 
%                 plotLaserResponse_SingleNeuron(fn,ProcessedDataPath,rawHomePath);
%                 set(gcf,'units','normalized','outerposition',[0 0 1 1])
%                 saveas(gcf,[savePath fn(1:end-4) 'Light'],'tif')
%                 close all
%             catch EM
%                 TimeAlignErrorProcess{n,1} = fn;
%                 TimeAlignErrorProcess{n,2} = EM.message;
%                 n = n+1;
%             end
%         else
%             fn
%             display('could not find raw data files')
%         end
    end
    clear TimeAlign events responses
end