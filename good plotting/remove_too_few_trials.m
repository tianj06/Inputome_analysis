function analyzedData = remove_too_few_trials(analyzedData,minTrialNum)
if nargin <2
    minTrialNum = 5;
end
    trialNum = cellfun(@(x)size(x,1),analyzedData.raster);
    removeTrials = find(trialNum < minTrialNum);
    if ~isempty(removeTrials)
        analyzedData.smoothPSTH(removeTrials,:) = nan;
        analyzedData.rocPSTH(removeTrials,:) = nan;
        analyzedData.rawLick(removeTrials,:) = nan;
        analyzedData.rawPSTH(removeTrials,:) = nan;
    end