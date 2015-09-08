% ind = find(strcmp('cant find psth and light result files',...
%     errorProcess(:,2)));
% dataFile = errorProcess(ind,1);
ProcessedDataPath = 'C:\analysis\formatted\';
cd(ProcessedDataPath);
fl = what(ProcessedDataPath);
dataFile = fl.mat;
savePath = 'C:\analysis\plottings\';
rawPath = {'F:\Mouse Data\'};
%rawPath = {'E:\rabies\'};

if ~iscell(dataFile)
    dataFile = {dataFile};
end
%%
errorFiles = cell(1,1);
k = 1;
for i = 1:length(dataFile) %145:225%
    filename = dataFile{i};
    info = whos(matfile(filename));
    varName = {info.name};
    
    try
       if isempty(find(strcmp('analyzedData',varName)))
            analyzedData = getPSTHSingleUnit(filename); 
            save(filename,'-append','analyzedData');
        end
        if isempty(find(strcmp('checkLaser',varName)))
            rawfind = 0;
            for j = 1:length(rawPath)
                [~,fn] = fileparts(filename);
                [animalName, folderName, ~] = extractAnimalFolderFromFormatted(fn);
                if exist([rawPath{j} animalName '\' folderName], 'dir')
                    rawdataPath = rawPath{j};
                    rawfind = 1;
                end
            end
            if rawfind
                plotLaserResponse_SingleNeuron_AfterSnippets(filename,ProcessedDataPath,rawdataPath);
                %plotLaserResponse_SingleNeuron(filename,ProcessedDataPath,rawdataPath);
                set(gcf,'units','normalized','outerposition',[0 0 1 1])
                saveas(gcf,[savePath fn 'Light'],'tif')
                close all
            else
                filename
                display('Could not find raw files')
            end
            
        end
        if isempty(find(strcmp('lightResult',varName)))
            lightResult = checkLaserSingleUnit(filename);
            save(filename,'-append','lightResult');
        end
    catch EM
        errorFiles{k,1} = dataFile{i};
        errorFiles{k,2} = EM.message;
        k = k+1;
    end
    close all;
end