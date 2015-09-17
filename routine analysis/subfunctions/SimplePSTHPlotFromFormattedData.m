  pretrigger = 1000;
        posttrigger = 4000;

            trigger = {
                events.rewardOn(events.trialType==9)
                events.airpuffOn(events.trialType==10)
                }; % 90% reward
                responseInterested = responses.spike;
             [~, r, psths] = plotPSTH(responseInterested, trigger, pretrigger, posttrigger, ...
                  'plotflag', 'psth','smooth','box',300);