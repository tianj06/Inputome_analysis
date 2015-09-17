clear all;
filePath = 'C:\Users\uchidalab\Dropbox (Uchida Lab)\lab\FunInputome\rabies\rabies_VTA\analysis\DAtype';
cd('C:\Users\uchidalab\Dropbox (Uchida Lab)\lab\FunInputome\rabies\rabies_VTA\formatted\')
fl = dir(filePath);
fl(1:2) = [];
fl = {fl.name};

sigpair = {[11 12],[12 13],[1,2],[5 6]};
windowpair = {[1000 1600],[1000 1600], [3000 3400],[3000 4000]};
sigresult = zeros(length(fl),length(sigpair));
for i = 1:length(fl)
    fn = [fl{i}(1:end-4) '_formatted.mat']; %
    %load(fn)
    %analyzedData = getPSTHSingleUnit(fn); 
    load(fn,'analyzedData');
    psthAll(i,:,:) = analyzedData.rawPSTH;
    rocAll(i,:,:) = analyzedData.rocPSTH;
    r = analyzedData.raster;
    for j = 1:length(sigpair)
        timeWin = windowpair{j}(1):windowpair{j}(2);
        responses = {};
        for k = 1:2
            responses{k} = mean(r{sigpair{j}(k)}(:,timeWin),2);
        end
        [~,sigresult(i,j)] = ranksum(responses{1},responses{2}); 
        responses{k} = mean(r{sigpair{j}(k)}(:,timeWin));
    end
end
%% calculate baseline
b = squeeze(mean(mean(psthAll(:,11:14,1:1000),3),2));
b1 = b;
%% scatter plot for all pairs of events
labels = {'90% cue', '50% cue'; '50% cue','0% cue';'90%W','50%W';'OM 90%W','OM 50%W'};
hfig = zeros(1,4);
for j = 1:length(sigpair)
    timeWin = windowpair{j}(1):windowpair{j}(2);
    responses = squeeze(mean(psthAll(:,sigpair{j},timeWin),3)) - ...
    repmat(b,1,2);
    hfig(j) = figure('Position',[ 377   476   658   295]);
    subplot(1,2,1);
    scatter(responses(:,1),responses(:,2))
    hold on;
    sigIdx = find(sigresult(:,j));
    scatter(responses(sigIdx,1),responses(sigIdx,2),'filled');
    refline(1,0)
    xlabel(labels{j,1})
    ylabel(labels{j,2})
    prettyP('','','','','a')
    percentSig = length(sigIdx)/length(fl);
    title(['percent significant:' num2str(percentSig)])
end

%% do same analysis for AAV dopamine data
filePath = 'C:\Users\uchidalab\Dropbox (Uchida Lab)\lab\FunInputome\rabies\rabies_VTA\analysis\AAVcontrol';
fl = what(filePath);fl = fl.mat;
cd(filePath)
sigpair = {[11 12],[12 13],[1,2],[5 6]};
windowpair = {[1000 1600],[1000 1600], [3000 3400],[3000 4000]};
sigresult = zeros(length(fl),length(sigpair));
for i = 1:length(fl)
    fn = fl{i}; %
    load(fn,'analyzedData')
    %analyzedData = getPSTHSingleUnit(fn); 
    %save(fn,'-append','analyzedData');
    psthAll(i,:,:) = analyzedData.rawPSTH;
    rocAll(i,:,:) = analyzedData.rocPSTH;
    r = analyzedData.raster;
    for j = 1:length(sigpair)
        timeWin = windowpair{j}(1):windowpair{j}(2);
        responses = {};
        for k = 1:2
            responses{k} = mean(r{sigpair{j}(k)}(:,timeWin),2);
        end
        [~,sigresult(i,j)] = ranksum(responses{1},responses{2}); 
        responses{k} = mean(r{sigpair{j}(k)}(:,timeWin));
    end
end
%% calculate baseline
b = squeeze(mean(mean(psthAll(:,11:14,1:1000),3),2));
b2 = b;
%% scatter plot for all pairs of events
labels = {'90% cue', '50% cue'; '50% cue','0% cue';'90%W','50%W';'OM 90%W','OM 50%W'};
for j = 1:length(sigpair)
    timeWin = windowpair{j}(1):windowpair{j}(2);
    responses = squeeze(mean(psthAll(:,sigpair{j},timeWin),3)) - ...
    repmat(b,1,2);
    figure(hfig(j));
    subplot(1,2,2);
    scatter(responses(:,1),responses(:,2))
    hold on;
    sigIdx = find(sigresult(:,j));
    scatter(responses(sigIdx,1),responses(sigIdx,2),'filled');
    refline(1,0)
    xlabel(labels{j,1})
    ylabel(labels{j,2})
    prettyP('','','','','a')
    percentSig = length(sigIdx)/length(fl);
    title(['percent significant:' num2str(percentSig)])
end
%%
figure;
plot(1,b1,'o');
hold on;
plot(2,b2,'o');
set(gca,'xtick',[1,2],'xticklabel',{'rabies','AAV'})
title('Baseline')
ylabel('Spikes/s')
xlim([0.5 2.5])
ranksum(b1,b2)

%{
%% calculate cue responese
a = squeeze(mean(psthAll(:,11:14,1000:1600),3));
a = a-repmat(b,1,4);
figure;
bar([1:4], mean(a));hold on;
plot([1:4],a,'o');
xlim([0.5 4.5])
ylabel('Spikes/s')
set(gca,'xticklabel',{'90%W','50%W','0%W','80%puff',});

p = zeros(1,3);
for i = 1:3
    p(i) = signrank(a(:,i),a(:,i+1));
end
sigstar({[1,2],[2,3], [3,4]},p)
title('Cue response 0-600ms')
%% calculate the US responese
a = squeeze(mean(psthAll(:,[1 2 9],3000:3400),3));
a = a - repmat(b,1,3);

figure;
bar([1:3], mean(a));hold on;
plot([1:3],a,'o');
xlim([0.5 3.5])
ylabel('Spikes/s')
set(gca,'xticklabel',{'90%W','50%W','freeW'});

p = zeros(1,2);
for i = 1:2
    p(i) = signrank(a(:,i),a(:,i+1));
end
sigstar({[1,2],[2,3]},p)
title('Reward response 0-400ms')
%% calcualte omission response
a = squeeze(mean(psthAll(:,[5:7],3000:4000),3));
a = a - repmat(b,1,3);

figure;
bar([1:3], mean(a));hold on;
plot([1:3],a,'o');
xlim([0.5 3.5])
ylabel('Spikes/s')
set(gca,'xticklabel',{'OM 90%W','OM 50%W','OM 0%W'});

p = zeros(1,2);
for i = 1:2
    p(i) = signrank(a(:,i),a(:,i+1));
end
sigstar({[1,2],[2,3]},p)
title('Reward omission 0-1000ms')
%}