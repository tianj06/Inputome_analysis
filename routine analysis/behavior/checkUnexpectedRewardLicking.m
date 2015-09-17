function checkUnexpectedRewardLicking(fileName)
if nargin <1
     [fileName, ~] = uigetfile(['*.mat'],...
    'Pick one MATLAB data files.','MultiSelect','on');
end

if ~iscell(fileName)
     load(fileName)
    trialType = events.trialType;
    rewarddOn = events.rewardOn;
    vari = responses.lick;
    trigger = [];
    if ~isempty(find(trialType==5))
        trigger{1} = rewarddOn(trialType==5);
        if ~isempty(find(trialType ==9))
            trigger{2} = rewarddOn(trialType==9);
        end
    end

    Pbefore = 1000;
    Pafter = 4000;
    figure;
    n = length(trigger);
    for i = 1: length(trigger)
                subplot(n,1,i)
                triggered_lick = triggered_average_rate (trigger{i}, vari, -Pbefore,Pafter);
                rasterPlotOriginal(triggered_lick);
                m = size(triggered_lick,1);
                hold on; plot([Pbefore Pbefore], [0 m])
                xlim([1,Pbefore+Pafter-1])
                ylim([1, m+1])
                ylabel('trialNum')
                xlabel('s')
                set(gca,'xtick',[1:1000:5000],'xticklabel',{'-1','0','1','2','3'})
                if i ==1
                    title('10% reward')
                elseif i ==2
                    title('free reward')
                end
    end
else
    for k = 1:length(fileName)
         checkUnexpectedRewardLicking(fileName{k})
    end
end