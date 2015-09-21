
fl = what(pwd);
fl = fl.mat;

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

%%
errorFiles = [];
trialProb = [];
k=1;
all_ratio = zeros(length(fl),10);
all_num = zeros(length(fl),10);
for i = 1:length(fl)	
    load(fl{i},'analyzedData')
    trialNum = cellfun(@(x)size(x,1),analyzedData.raster);
    trialNum_ratio = trialNum/trialNum(1);   
    all_ratio(i,:) = trialNum_ratio(1:10)';
    all_num(i,:) = trialNum(1:10)';
    clear analyzedData
end 
