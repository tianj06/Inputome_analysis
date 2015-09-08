function noiseVector = calculate_csc_noise(cscNames,record_range)
filtWV = zeros(4,1000*(diff(record_range)+1));
for i = 1:length(cscNames)
    [filtWV(i,:), ~, ~, sampfreq] = quick_readCSCfile(cscNames{i}, record_range);
end
%filtWV = filtWV - repmat(mean(filtWV), size(filtWV,1) ,1);
noiseVector = rms(filtWV,2);

