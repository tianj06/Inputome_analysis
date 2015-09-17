raw_data_path = 'F:\All rabies behavioral data\';
savePath = 'C:\Users\uchidalab\Dropbox (Uchida Lab)\lab\temp behavior data\results\'
d = dir(raw_data_path);
folders = {d(find(vertcat(d.isdir))).name};
folders = folders(cellfun(@(x)length(x)>=3,folders));
if find(strcmp(folders,'results'))
    folders(find(strcmp(folders,'results'))) = [];
end
errorFile = {};
for i = 1:length(folders)
    animalName = folders{i};
    animalPath = [raw_data_path animalName '\'];
    % get names of folders which contains each day's data
    d = dir(animalPath);
    fd = {d(find(vertcat(d.isdir))).name};
    fd = fd(cellfun(@(x)length(x)>3,fd));
    for j = 1:length(fd)
        if ~exist([savePath animalName '\' fd{j} 'behavior.mat'],'file')
            cd([raw_data_path animalName '\' fd{j}])
            try
                AnalTrainingBehaviorLabview(savePath, 0)
            catch
                errorFile = [errorFile, [animalName fd{j}]];
            end
        end
    end
end

