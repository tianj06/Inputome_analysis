% plotSingleCellVGlut2LH(dataFile,dataPath)
% This function makes some basic plots of the original dataset.
% Inputs:
%   - dataFile: name of the .mat file, no dataPath needed. If omitted, a 
%   dialog box will appear.  You can select multiple files
%   - dataPath: location of the .mat file.  
%   Default is '.../Data/VGlut2_LH/ProcessedNeurons'
% Example: plotSingleCellArchVS('mouseA_2013-03-31_11-33-05_TT2_3_formatted.mat')
% consider using via the wrapper function batchSingleCellFigures_ArchVSD1.m

% Vinod Rao

function plotSingleCellwithRaster(dataFile,dataPath)
%% load the data
if nargin<2
    %dataPath = '/Users/jutian/Documents/lab/recording data/Hebanula lesion/processed neurons';
    dataPath = 'F:\rabies\ProcessedNeurons';
end
if nargin<1 %|| exist([dataPath filesep dataFile],'file')~=2
    tempdir = pwd;
    cd(dataPath)
    [dataFile, dataPath] = uigetfile('*.mat','Pick one (or more) MATLAB data file(s).','MultiSelect','on');
    cd(tempdir)
end
if iscell(dataFile)  %if multiple files were chosen, call this function once per file
    for i = 1:length(dataFile)
        plotSingleCellwithRaster(dataFile{i},dataPath);
    end
    return
end
load([dataPath filesep dataFile]);
%% set up subpanels using panel()
figure('Position',[407 25 1008 781]);
ind = find(dataFile=='_');
expt_datetime = dataFile(ind(1)+1:ind(3)-1);
spike_file = dataFile(ind(3)+1:ind(5)-1);
animalName = dataFile(1:3);
set(gcf,'name',sprintf([animalName ': %s, %s'],expt_datetime,spike_file));
p = panel();
p.pack('v',[0.65,-1]);
p(1).pack('v',2,'h',2);
p(2).pack('h',4);

%% trialType reference
% ttCwaterUwater = 1;
% ttCwaterUnothing = 2;
% ttCuncertainUwater = 3;
% ttCuncertainUnothing = 4;
% ttCnothingUwater = 5;
% ttCnothingUnothing = 6;
% ttCairpuffUairpuff = 7;
% ttCairpuffUnothing = 8;
% ttUwater = 9;
% ttUairpuff = 10;

%% plot PSTH for CS
p(1,1,1).select();
trig = {events.odorOn((events.odorID==3)&(~isnan(events.rewardOn))), ...   ~90% reward
        events.odorOn((events.odorID==1)&(~isnan(events.rewardOn))), ...   ~50% reward
        events.odorOn((events.odorID==2)&(isnan(events.rewardOn))), ...   ~90% no reward
        events.odorOn((events.odorID==4)&(~isnan(events.airpuffOn)))};    % ~90% airpuff
CueColor= [  0 	0 	255;%blue  
                   30 	144 	255;%light blue  
                   128 	128 128; % grey
                    255 0 0]/255; % red
legText = {'Reward cue', '50% cue','No reward cue', 'Airpuff cue'};
[~,r,~,~,~,~,~,~,legh] = ...
  plotPSTH(responses.spike, trig, 1000, 4000, 'plottype','PSTH', ...
    'smooth','psp',50,'legend', legText,...
    'ax',gca,'co',CueColor);
set(legh,'box','off','Location','NorthWest');
plot([0 0],ylim,'k--');
plot([2000 2000],ylim,'k--');
title('Neuron PSTH')

p(1,2,1).select();
for i = 1:length(trig)
    if i ==1
        offset = 0;
    else
        offset = offset+length(trig{i-1});
    end
    rasterPlotOriginal(r{i},CueColor(i,:),offset)
    hline(offset+length(trig{i}),'k')
end
set(legh,'box','off','Location','NorthWest');
ylim([0 offset+length(trig{i})])
plot([1000 1000],ylim,'k--');
plot([3000 3000],ylim,'k--');
xlim([0 5000])
%temp = get(gca,'Children'); set(gca,'Children',flipud(temp));
set(gca,'XTickLabel',{});
%% plot Lick for CS and do stats
p(1,1,2).select();
[~,r,~,~,~,~,~,~,legh] = ...
  plotPSTH(responses.lick, trig, 1000, 4000, 'plottype','PSTH', ...
    'smooth','gaussian',20,'legend', legText,...
    'ax',gca,'responselabel','Lick rate (lick/s)','co',CueColor);
set(legh,'box','off','Location','best');
plot([0 0],ylim,'k--');
plot([2000 2000],ylim,'k--');
title('Behavior')

