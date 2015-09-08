function [allRasters, allPSTH]= formattedToRasters_filelist(fileList,type)
% type 1 spike data; type 2 lick data
    if nargin ==1
        type = 1;
    end
    pretrigger = 1000;
    posttrigger = 4000;
    allPSTH = zeros(length(fileList),14,5001);
    allRasters = cell(length(fileList),14);
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
         allPSTH(i,:,:) = psths;
         allRasters(i,:) = r';
    end
end