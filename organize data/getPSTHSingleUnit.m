function analyzedData = getPSTHSingleUnit(filename) 
    pretrigger = 1000;
    posttrigger = 4000;
    rocBin = 100;
    binNum = (pretrigger + posttrigger)/rocBin;
    load(filename)
    trigger = {events.odorOn(events.trialType==1)
        events.odorOn(events.trialType==3)
        events.odorOn(events.trialType==5)
        events.odorOn(events.trialType==7)
        events.odorOn(events.trialType==2)
        events.odorOn(events.trialType==4)
        events.odorOn(events.trialType==6)
        events.odorOn(events.trialType==8)
        events.rewardOn(events.trialType==9)-2000
        events.airpuffOn(events.trialType==10)-2000
        events.odorOn(events.odorID == 3)
        events.odorOn(events.odorID == 1)
        events.odorOn(events.odorID == 2)
        events.odorOn(events.odorID == 4)
        }; % 90% reward

     [~, r, psths] = plotPSTH(responses.spike, trigger, pretrigger, posttrigger, ...
          'plotflag', 'none','smooth','n');
     for j = 1:length(trigger)
         if j ==3|j==5|j==8
            smoothPSTH(j,:) = smooth(psths(j,:),200); 
         else
            smoothPSTH(j,:) = smooth(psths(j,:),100);
         end
         baseline = [];
         for n = 1:pretrigger/rocBin
             if j==3|j==5|j==8
                 temp = sum(r{1}(:,rocBin*(n-1)+1:rocBin*n),2);
             else
                 temp = sum(r{j}(:,rocBin*(n-1)+1:rocBin*n),2);
             end
             baseline = [baseline; temp];
         end
        for k = 1:binNum
            s = sum(r{j}(:,rocBin*(k-1)+1:rocBin*k),2);
            try 
                rocPSTH(j,k) = auROC(s,baseline);
            catch
                rocPSTH(j,k) = nan;
            end
        end   
     end
     [~, r, psths] = plotPSTH(responses.spike, trigger, pretrigger, posttrigger, ...
          'plotflag', 'none','smooth','n');
    analyzedData.smoothPSTH = smoothPSTH;
    analyzedData.rawPSTH = psths;
    analyzedData.rocPSTH = rocPSTH;
    analyzedData.raster = r;
    analyzedData.psthName = {'90%water','50% reward','10% reward','80% airpuff',...
            'omission 90% water','omission 50% reward','omssion 10% reward',...
            'omission airpuff','free reward','free airpuff'};
        
    [~, r, psths] = plotPSTH(responses.lick, trigger, pretrigger, posttrigger, ...
          'plotflag', 'none','smooth','n');        
    analyzedData.rawLick = psths;