p(1,2,2).select();
for i = 1:length(trig)
    if i ==1
        offset = 0;
    else
        offset = offset+length(trig{i-1});
    end
    rasterPlotOriginal(r{i},CueColor(i,:),offset)
    hline(offset+length(trig{i}),'k')
end
ylim([0 offset+length(trig{i})])
set(legh,'box','off','Location','NorthWest');
plot([1000 1000],ylim,'k--');
plot([3000 3000],ylim,'k--');
xlim([0 5000])
set(gca,'XTickLabel',{});

%% Plot reward US
p(2,1).select();
trig = {events.rewardOn(events.trialType==1), ...
        events.rewardOn(events.trialType==3), ...
        events.rewardOn(events.trialType==5), ...
        events.rewardOn(events.trialType==9)};
RewardColor = [   
               30 144 255;   % light blue 50% reward
               74	74	74;  % dark grey  10% reward
               0 	0 	255; % blue 90% reward
               0 201 87]/255;               %green free reward 
legText = {sprintf('%d%% reward (n=%d trials)',round(sum(events.trialType==1)/sum(events.odorID==1)*100),length(trig{1})), ...
           sprintf('%d%% reward (n=%d)',round(sum(events.trialType==3)/sum(events.odorID==2)*100),length(trig{2})), ...
           sprintf('%d%% reward (n=%d)',round(sum(events.trialType==5)/sum(events.odorID==3)*100),length(trig{3})),...
           'free reward'};
[~,~,~,~,~,~,~,~,legh] = ...
  plotPSTH(responses.spike, trig, 500, 1000, 'plottype','PSTH', ...
    'smooth','psp',50,'legend', legText,...
    'ax',gca,'co',RewardColor);
plot([0 0],ylim,'k--');
set(legh,'box','off','Location','NorthWest');
xlabel('Time from reward delivery (ms)');
title('Reward responses');
%% Plot no reward US
p(2,2).select();
trig = {events.odorOn(events.trialType==6)+2000, ...
        events.odorOn(events.trialType==4)+2000, ...
        events.odorOn(events.trialType==2)+2000, ...
        events.odorOn(events.trialType==8)+2000};
OmissionColor = [  
                0 	0 	255; % blue 10% reward omission
                74	74	74;  % dark grey  90% reward omission  
                        30 144 255;   % light blue 50% reward omission    
               255 0 0]/255;               %red  airpuff omission  
legText = {sprintf('%d%% no reward (n=%d trials)',round(sum(events.trialType==6)/sum(events.odorID==2)*100),length(trig{1})), ...
           sprintf('%d%% no reward (n=%d)',round(sum(events.trialType==4)/sum(events.odorID==1)*100),length(trig{2})), ...
           sprintf('%d%% omitted reward (n=%d)',round(sum(events.trialType==2)/sum(events.odorID==3)*100),length(trig{3})), ...
           sprintf('%d%% omitted airpuff (n=%d)',round(sum(events.trialType==8)/sum(events.odorID==4)*100),length(trig{4}))};
[~,r,~,~,~,~,~,~,legh] = ...
plotPSTH(responses.spike, trig, 500, 1000, 'plottype','PSTH', ...
    'smooth','box',100,'legend', legText,...
    'ax',gca,'co',OmissionColor);
plot([0 0],ylim,'k--');
set(legh,'box','off','Location','NorthWest');
xlabel('Time from putative reward delivery (ms)');
title('No reward responses');

p(2,3).select();
for i = 1:length(trig)
    if i ==1
        offset = 0;
    else
        offset = offset+length(trig{i-1});
    end
    rasterPlotOriginal(r{i},CueColor(i,:),offset)
    hline(offset+length(trig{i}),'k')
end
set(legh,'box','off','Location','NorthWest');
ylim([0 offset+length(trig{i})])
plot([500 500],ylim,'k--');
xlim([0 1500])
set(gca,'XTick',[0:500:1500],'XTickLabel', {'-500','0','500','1000'})

%% Plot airpuff US
p(2,4).select();
trig = {events.airpuffOn(events.trialType==7)
        events.airpuffOn(events.trialType==10)}; % include out session airpuff
legText = {sprintf('%d%% airpuff (n=%d trials)',round(sum(events.trialType==7)/sum(events.odorID==4)*100),length(trig{1})), ...
           sprintf('free airpuff (n=%d trials)',length(trig{2}))};
[~,~,~,~,~,~,~,~,legh] = ...
  plotPSTH(responses.spike, trig, 500, 1000, 'plottype','PSTH', ...
    'smooth','psp',50,'legend', legText,...
    'ax',gca);
plot([0 0],ylim,'k--');
set(legh,'box','off','Location','NorthWest');
xlabel('Time from airpuff delivery (ms)');
title('Aversive responses');

