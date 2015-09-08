function merge2units(varargin)

if nargin<2
    DataPath = 'D:\Dropbox (Uchida Lab)\lab\FunInputome\ProcessedNeurons\';
    [units, DataPath] = uigetfile([DataPath '*.mat'],...
    'Pick two (or more) formatted data file(s) to merge.','MultiSelect','on');
else
    units = varagin;
end

if length(units)<2
    error('Choose at least two files')
else
    for i = 1:length(units)-1
        data1 = load(units{i});
        data2 = load(units{i+1});
        if i==1
            mergedData = mergeStruct(data1, data2);
        else
            mergedData = mergeStruct(mergedData, data2);
        end
    end
    ind = strfind(units{1},'_');
    mergedfileName = [units{1}(1:ind(end)) 'merged.mat'];
    save(mergedfileName,'-struct','mergedData');
end

end