function [allPSTH, averagePSTH, norAllPSTH]= getAveragePSTH_filelist(fileList,type)
        if nargin ==1
            type = 1;
        end
        pretrigger = 1000;
        posttrigger = 4000;
        psthValue = zeros(length(fileList),14,5001);
        rocBin = 100;
        binNum = (pretrigger + posttrigger)/rocBin;
        for i = 1:length(fileList)
            load(fileList{i})
           
            trigger = {events.odorOn(events.trialType==1)
                events.odorOn(events.trialType==3)
                events.odorOn(events.trialType==5)
                events.odorOn(events.trialType==7)
                events.odorOn(events.trialType==2)
                events.odorOn(events.trialType==4)
                events.odorOn(events.trialType==6)
                events.odorOn(events.trialType==8)
                events.rewardOn(events.trialType==9)
                events.airpuffOn(events.trialType==10)
                events.odorOn(events.odorID==3)
                events.odorOn(events.odorID==1)
                events.odorOn(events.odorID==2)
                events.odorOn(events.odorID==4)
                }; % 90% reward
            if type == 1 
                responseInterested = responses.spike;
            elseif type ==0
                responseInterested = responses.lick;
            end
             [~, r, psths] = plotPSTH(responseInterested, trigger, pretrigger, posttrigger, ...
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
                        norAllPSTH(i,j,k) = auROC(s,baseline);
                    catch
                        norAllPSTH(i,j,k) = nan;
                    end
                end   
             end
             psthValue(i,:,:) = smoothPSTH; 

        end
        if length(fileList)>1
            averagePSTH = squeeze(nanmean(psthValue));
        else
            averagePSTH = squeeze(psthValue);
        end
        allPSTH = psthValue;
end