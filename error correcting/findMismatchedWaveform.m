
ProcessedDataPath = 'D:\Dropbox (Uchida Lab)\lab\FunInputome\ProcessedNeurons\'; 
%'D:\Lab\Projects\Functional Inputom\Inputome_formatted_cells\'; 
 % 'D:\Dropbox (Uchida Lab)\lab\FunInputome\VTARabiesLight\formatted\';

[dataFile, ProcessedDataPath] = uigetfile([ProcessedDataPath '*.mat'],...
    'Pick one (or more) MATLAB data file(s).','MultiSelect','on');
errorDataFile = [];
errorProcessFile = [];
k = 1;
j = 1;
for i = 1:length(dataFile)
        tempData = matfile(dataFile{i});  
        try
            timeshift = tempData.TimeAlign;
            timeshift = timeshift.TimeShift;
            if abs(timeshift)>6
                errorDataFile{k} = dataFile{i};
                k = k+1;
            end
        catch
            errorProcessFile{j} = dataFile{i};
            j = j+1;
        end
end