%average_lick_across_days_rabies

% for each animal 
% output1: struct: field as date, the value for field is:  x time 0-5s 50ms bin 100bins, y four conditions

raw_data_path = 'F:\All rabies behavioral data\';
extracted_behavior_path = 'C:\Users\uchidalab\Dropbox (Uchida Lab)\lab\temp behavior data\results\';

%% get all anmals' names for analysis
%animalNames = {'Les','Northwest'};
d = dir(raw_data_path);
fd = {d(find(vertcat(d.isdir))).name};
animalNames = fd(cellfun(@(x)length(x)>=3,fd));

%%



homePath = 'C:\Users\uchidalab';
animalRabiesDate = [homePath '\Dropbox (Uchida Lab)\lab\FunInputome\animalRabiesDate.xlsx'];
T = readtable(animalRabiesDate,'Sheet','Sheet1');

results = cell(1,6);
l = 1;

for i = 1:length(animalNames)
    animalName = animalNames{i};
    animalPath = [raw_data_path animalName '\'];
    % get rabies date
    ind=find(ismember(lower(T.AnimalName),lower(animalName)));
    datestring = T.Rabies(ind);
    RabiesDate = datetime(datestring,'InputFormat','M/d/yyyy');

    % get names of folders which contains each day's data
    d = dir(animalPath);
    folders = {d(find(vertcat(d.isdir))).name};
    folders = folders(cellfun(@(x)length(x)>3,folders));
    dates = cellfun(@(x) x(1:10),folders, 'UniformOutput',0);
    % if one day has multiple data, pick the biggest one for analysis
    [ind, unique_dates] = grp2idx(dates);
    countOfX = hist(ind,unique(ind));
    redun_dates = find(countOfX>1);
    remove_index = [];
    if ~isempty(redun_dates)
        % calculate the size of different folders belong to the same day
        for j = 1:length(redun_dates)
            tempIdx = find(ind==redun_dates(j));
            max_folder_idx = 0;
            max_folder_size = 0;
            for k = 1:length(tempIdx)
                folderName = folders{tempIdx};
                digi_file_info = dir([animalPath folderName '\digital_data.dat']);
                file_size = digi_file_info.bytes;
                if file_size>max_folder_size
                    max_folder_idx = tempIdx(k);
                    max_folder_size = file_size;
                end
            end
            remove_index = vertcat(remove_index,setdiff(tempIdx, max_folder_idx));
        end
        if ~isempty(remove_index)
            folders(remove_index) = [];
        end
        % for each folder, extract the lick signal
    end
    for j = 1:length(folders)
        try
           date_time = folders{j};
           load([extracted_behavior_path animalName '\' date_time 'behavior.mat'])
           trig = {events.odorOn((events.odorID==3)&(~isnan(events.rewardOn))), ...   ~90% reward
                    events.odorOn((events.odorID==1)&(~isnan(events.rewardOn))), ...   ~50% reward
                    events.odorOn((events.odorID==2)&(isnan(events.rewardOn))), ...   ~90% no reward
                    events.odorOn((events.odorID==4)&(~isnan(events.airpuffOn)))};    % ~90% airpuff
    
            [~,r] = ...
              plotPSTH(responses.lick, trig, 1000, 4000, 'plottype','none', ...
                'smooth','none');  
            an_licks = cellfun(@(x)mean(sum(x(:,2000:3000),2)), r, 'UniformOutput',false); % anticipatory licking
            results{l,1} = animalName;
            results{l,2} = date_time;
            results(l,3:6) = an_licks';
        catch
            results{l,1} = animalName;
            results{l,2} = date_time;
            results(l,3:6) = {nan,nan,nan,nan};
        end
            if isempty(RabiesDate)
                results{l,7} = 1;
            else
                current_date = datetime(date_time,'InputFormat','yyyy-MM-dd_HH-mm-ss'); 
                results{l,7} = current_date < RabiesDate;
            end
            l = l+1;
    end
end

T = cell2table(results,'VariableNames',{'animal','time','al_90','al_50','al_0','al_puff','training_flag'});
writetable(T,[extracted_behavior_path 'all_animal_al.csv'])