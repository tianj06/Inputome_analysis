function unitsummary(filename,initialDate,rawdataPath)
load(filename)
%%
figure; set(gcf,'Position',[300 200 1200 1100]);

p=panel();
p.pack('v',[0.23, 0.6 -1]);
p(1).pack('h',[0.6 -1]); % left wvform, right quality chart
p(1,1).pack('h',4);
p(2).pack('h',2);
p(2,1).pack('v',4);
p(2,2).pack('v',2);

%%
% plot average waveform
nonEvokedSpikeWaveforms = checkLaser.Raw_Spon_wv;
evokedSpikeWaveforms = checkLaser.Raw_wv;


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

if ~isempty(Nevoked)
    yl(1) = 1.2*min(min(meanEW));
    yl(2) = 1.2*max(max(meanEW));
    for i = 1:4
        p(1,1,i).select();
        WVcorr(i) = corr(meanEW(i,:)',meanSW(i,:)');
        errorbar_patch(1:32, meanEW(i,:), stdEW(i,:),'k');
        hold on;
        errorbar_patch(1:32, meanSW(i,:), stdSW(i,:),'b');    
        title(['wire' num2str(i)]);
        axis tight
        ylim(yl);
        axH = gca;
        if i ==1
            %legend('Evoked','Spontanous')
        end
    end
else
    WVcorr = nan(1,4);
end

%%
% plot iti distriution
p(2,1,1).select();
O_HistISI(responses.spike/1000);
%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%
% % AutoCorrs
% %%%%%%%%%%%%%%%%%%%%%%%%%%%
binSize = 1; % in ms
width = 50; %in ms
xrange = 0:binSize:width;
nBins = length(xrange);
p(2,1,2).select();
[ACD,xrange] = O_AutoCorr(responses.spike, binSize, nBins);
bar(xrange, ACD, 'FaceColor', 'c');
title('autoCorr');
%% plot light latency
p(2,1,3).select();
LaserOnset = events.freeLaserOn;
postLaseSpikeTime = zeros(length(LaserOnset),31);
k = 0;
for i=1:length(LaserOnset)
    idx = find((responses.spike>LaserOnset(i)-15)& (responses.spike<(LaserOnset(i)+15)));
    nearestspikes=responses.spike(idx);
    if ~isempty(nearestspikes)
         k=k+1;
         postLaseSpikeTime(i,round(nearestspikes-LaserOnset(i))+16)=1;
    end
end
xbar = -15:15;
bar(xbar, sum(postLaseSpikeTime));
title('Spike distr after Laser');
xlabel('(ms)');
xlim([-15 15]);
%% 
p(2,1,4).select();
if length(checkLaser.responsesProb)==6
    plot([1 5 10 20 50], checkLaser.responsesProb([1 3 4 5 6]),'o-');
elseif length(checkLaser.responsesProb)==5
    plot([1 5 10 20 50], checkLaser.responsesProb);
else
    plot(checkLaser.responsesProb)
    xlabel('unknown freq')
end
title('Laser probability')
%% plot psth 

psth = analyzedData.smoothPSTH;

CueColor= [  0 	0 	255;%blue  
             30 	144 	255;%light blue  
             128 	128 128;
             255 0 0]/255; % grey
trialType = [1 2 3 4];
 % 1 90% reward 2 50% reward 3 10% reward 4 airpuff
 % 5 10% reward omission 6 50% omission 7 90% omission 8 airpuff omission
 % 9 free reward 10 free airpuff
p(2,2,1).select();
for i = 1:2
        plot(psth(trialType(i),:),'color',CueColor(i,:),'LineWidth',1)
        i = i+1;
        hold on
end
plot(2101:5000, psth(9,101:3000),'color','k','LineWidth',1) % free reward
trialType = 5:7;
for i = 1:3
        plot(psth(trialType(i),:),'color',CueColor(i,:),'LineWidth',1,'LineStyle','--')
        i = i+1;
        hold on
