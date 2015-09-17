% copy Mitsuko harddrive data
function copyMitsiukoOldData(homePath)
%% get a list of raw data files
homePath = 'M:\St\Jay\';
cd(homePath)
dirlist = dir(pwd);
dirName = {dirlist.name};
isdir = [dirlist.isdir];
dirName = dirName(isdir);
dataFolderName = [];
k = 1;
for i = 1:length(dirName)
    if length(dirName{i})==19
        dataFolderName{k} = dirName{i};
        k = k+1;
    end
end

%% get a list of potential units
unitsList = importdata('Jay.txt');
unitsList = uniqueRowsCA(unitsList);
strLength = cellfun(@length,unitsList);
unitsList(strLength<14) = [];

BadUnit = zeros(length(unitsList),1);
k = 1;
for i = 1:length(unitsList)
    uName = unitsList{i};
    if strcmp(uName(1),'(')
        BadUnit(i) = 1;
        uName = uName(2:end-1);
    else
        % copy a unit to raw data file
        timeName = ['2012-' uName(10:11) '-' uName(12:13)];
        if ~isempty(strfind(uName,'00'))
            fd=dataFolderName{find(~cellfun(@isempty,strfind(dataFolderName,[timeName '_00-00-00'])))};
        else
            fd=dataFolderName{find(~cellfun(@isempty,strfind(dataFolderName,timeName)))};
        end
        TTname = [uName(end-4:end-2) '_0' uName(end)];
        unitFile{k} = [TTname '.t'];
        unitFolder{k} = [fd '\'];
        k = k+1;
    end
end

%% format all of the units
for i = 1:length(unitFile)
    currentFolder = unitFolder{i};
    cd([homePath currentFolder])
    unitsFile = unitFile{i};
        try
            formatNlynxCCtaskData([homePath currentFolder],unitsFile)
        catch EM
            disp(currentFolder)
            disp(EM.message)
        end
    
end

%% plot PSTH