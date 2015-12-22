fl = what(pwd);
fl = fl.mat;
N = length(fl);

for i = 1:length(fl)
    load(fl{i},'analyzedData')
    bl(i) = mean( mean(analyzedData.rawPSTH([1 7],1:1000)));
    load(fl{i},'area');
    brainArea{i} = area;
end
%% add indicator for light responsive unit
fll = what('C:\Users\uchidalab\Dropbox (Uchida Lab)\lab\FunInputome\rabies\analysis2015Fall\newLight');
fll = fll.mat;
lightInd = ismember(fl,fll);
%%
brainArea(ismember(brainArea,{'LH_an','LH_psth','LH_po'})) = {'LH'};
brainArea(ismember(brainArea,{'PPTg_an','PPTg'})) = {'PPTg'};

% change  the name of brain areas
oldnames = {'Striatum','LH','VS','PPTg','RMTg','VP','DA','VTA3','VTA2','STh'};
newnames = {'Dorsal striatum','Lateral hypothalamus','Ventral striatum',...
    'PPTg','RMTg','Ventral pallidum','Dopamine','VTA type3',...
    'VTA type2','Subthalamic'};
oldbrain = brainArea;
for i = 1:length(oldnames)
    idx = ismember(oldbrain,oldnames{i});
    brainArea(idx) = newnames(i);
end
%%
uniqueAreas = unique(brainArea);
uniqueAreas = uniqueAreas(2:end);
for i = 1:length(uniqueAreas)
    ind = strcmp(brainArea, uniqueAreas{i});
    subplot(3,3,i)
    binSize = round(max(bl(ind))/20);
    maxBl = 20*round(max(bl(ind))/20);
    bins = 0:binSize:maxBl;
    lb = hist(bl(ind'&lightInd),bins)/sum(ind'&lightInd);
    nlb = hist(bl(ind'&~lightInd),bins)/sum(ind'&~lightInd);
    bar(bins,[lb; nlb]',1.5)
    title(uniqueAreas{i})
    legend('light','nonlight')
end

fl(strcmp(brainArea', 'Ventral striatum')&bl'>20&lightInd)

%% compute spike width, plot it with baseline
%?? better way to compute wavewidth.
spikeWidth = [];
for i = 1:length(fl)
    load(fl{i},'checkLaser')
    % find channel with biggest response
    if exist('checkLaser','var')
        mwv = squeeze(nanmean(checkLaser.Raw_Spon_wv));
        ams = max(mwv') - min(mwv');
        [~,wireId] = max(ams);    
        wv = reshape(checkLaser.Raw_Spon_wv(:,wireId,:),[],32);
        width = [];
        % method 1 peak to trough
%         for j = 1:size(wv,1)
%             [~,peak] = max(wv(j,:));
%             [~,valley] = min(wv(j,:));
%             width(j) = abs(peak-valley);  
%         end
%         spikeWidth(i) = mean(width);
        % method 2 statistical significant

         if size(wv,1)> 10
%             if size(wv,1)>50
%                 ind = randperm(size(wv,1));
%                 wv = wv(ind(1:50),:);
%             end
%             start = 0;
%             stop = 32;
%             for j = 2:32
%                 if (ttest(wv(:,j)-wv(:,1)))&&(abs(mean(wv(:,j)-wv(:,1)))>5)
%                     start = j;
%                     break
%                 end
%             end  
%             for j = 31:-1:1
%                 if ttest(wv(:,j)-wv(:,32))&&(abs(mean(wv(:,j)-wv(:,32)))>5)
%                     stop = j;
%                     break
%                 end
%             end  
%             width =  stop - start+1;

            % method 3 half width
            mwv = mwv(wireId,:);
            maxa = max(mwv);
            mina = min(mwv);
            if abs(maxa) < abs(mina)
                wv = -wv;
            end
            start = [];
            stop = [];
            for j = 1:size(wv,1)
                halfm = (max(wv(j,:)) - wv(j,1))/2;
                ind=crossing(wv(j,:)-halfm);
                try
                    start(j) = ind(1);
                    stop(j) = ind(end)+1;
                catch
                    start(j) = nan;
                    stop(j) = nan;
                end
            end
            start = nanmean(start);
            stop = nanmean(stop);
            width = stop - start + 1;
        else
            width = nan;
        end
        spikeWidth(i) = width;
        all_start(i) = start;
        all_stop(i) = stop;
     
     else
         spikeWidth(i) = nan;
     end
     clear checkLaser
end
%%
ind = ismember(brainArea', {'Ventral striatum','Dorsal striatum'});
figure;
scatter(spikeWidth(ind)*1000/30,bl(ind))
hold on
scatter(spikeWidth(ind&lightInd)*1000/30,bl(ind&lightInd),'r')

figure;
bins = 50:50:500;
a = hist(spikeWidth(ind&lightInd)*1000/30,bins)/sum(ind&lightInd);
b = hist(spikeWidth(ind&~lightInd)*1000/30,bins)/sum(ind&~lightInd);
bar(bins,[a ;b]',1.5)
legend('light','nonlight')


flind = fl(spikeWidth<=4&ind);
for i = 1:length(flind)
    load(flind{i},'checkLaser')
    % find channel with biggest response
    mwv = squeeze(mean(checkLaser.Raw_Spon_wv));
    figure;
    plot(mwv')
end

flvs_nonlight = fl(strcmp(brainArea', 'Ventral striatum')&~lightInd);
flvs_light = fl(strcmp(brainArea', 'Ventral striatum')&lightInd);
figure;
mwv_nonlight = [];
mwv_light = [];
for i = 1:length(flvs_nonlight)
    load(flvs_nonlight{i},'checkLaser')
    % find channel with biggest response
    mwv = reshape(mean(checkLaser.Raw_Spon_wv,1),4,32);
    ams = max(mwv') - min(mwv');
    [~,wireId] = max(ams);
    mwv_nonlight(i,:) = mwv(wireId,:);
end

for i = 1:length(flvs_light)
    load(flvs_light{i},'checkLaser')
    % find channel with biggest response
    mwv = reshape(mean(checkLaser.Raw_Spon_wv,1),4,32);
    ams = max(mwv') - min(mwv');
    [~,wireId] = max(ams);
    mwv_light(i,:) = mwv(wireId,:);
end

figure;
nonl_m = squeeze(nanmean(mwv_nonlight));
l_m = squeeze(mean(mwv_light));
subplot(2,1,1)
plot(nonl_m')
subplot(2,1,2)
plot(l_m')

figure;
s = all_start(strcmp(brainArea', 'Ventral striatum')&lightInd);
st = all_stop(strcmp(brainArea', 'Ventral striatum')&lightInd);
for i = 1:size(mwv_light,1)
    subplot(5,7,i)
    plot(mwv_light(i,:));hold on;
    vline(s(i))
    vline(st(i))
end