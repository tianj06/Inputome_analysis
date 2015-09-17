%% identify light response neurons
function [lightfiles, lightlatency,lightjitter]= SelectLightResponsiveUnits(brainArea,formattedpath,lowsalt, highsalt,plotflag)
%brainArea = 'Ce';
%formattedpath = ['C:\Users\uchidalab\Dropbox (Uchida Lab)\lab\FunInputome\rabies\rabies_' brainArea '\uniqueUnits\'];
flall = what(formattedpath);
flall = flall.mat;
saveFolder = 'C:\Users\uchidalab\Dropbox (Uchida Lab)\lab\FunInputome\rabies\analysis2015Fall\';
% add extra information about light response: check whether a unit is
% inhibited by laser. If inhibited, it should be removed from later
% analysis
for i = 1:length(flall)
    clear checkLaser
    load(flall{i})
    if exist('checkLaser','var')
        if ~isfield(checkLaser,'p_inhibit')
             trigger = events.freeLaserOn;
             [~, r, ~] = plotPSTH(responses.spike, trigger, 20, 20, ...
              'plotflag', 'none','smooth','n');
            checkLaser.p_inhibit = signrank(sum(r{1}(:,11:20),2), sum(r{1}(:,21:30),2),'tail','right' );
            save(flall{i},'-append','checkLaser') 
        end
    end
end
p = [];
for i = 1:length(flall)
    load(flall{i},'lightResult','checkLaser')
    if exist('lightResult','var')&&exist('checkLaser','var')
        llatency(i) = lightResult.latency; 
        llowSalt(i) = lightResult.lowSaltP; 
        lhightSalt(i) = lightResult.highSaltP; 
        lwvcorr(i) = lightResult.wvCorrAll; 
        p(i) = checkLaser.p_inhibit;
        %brainAreaAll{i} = area;
        %lightResult.wvCorrSpecific
        clear lightResult checkLaser;
    else
        disp([flall{i} ' missing lightResult or checkLaser'])
        llatency(i) = nan; 
        llowSalt(i) = nan; 
        lhightSalt(i) = nan; 
        lwvcorr(i) = nan; 
        p(i) = nan;
    end
end

llowSalt(llowSalt==0) = 0.001;
lhightSalt(lhightSalt==0) = 0.001;
%%
% plot basic statistics about the light identification parameter
figure;
subplot(3,1,1)
hist(log10(llowSalt(p>0.05)))
xlabel('log10(P salt low freq)')
ylabel('# Neurons')
xlim([-3,0])
vline(log10(lowsalt),'k--')
subplot(3,1,3)
hist(log10(lhightSalt(llowSalt<lowsalt & p>0.05)))
xlim([-3,0])
xlabel('log10(P salt high freq) low freq < 0.01')
ylabel('# Neurons')
vline(log10(highsalt),'r--')
subplot(3,1,2)
hist(lwvcorr(llowSalt<lowsalt & p>0.05),0.5:0.05:1)
xlim([0.5,1])
xlabel('wave correlation low freq < 0.01')
ylabel('# Neurons')
vline(0.9,'k--')
suptitle([brainArea ' light response'])
saveas(gcf,[saveFolder brainArea ' light response.fig'])
%%


latencyCR = [1:15];
lowSaltCR = lowsalt;
highSaltCR = [0.01, 1];
wvcorrCR = 0.90; % it seems wvcorr is always bigger than 0.95
numLightIdentified = [];
for i = 1:15
    for j = 1:2
        numLightIdentified(i,j) = sum((llatency<latencyCR(i))&(llowSalt<lowSaltCR)...
            &(lhightSalt<highSaltCR(j))&(lwvcorr>wvcorrCR)&(p>0.05));
    end
end
figure;
plot(latencyCR,numLightIdentified)

ind = find((llowSalt<lowSaltCR)&(lwvcorr>wvcorrCR)&(p>0.05));
for i = 1:length(ind)
    f = flall{ind(i)};
    disp([f(1:end-14) '  ' num2str(llatency(ind(i)))])    
end

%% criteria for light responses:
lightIdx = (llowSalt<lowSaltCR)&(lhightSalt< highsalt)&(lwvcorr>wvcorrCR)&(p>0.05);
lightfiles = flall(lightIdx);
lightlatency = llatency(lightIdx);
lightjitter =  nanstd(checkLaser.LaserEvokedPeak);

%% visualize light identified neurons' response
if plotflag == 1
    summaryPlotOneInputArea(formattedpath, flall, lightIdx,brainArea)
end
