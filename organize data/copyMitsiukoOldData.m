% copy Mitsuko harddrive data
function copyMitsiukoOldData(homePath)
%% get a list of raw data files
homePath = 'N:\rabiesRMTg\Dragonfly\';
cd(homePath)
dirlist = dir(pwd);
dirName = {dirlist.name};
isdir = [dirlist.isdir];
dirName = dirName(isdir);
dataFolderName = [];
k = 1;
j = 1;
for i = 1:length(dirName)
    if length(dirName{i})==19
        dataFolderName{k} = dirName{i};
        k = k+1;
    end
    if length(dirName{i})==6
        newFolderName{j} = dirName{i};
        j = j+1;
    end
end
%% copy stuff from new folder to original folder
for i = 1:length(newFolderName)
    flist = rdir( [newFolderName{i} '\*.fd']);
    flist = {flist.name};
    fdName = newFolderName{i};
    desFolder = ['20' fdName(1:2) '-' fdName(3:4) ...
        '-' fdName(5:6)];
    ind = strfind(dataFolderName,desFolder);
    ind = find(~cellfun(@isempty,ind));
    desFolder = dataFolderName{ind};
    for j = 1:length(flist)
       [~, filename ext] = fileparts(flist{j});
        movefile(flist{j}, [desFolder '\' filename ext]);
    end
end

%% get a list of potential units
unitsList = importdata('Dragonfly.txt');
unitsList = uniqueRowsCA(unitsList);
strLength = cellfun(@length,unitsList);
unitsList(strLength<15) = [];

newUnitList = {};
BadUnit = zeros(length(unitsList),1);
for i = 1:length(unitsList)
    uName = unitsList{i};
    if strcmp(uName(1),'(')
        BadUnit(i) = 1;
        uName = uName(2:end-1);
    else
        % copy a unit to raw data file
        ind = strfind(uName, '_');
        fdName = uName(ind(1)+1:ind(2)-1);
        unitTTName = [uName(ind(2)+1:ind(2)+3) ...
            '_' uName(ind(2)+5:end)];
        unitFile = [homePath fdName filesep unitTTName '.mat'];
        desFolder = ['20' fdName(1:2) '-' fdName(3:4) ...
            '-' fdName(5:6)];
        ind = strfind(dataFolderName,desFolder);
        ind = find(~cellfun(@isempty,ind));
        desFolder = dataFolderName{ind};
        newUnitList{i} = [desFolder filesep unitTTName '.mat'];
        if ~exist([desFolder filesep unitTTName '.mat'],'file')
            copyfile(unitFile, [desFolder filesep unitTTName '.mat'])
        end
    end
end

%% format all of the units
for i = 1:length(dataFolderName)
    currentFolder = dataFolderName{i};
    cd([homePath currentFolder])
    unitsFile = dir('TT*.mat');
    if ~isempty(unitsFile)
        unitsFile = {unitsFile.name};
        try
            formatNlynxCCtaskData([homePath currentFolder],unitsFile)
        catch EM
            disp(currentFolder)
            disp(EM.message)
        end
    end
end

%% plot PSTH


% for i = 1:length(newUnitList)
%     [currentFolder,a,b]=fileparts(newUnitList{i});
%     try
%         formatNlynxCCtaskData([homePath currentFolder],{[a b]})
%     catch EM
%         disp(currentFolder)
%         disp(EM.message)
%     end
% end