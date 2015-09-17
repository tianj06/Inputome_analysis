ProcessedDataPath = 'D:\Dropbox (Uchida Lab)\lab\FunInputome\rabies\rabies_Striatum\uniqueUnits\';

savePath = 'D:\Dropbox (Uchida Lab)\lab\FunInputome\rabies\rabies_Striatum\uniqueUnits\';
% 
fl = what(pwd);
fl = fl.mat;
% 
% [animalNames] = cellfun(@extractAnimalFolderFromFormatted,fl,'UniformOutput',0);
% 
% [idx, uniqueName] = grp2idx(animalNames);

%%
% for i = 1:max(idx)
%     ind = find(idx == i,1,'first');
%     plotSingleCellwithRaster(fl(ind),ProcessedDataPath)
%     fileName = fl{ind}(1:end-14);
%     set(gcf,'units','normalized','outerposition',[0 0 1 1],'PaperPositionMode','auto');
%         saveas(gcf,[savePath fileName 'PSTH'],'tif')
%     close all;
% end

%% 
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

%rawDataPath ='K:\St\';%'M:\rabiesPPTg\';%'O:\LH\'; %'M:\rabiesPPTg\'; % 
% probAnimals = {'Horntail','Dragonfly'};
% probAniIdx = find(ismember(uniqueName,probAnimals));

%load('LightDataSet1')
%%
errorFiles = [];
trialProb = [];
k=1;

for i = 1:length(fl)	
    load(fl{i})
    trialType = events.trialType;
    odorID = events.odorID;
    a = [round(sum(trialType==ttCwaterUwater)/sum(odorID==3)*100)
        round(sum(trialType==ttCuncertainUwater)/sum(odorID==1)*100)
        round(sum(trialType==ttCnothingUwater)/sum(odorID==2)*100)
        round(sum(trialType==ttCairpuffUairpuff)/sum(odorID==4)*100)
        sum(trialType==ttUwater)
        sum(trialType==ttUairpuff)
        ]';    
    
       trialProb (i,:) = a;
        
       if max(abs(a(1:4) - [90 50 0 80]))>15 || a(5)>40 || a(6) > 40
        
%             try
%                 updateEventExtractionsAllClick(fl{i},rawDataPath)
%                 %updateEventExtractions(fl{i},rawDataPath)
%             catch
                 errorFiles{k,1} = fl{i};
                 errorFiles{k,2} = a;
                 k = k+1;
%            end
      end
        
    
end 

%% change the rabies date
% animalRabiesDate = 'C:\Users\Hideyuki\Dropbox (Uchida Lab)\lab\FunInputome\animalRabiesDate.xlsx';
% T = readtable(animalRabiesDate,'Sheet','sheet1');
% 
% probAnimals = {'Horntail','Dragonfly',''};
% probFiles = fl;%(find(ismember(animalNames,probAnimals)));
% for i = 1:length(probFiles)
%     fn = probFiles{i};
%     [animalName, folderName, unitName] = extractAnimalFolderFromFormatted(fn);
%     ind=find(ismember(lower(T.AnimalName),lower(animalName)));
%     temp = T.Rabies{ind};
%     idx = strfind(temp, '/');
%     m = str2num(temp(1:idx(1)-1));
%     d = str2num(temp(idx(1)+1:idx(2)-1));
%     y = str2num(temp(idx(2)+1:end));
%     initialDate = datenum(y, m, d);   
%     recordDate = datenum(str2num(folderName(1:4)),...
%     str2num(folderName(6:7)), str2num(folderName(9:10)));
%     rabiesDate = recordDate -initialDate;
%     
%     save(fn,'-append','rabiesDate');
% end

%% check rabies date for each mouse

% for i = 1:max(idx)
%     ind = find(idx == i,1,'first');
%     fn = fl{ind};
%     
%     [animalName, folderName, unitName] = extractAnimalFolderFromFormatted(fn);
%     ind=find(ismember(lower(T.AnimalName),lower(animalName)));
%     temp = T.Rabies{ind};
%     temp_idx = strfind(temp, '/');
%     m = str2num(temp(1:temp_idx(1)-1));
%     d = str2num(temp(temp_idx(1)+1:temp_idx(2)-1));
%     y = str2num(temp(temp_idx(2)+1:end));
%     initialDate = datenum(y, m, d);   
%     recordDate = datenum(str2num(folderName(1:4)),...
%     str2num(folderName(6:7)), str2num(folderName(9:10)));
% 
%     rabiesDate = recordDate -initialDate;
%     rabiesDate
%     save(fn,'-append','rabiesDate');    
%     clear rabiesDate
% end