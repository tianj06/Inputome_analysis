%update trial types
%this function fix an early analysis problem in which data recorded from
%neuralynx rigs were assigned wrong trialtypes. A remapping of old
%trialtype value to new trialtype value is necessary to fix it.
%

filelist = what(pwd);
filelist = filelist.mat;

for i = 1:length(filelist)
    load(filelist{i})
    trial1num = length(find(events.trialType==1));
    trial2num = length(find(events.trialType==2));
    trial3num = length(find(events.trialType==3));
    trial4num = length(find(events.trialType==4));
    trial5num = length(find(events.trialType==5));
    trial6num = length(find(events.trialType==6));
    tempType = events.trialType;
    pairRato = [trial1num/trial2num trial3num/trial4num trial5num/trial6num];
    [~,ind] = sort(pairRato,'descend');
    if length(find(ind == [3 1 2]))==3
        newTrialType = [3 4 5 6 1 2];
        idx = find(ismember(events.trialType,[1:6]));
        events.trialType(idx) = events.trialType(idx)*100;
        for j = 1:6
            events.trialType(events.trialType==j*100) = newTrialType(j);
        end
        disp(['fixed ' filelist{i}])
        save(filelist{i},'events','-append');
    elseif length(find(ind == [2 3 1]))==3
        newTrialType = [5 6 1 2 3 4];
        idx = find(ismember(events.trialType,[1:6]));
        events.trialType(idx) = events.trialType(idx)*100;
        for j = 1:6
            events.trialType(events.trialType==j*100) = newTrialType(j);
        end
        disp(['fixed ' filelist{i}])
        save(filelist{i},'events','-append');
    elseif length(find(ind == [1 2 3]))==3
    else
        disp(filelist{i});
        disp('wield trialType')
    end
end