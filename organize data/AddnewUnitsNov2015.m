%addNewAnimalsData

homepath = 'C:\Users\uchidalab\Dropbox (Uchida Lab)\lab\FunInputome\rabies\';

areaFolders = {'rabies_VS','rabies_VP','rabies_PPTg','rabies_PPTg'};

desFormattedDataPath = [homepath '\analysis2015Fall\new units 2015Nov\'];


%% read excelsheet about units infor
excelDoc = [homepath 'NeuronAddedNov2015.xlsx'];
[~,sheets] = xlsfinfo( excelDoc );
for i =1:length(sheets)
    [num txt all] = xlsread(excelDoc,sheets{i});
    % num: 1st colum Tetrode 3rd colum unit ID
    % txt: 1st row, variable name; 2colum date
    AnimalName = sheets{i};
    SourceFormattedDataPath = [homepath areaFolders{i} '\formatted\'];
    dataFiles = rdir([SourceFormattedDataPath '*.mat']);
    dataFiles = {dataFiles.name};
    for j = 1:size(num,1)
        % extract recording time information
        date = txt{j+1,2};
        Merged = 0;
        if strcmp(date(1),'M')
            Merged =1;
            date(1) = [];
        end
        ind = strfind(date,'/');
        Month = date(1:ind(1)-1);
        if length(Month)==1
            Month = ['0' Month];
        end
        Day = date(ind(1)+1:ind(2)-1);
        if length(Day) ==1
            Day = ['0' Day];
        end
        Year = date(ind(2)+1:end);
        RecordTime = [Year '-' Month '-' Day];
        
        ind = strfind(dataFiles, [AnimalName '_' RecordTime]);
        nameMatch = find(~cellfun('isempty', ind));
        
        % extract unit information
        UnitName= ['TT' num2str(num(j,1)) '_' num2str(num(j,3))];
        ind = strfind(dataFiles, UnitName);
        a = find(~cellfun('isempty', ind));
        
        UnitName= ['TT' num2str(num(j,1)) '_0' num2str(num(j,3))];
        ind = strfind(dataFiles, UnitName);
        b = find(~cellfun('isempty', ind));
        UnitMatch = [a b];
        
        %file with both Unit match and Name match is the right one
        fileIdx = intersect(nameMatch,UnitMatch);
        if Merged
             ind = strfind(dataFiles, 'merged');
             MergeMatch = find(~cellfun('isempty', ind));
             fileIdx = intersect(fileIdx,MergeMatch);
        end
            
        if isempty(fileIdx)
            fn =  [AnimalName '_' RecordTime '*' UnitName];
            disp(['Miss formatted data' fn]);
        else
            [~,filename, ext] = fileparts(dataFiles{fileIdx});
            desFile = [desFormattedDataPath filename ext];
            if ~exist(desFile,'file')
                copyfile(dataFiles{fileIdx}, desFile);
            end
        end
    end
end
%% add analyzed data, brain area, and rabies date to the new data
animalRabiesDate = ['C:\Users\uchidalab\Dropbox (Uchida Lab)\lab\FunInputome\animalRabiesDate.xlsx'];
T = readtable(animalRabiesDate,'Sheet','Sheet1');

fl = what(desFormattedDataPath);
fl = fl.mat;
for i = 1:length(fl)
    fn = fl{i};
    [animal,~,~] = extractAnimalFolderFromFormatted(fn);
    if strcmp(animal,'Uno')
        area = 'VP';
    elseif strcmp(animal,'Rubytuesday')
        area = 'VS';
    elseif strcmp(animal,'Wagamama')
        area = 'RMTg';
    end
    analyzedData = getPSTHSingleUnit(fn);
    save([desFormattedDataPath fn],'-append','area','analyzedData');
    updateRabiesDate(fn, T)
end

%% detect light responsive units
flall = what(pwd);
flall = flall.mat;
% add extra information about light response: check whether a unit is
% inhibited by laser. If inhibited, it should be removed from later
% analysis
for i = 1:length(flall)
    clear checkLaser
    load(flall{i})
    if exist('checkLaser','var')
        if ~isfield(checkLaser,'p_inhibit')
             trigger = events.freeLaserOn;
             [~, r, ~] = plotPSTH(responses.spike, trigger, 20, 20, ...
              'plotflag', 'none','smooth','n');
            checkLaser.p_inhibit = signrank(sum(r{1}(:,11:20),2), sum(r{1}(:,21:30),2),'tail','right' );
            save(flall{i},'-append','checkLaser') 
        end
    end
end
p = [];
for i = 1:length(flall)
    load(flall{i},'lightResult','checkLaser')
    if exist('lightResult','var')&&exist('checkLaser','var')
        llatency(i) = lightResult.latency; 
        llowSalt(i) = lightResult.lowSaltP; 
        lhightSalt(i) = lightResult.highSaltP; 
        lwvcorr(i) = lightResult.wvCorrAll; 
        ljitter(i) = nanstd(checkLaser.LaserEvokedPeak);
        p(i) = checkLaser.p_inhibit;
        %brainAreaAll{i} = area;
        %lightResult.wvCorrSpecific
        clear lightResult checkLaser;
    else
        disp([flall{i} ' missing lightResult or checkLaser'])
        llatency(i) = nan; 
        llowSalt(i) = nan; 
        lhightSalt(i) = nan; 
        lwvcorr(i) = nan; 
        p(i) = nan;
    end
end

llowSalt(llowSalt==0) = 0.001;
lhightSalt(lhightSalt==0) = 0.001;

%% criteria for light responses:
lowSaltCR = 0.01;
highsalt = 0.01;
wvcorrCR = 0.9;
lightIdx = (llowSalt<lowSaltCR)&(lhightSalt< highsalt)&(lwvcorr>wvcorrCR)&(p>0.05);
lightfiles = flall(lightIdx);
lightlatency = llatency(lightIdx);
lightjitter = ljitter(lightIdx);
%%
fid = fopen('C:\Users\uchidalab\Dropbox (Uchida Lab)\lab\FunInputome\rabies\analysis2015Fall\new_by_area2.txt','wt');
oldanimal = '';
for i = 1:length(lightfiles)
    % count neuron number belong to this
    animal = extractAnimalFolderFromFormatted(lightfiles{i});
    if ~strcmp(animal,oldanimal)
        oldanimal = animal;
        %fprintf(fid,'\n');
        fprintf(fid,'%s neuron dates: \n',animal);
    end
    load(lightfiles{i},'rabiesDate');
    fprintf(fid,'%d, \t',rabiesDate);
    clear rabiesDate
end

%% add sushi brain area
area = 'PPTg';
for i = 1:length(flall)
    animal = extractAnimalFolderFromFormatted(flall{i});
    if strcmp(animal,'Sunflower')
        save(flall{i},'-append','area');
    end
end
%% copy all lightID units to light folder
lightFolder = 'C:\Users\uchidalab\Dropbox (Uchida Lab)\lab\FunInputome\rabies\analysis2015Fall\newLight\';
for i = 1:length(lightfiles)
    animal = extractAnimalFolderFromFormatted(lightfiles{i});
    if strcmp(animal,'Sushi')
        copyfile(lightfiles{i},[lightFolder lightfiles{i}]);
    end
end