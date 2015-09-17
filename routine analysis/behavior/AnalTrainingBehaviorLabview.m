function AnalTrainingBehaviorLabview(save_folder, plotflag)
if nargin < 2
    plotflag = 1;
    if nargin <1
       save_folder = 'C:\Users\uchidalab\Dropbox (Uchida Lab)\lab\temp behavior data\results\';
    end
end
%% set up folder
PathName = pwd; % current pathname
[a, date, ~] = fileparts(PathName);
[~, animalName, ~] = fileparts(a);
save_folder = [save_folder  animalName filesep];
saveBatchFile = [save_folder 'batch_data.dat'];

saveFile = [save_folder date 'behavior.mat'];
lick_inhibition_width = 80; 
Threshold = 0.005;
sr = 1000;  % sampling rate
if exist('trial_type.dat', 'file')
    %% read files detect lick time and event time

    digidata = read_binary_digital([PathName, filesep, 'digital_data.dat']); % read digital data
    digievents = reshape(digidata,8,[])';  % digievents: samplepoints * num of digi ports     temp = [];
    temp_events = [];
    temp = [];
    for i = 1:6
        temp = [temp find(diff(digievents(:,i+1)))'];
        temp_events = [temp_events nonzeros(diff(digievents(:,i+1)))'.*i];    
    end
    [timestamps IX] = sort(temp);
    events = temp_events(IX);

    digievents = [timestamps; events; 
                   circshift(events,[0 -2]); circshift(timestamps,[0 2]) ]; % 3*event number matrix
                                                 ...digievents(1,:)== timestamps
                                                 ...digievents(2,:)== events
                                                 ...digievents(3,:)== events shifted by 2 (next event)
    %% set triggers
    ttCwaterUwater = 1;
    ttCwaterUnothing = 2;
    ttCuncertainUwater = 3;
    ttCuncertainUnothing = 4;
    ttCnothingUwater = 5;
    ttCnothingUnothing = 6;
    ttCairpuffUairpuff = 7;
    ttCairpuffUnothing = 8;
    ttUwater = 9;
    ttUairpuff = 10;
    
    % event code:
    % odor1 1 onset -1 offset
    % odor2 2       -2
    % odor3 3       -3
    % odor4 4       -4
    % water 5       -5
    % airpuff 6     -6
    
   odorOnInds = find(ismember(digievents(2,:),[1,2,3,4]));
   freeRewardInds = find( (digievents(2,:)==5) & ...
                       ( (digievents(1,:) - digievents(4,:) > 3000) ));  %extra sanity check to make sure two events previous did not happen within last 3sec
   freeAirpuffInds = find( (digievents(2,:)==6) & ...
                       ( (digievents(1,:) - digievents(4,:) > 3000))); 
    trialStartInds = [odorOnInds, freeRewardInds, freeAirpuffInds];
    trialStartInds = sort(trialStartInds);
    trialStartTimes = digievents(1,trialStartInds);
    ntrials = length(trialStartInds)-1;
    
    odorOn = nan(ntrials,1);
    odorOff = nan(ntrials,1);
    odorID = nan(ntrials,1);
    trialType = nan(ntrials,1);
    rewardOn = nan(ntrials,1);
    airpuffOn = nan(ntrials,1);
    
    for i = 1:ntrials
        tempIdx = trialStartInds(i);
       if digievents(2, tempIdx)==1
            odorOn(i) = digievents(1, tempIdx);
            odorOff(i) = digievents(1, tempIdx+1);
            odorID(i) = 1;
            if digievents(3, tempIdx) ==5
               trialType(i) = 3;
               rewardOn(i) = digievents(1, tempIdx+2);
           else
               trialType(i) = 4;
           end
       elseif digievents(2, tempIdx)==2
            odorOn(i) = digievents(1, tempIdx);
            odorOff(i) = digievents(1, tempIdx+1);
            odorID(i) = 2;
            if digievents(3, tempIdx) ==5
               trialType(i) = 5;
                rewardOn(i) = digievents(1, tempIdx+2);
           else
               trialType(i) = 6;
           end
       elseif digievents(2, tempIdx)==3
            odorOn(i) = digievents(1, tempIdx);
            odorOff(i) = digievents(1, tempIdx+1);
            odorID(i) = 3;
            if digievents(3, tempIdx) ==5
               trialType(i) = 1;
               rewardOn(i) = digievents(1, tempIdx+2);
           else
               trialType(i) = 2;
           end
       elseif digievents(2, tempIdx)==4
            odorOn(i) = digievents(1, tempIdx);
            odorOff(i) = digievents(1, tempIdx+1);
            odorID(i) = 4;
            if digievents(3, tempIdx) ==6
               trialType(i) = 7;
               airpuffOn(i) = digievents(1, tempIdx+2);
           else
               trialType(i) = 8;
           end
       elseif digievents(2, tempIdx)==5
           trialType(i) = 9;
           rewardOn(i) = digievents(1, tempIdx+2);
       elseif digievents(2, tempIdx)==6
           trialType(i) = 10;
           airpuffOn(i) = digievents(1, tempIdx+2);
       end
    end
    
    %% extract lick signal
    lick = read_binary_analog([PathName,filesep, 'analog_data.dat']); % read analog data

    filtered_lick = lowpass_signal(lick,sr,40);
    a = crossing(diff(filtered_lick),[],Threshold);
    
    licktiming = a(1);
    for i = 1:length(a)
        if a(i) - licktiming(end) > lick_inhibition_width
            licktiming = [licktiming a(i)];
        end
    end

    %% save extracted data
   events = setupEvents(ntrials, odorOn, odorOff, odorID, [], [], rewardOn, airpuffOn, ...
                     [], [], trialType, [], [], []);   
    responses.lick = licktiming;
    %save the final celldata
    saveCellData(saveFile, events, responses,[],saveBatchFile);
    
   
     %%   make some plottings
if plotflag ==1
    trigger = {odorOn((odorID==3)&(~isnan(rewardOn))), ...   ~90% reward
        odorOn((odorID==1)&(~isnan(rewardOn))), ...   ~50% reward
        odorOn((odorID==2)&(isnan(rewardOn))), ...   ~90% no reward
        odorOn((odorID==4)&(~isnan(airpuffOn)))};    % ~90% airpuff

    cl = [ 0 	0 	255; ...
          30 	144 	255; ...               
          128 	128 128; ...          
          255 0 0]./255;    % set trigger color
    n_plots = 3;
    
%%  for debugging\
% lick = read_binary_analog([PathName,'/analog_data.dat']); % read analog data
% 
% for j = 1: 10
%     t0 = trigger{3}(j*2);
%     figure(j);plot(lick(t0-500:t0+2000));
%     filtered_lick = lowpass_signal(lick(t0-500:t0+2000),500,20);
%     figure(j);hold on; plot(filtered_lick,'r');
%     plot(diff(filtered_lick),'g');
%     a = crossing(diff(filtered_lick),[],-0.05);
%     licktiming = a(1);
%     for i = 1:length(a)
%         if a(i) - licktiming(end) > lick_inhibition_width
%             licktiming = [licktiming a(i)];
%         end
%     end
%     plot(licktiming,0,'*'); 
% end
% 

 %% check licking signal
%  for i = 1:5:80
%     reward_trial = trigger{3}(i); 
%     
%     figure; plot([lick(reward_trial:reward_trial+4*sr); filtered_lick(reward_trial:reward_trial+4*sr)]'); % see the filtering
%     
%     hold on; plot(diff(filtered_lick(reward_trial:reward_trial+4*sr)),'r')
%     lickdetected = licktiming(find((licktiming > reward_trial) & (licktiming < reward_trial+4*sr)));
%     hold on; plot(lickdetected-reward_trial,1,'*')
%  end

    %% plot average

    Pbefore = 1000; % data points before trigger
    Pafter = 4000; % data points after trigger
    sample_rate = sr; % data points per second
    vari = licktiming;
    lick_bin = 10;
    figure; 

    subplot(n_plots,1,1);
    ox = [Pbefore,Pbefore + 1*sample_rate, Pbefore + 2*sample_rate]*1000/sample_rate;
    oy = 12 ;

    patch([ox(1:2) fliplr(ox(1:2))], [oy oy 0 0],[100 100 100]/256,'edgecolor','none','FaceAlpha',0.2);
    hold on;
    plot([ox(3) ox(3)],[0 oy],'Color','b','LineWidth',2);

    for i = 1: length(trigger)
            triggered_lick = triggered_average_rate (trigger{i}, vari, -Pbefore,Pafter);
            plot_error(triggered_lick,lick_bin,cl(i,:),1000);
            hold on;
    end
    axis tight
    title(date)
    %% plot raster
    % line_space = 0.05;
    % k = 1;
    % for i = 1: length(trigger)
    %     k = k+1;
    %     triggered_lick = triggered_average_rate (trigger{i}, vari, Pbefore, Pafter);
    %     subplot(n_plots,1,k);
    %     for j = 1:size(triggered_lick,1)
    %         rel_spike_t = find(triggered_lick(j,:)==1);
    %         x = ones(3*length(rel_spike_t),1)*NaN;          %the trick is to generate a vector that has NaN to interrupt the lineplot (see also rasterplot in utilities)
    %         x(1:3:end)= rel_spike_t;
    %         x(2:3:end)= rel_spike_t;
    % 
    %         y = ones(3*length(rel_spike_t),1)*NaN;
    %         y(1:3:end)= (j)-1;
    %         y(2:3:end)= y(1:3:end)+1-line_space;
    %         x = x/sample_rate;                                  %scale to seconds
    %         plot(x,y,'color',cl(i,:)); hold on
    %     end        
    %     if i ==1
    %         title('raster plot of licking')
    % 
    %     end
    % end
    % 
    % h=get(gcf,'children');
    % axis(h,'tight');
    % set((h),'XTick',[0:.5:5]);
    % set((h),'XTickLabel',[-1:.5:4]);
    %% plot anticipatory licks

    delay = 1; % delay between odor offset and water onset is 1s
    odortime = 1;
    plottype = [1 3 6 7];
    for i = 1: length(trigger) 
            triggered_lick = triggered_average_rate (trigger{i}, vari, 0, 2*sample_rate);       
            AL{i} = sum(triggered_lick(:,odortime*sample_rate:(odortime+delay)*sample_rate), 2); % calculate the total anticipatory licks for each trial
            if ~isempty(find(trialType==plottype(i),1))
                subplot(n_plots,1,2);plot(find(trialType==plottype(i)),AL{i},'o','MarkerFaceColor',cl(i,:), 'MarkerEdgeColor',cl(i,:));hold on;
            end
            %smoothed_AL = smooth(AL{i},20);
            %figure(h2);plot(smoothed_AL,'color',cl(i,:));title('smoothed anticipatory licking');        
            %hold on;
    end
    title('anticipatoy licking during delay')
    %% plot licks after reward

    delay = 1; % delay between odor offset and water onset is 1s
    odortime = 1;
    for i = 1: length(trigger) 
            triggered_lick = triggered_average_rate (trigger{i}, vari, 0, 3*sample_rate);       
            AL{i} = sum(triggered_lick(:,(odortime+delay)*sample_rate:(odortime+delay+1)*sample_rate), 2); % calculate the total anticipatory licks for each trial
            if ~isempty(find(trialType==plottype(i),1))
                subplot(n_plots,1,3);plot(find(trialType==plottype(i)),AL{i},'o','MarkerFaceColor',cl(i,:), 'MarkerEdgeColor',cl(i,:));hold on;
            end
            %smoothed_AL = smooth(AL{i},20);
            %figure(h2);plot(smoothed_AL,'color',cl(i,:));title('smoothed anticipatory licking');        
            %hold on;
    end
    title('licking after reward')

    %% save data
    saveas(gcf,[save_folder  date '.jpg']);
end
end
end