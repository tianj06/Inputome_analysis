function [ output_args ] = CSCrefCalculation( input_args )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
record_range = [1 1000];
filtWV = zeros(4,1000*(diff(record_range)+1));
for i = 1:length(TTcscName)
    [filtWV(i,:), ~, ~, sampfreq] = quick_readCSCfile(TTcscName{i}, record_range);
end
for i = 1:4
    noiseVector(:,i) = rms(filtWV-repmat(filtWV(i,:),4,1),2);
end

end

