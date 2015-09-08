function [L,ChannelValidity]= caluclateLratio_Mclust4(unitName, FeatureToUse,loadingEngine)
% construct feature name
    TTname = unitName(1:3);
    % load channel validity
    energyFile = [TTname '_feature_Energy.fd'];
    load(energyFile, 'ChannelValidity', '-mat'); % usually energy is calculated
    channelNum = length(find(ChannelValidity));
    % load feature timestamps
    load(energyFile, 'FeatureTimestamps', 'FeatureNames', '-mat');
    FD = zeros(length(FeatureTimestamps),channelNum*length(FeatureToUse));
    %%
    for i = 1:length(FeatureToUse)
        FeatureFile{i} = [TTname '_feature_' FeatureToUse{i} '.fd'];
        if exist(FeatureFile{i})
            load(FeatureFile{i},'FeatureData', '-mat');
            FD(:,(i-1)*channelNum+1:channelNum*i) = FeatureData;
        else
            if ~exist('WV','var')
                if loadingEngine == 1 % intan
                       [~,WV] = LoadingEngineIntan4([TTname '.dat']);
                elseif loadingEngine == 0 % neuralynx
                       [~,WV] = LoadTT_NeuralynxNT([TTname '.ntt']);
                end
            end
            [FeatureData, ~, ~] = feval(['O_feature_' FeatureToUse{i}], WV, ChannelValidity);
            FD(:,(i-1)*channelNum+1:channelNum*i) = FeatureData;
            save(FeatureFile{i},'FeatureData','FeatureTimestamps','-mat');
        end         
    end
    clear WV
%%    
% load unit timestamps    
   %       TS = load([unitName '.mat']); % for MClust3.5
   fid = fopen([unitName '.t'],'r','b');  
   H = ReadHeader(fid);
   TS = fread(fid, inf,'uint32');
   fclose(fid);
 % find clusterSpikeIndex  
 FeatureTimestamps = int32(1000*FeatureTimestamps);
 TS = int32(TS/10);
 
 [~,a,b] = intersect(FeatureTimestamps,TS);
 [~,a1,b1] = intersect(FeatureTimestamps,TS+1);
 [~,a2,b2] = intersect(FeatureTimestamps,TS-1);
 [tempIdx ia]= setdiff(b1,b);
 b = [b; tempIdx]; 
 a = [a; a1(ia)];
 [tempIdx ia] = setdiff(b2,b);
 b = [b; tempIdx]; 
 a = [a; a2(ia)];
clusterSpikeIndex = a;

% compute L-ratio
[L, ~] = O_L_Ratio(FD, clusterSpikeIndex);

end