end
%legend('90% water','50% water','free water','OM 90%','OM 50%','OM 10%');  
xlim([100 4800])


p(2,2,2).select();
plot(psth(4,:),'r','LineWidth',1)
hold on;
plot(psth(8,:),'color',[0.5 0.5 0.5],'LineWidth',1)
plot(2101:5000, psth(10,101:3000),'color','k','LineWidth',1)

%legend('predicted puff','puff omission','free puff');  
xlim([100 4800])

%% display quality chart
% extract L-ratio
% extractFeatures FD n*m array, n spike num, m number of feature
[~, fn] = fileparts(filename);
[animalName, folderName, unitName] = extractAnimalFolderFromFormatted(fn);
if strcmp(rawdataPath(end),filesep)
    rawdataPath = rawdataPath(1:end-1);
end

dataPath = [rawdataPath '\' folderName '\'];
%checkClusterFile = [dataPath unitName '-CluQual.mat'];
% if exist(checkClusterFile)
%     load(checkClusterFile)
%     df = CluSep.L_Ratio.df;
%     Lratio = CluSep.L_Ratio.Lratio;
% else
    % has to compute L-ratio again
if exist([dataPath unitName(1:3) '.dat'])
    loadingEngine =  1; % intan   
elseif exist([dataPath unitName(1:3) '.ntt'])
    loadingEngine = 0; % neuralynx
end
%%
cd(dataPath)
FeatureToUse{1} = {'Energy','WavePC1','WavePC2'};
FeatureToUse{2} = {'Peak','WavePC1','WavePC2'};
FeatureToUse{3} = {'Valley','WavePC1','WavePC2'};
l = [];
for i = 1:3
    currentFeatures = FeatureToUse{i};
    if exist( [dataPath unitName(1:3) '_wavePC1.fd'] )
        [L, cv]= caluclateLratio_MClust3_5(unitName,currentFeatures ,loadingEngine);
    else
        [L, cv ]= caluclateLratio_Mclust4(unitName, currentFeatures,loadingEngine);
    end
    CluSep(i).L_Ratio= L.Lratio;
    CluSep(i).df= L.df;
    CluSep(i).ChannelValidity = cv;
    CluSep(i).Features = currentFeatures;
    l(i) = L.Lratio;
end
Lratio = min(l);
save(filename,'-append','CluSep')    
%%

p(1,2).select();
xlim([-0.3 2])
ylim([-0.3 3])
text(0,0, sprintf('Lratio  %0.3f',Lratio),'FontSize',14)
text(0,0.8, sprintf('saltPlow  %0.3f',lightResult.lowSaltP),'FontSize',14)
text(0,1.6, sprintf( 'saltPhigh  %0.3f' ,lightResult.highSaltP),'FontSize',14)
text(1,0, sprintf('WVcorr  %0.3f' ,lightResult.wvCorrSpecific),'FontSize',14)
text(1,0.8, sprintf('lightLatency  %2.1f' ,lightResult.latency),'FontSize',14)
if exist('TimeAlign','var')
    tshift = TimeAlign.TimeShift;
else
    tshift = 0;
end
text(1,1.6, sprintf('TimeAlign  %1.1f' ,tshift),'FontSize',14)
axis off
% extract recording date
recordDate = datenum(str2num(folderName(1:4)),...
    str2num(folderName(6:7)), str2num(folderName(9:10)));
rabiesDate = recordDate -initialDate;
save(filename,'-append','rabiesDate');
text(0.5,2.4, ['rabies date' num2str(rabiesDate)],'FontSize',14)
%% plot baseline;
tstart = min(events.odorOn(1), events.freeLaserOn(1));
tend = max(events.odorOff(end), events.freeLaserOn(end));
bin = 5000;
trigger = tstart:bin-1:tend;
bl = sum(triggered_average_rate(trigger,responses.spike,0,bin-1),2)*1000/bin;
bl = smooth(bl);
p(3).select();
plot((trigger-tstart)/60000,bl)
xlabel('min')
title('Baseline')
ylabel('Spikes/s')

end