function [L cv]= caluclateLratio_MClust3_5(unitName, FeatureToUse,loadingEngine)
% construct feature name
    TTname = unitName(1:3);
    % load channel validity
    energyFile = [TTname '_Energy.fd'];
    load(energyFile, 'ChannelValidity', '-mat'); % usually energy is calculated
    channelNum = length(find(ChannelValidity));
    % load feature timestamps
    cv = ChannelValidity;
    load(energyFile, 'FeatureTimestamps', 'FeatureNames', '-mat');
    FD = zeros(length(FeatureTimestamps),channelNum*length(FeatureToUse));
    %%
    for i = 1:length(FeatureToUse)
        FeatureFile{i} = [TTname '_' FeatureToUse{i} '.fd'];
        if length(FeatureToUse{i})>6
            if strcmp(FeatureToUse{i}(5:6),'PC')
                FeatureFile{i}(5) = lower(FeatureFile{i}(5));
            end
        end
        if exist(FeatureFile{i})
            load(FeatureFile{i},'FeatureData', '-mat');
            FD(:,(i-1)*channelNum+1:channelNum*i) = FeatureData;
        else
            if ~exist('WV','var')
                if loadingEngine == 1 % intan
                       [~,WV] = LoadingEngineIntan2([TTname '.dat']);
                elseif loadingEngine == 0 % neuralynx
                       [~,WV] = LoadTT_NeuralynxNT([TTname '.ntt']);
                end
            end
            [FeatureData, ~, ~] = feval(['O_feature_' FeatureToUse{i}], WV, ChannelValidity);
            FD(:,(i-1)*channelNum+1:channelNum*i) = FeatureData;
            save( FeatureFile{i},'FeatureData','FeatureTimestamps','-mat');
        end         
    end
    clear WV
%%    
% load unit timestamps    
load([unitName '.mat']); % for MClust3.5

 % find clusterSpikeIndex  
clusterSpikeIndex = find(ismember(FeatureTimestamps,TS)); % MClut4.0, has to test for 3.5
% compute L-ratio
[L, ~] = O_L_Ratio(FD, clusterSpikeIndex);

end