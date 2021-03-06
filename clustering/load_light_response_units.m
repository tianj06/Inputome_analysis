function [rocPSTH,lickPSTH,rawPSTH] = load_light_response_units(light_table,homeFolder)
if nargin <2
    homeFolder = ['C:\Users\uchidalab\Dropbox (Uchida Lab)\lab\FunInputome\rabies\rabies_'];
end
rocPSTH = zeros(height(light_table),10,50);
lickPSTH = zeros(height(light_table),10,5001);
rawPSTH = zeros(height(light_table),10,5001);

for i = 1:height(light_table)
    fn = [homeFolder light_table.Area{i} '\uniqueUnits\' light_table.FileName{i}];
    load(fn, 'analyzedData')
    analyzedData = remove_too_few_trials(analyzedData,5);
    rocPSTH(i,:,:) = analyzedData.rocPSTH(1:10,:);
    lickPSTH(i,:,:) = analyzedData.rawLick(1:10,:);
    rawPSTH(i,:,:) = analyzedData.rawPSTH(1:10,:);
end
    