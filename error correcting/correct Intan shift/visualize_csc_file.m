%1.to plot one csc raw trace:
%visualize_csc_file({'CSC1.ncs'},[1 300]) 
% [1 300] is an artibutary time range, corresponding to the beginning of recording
%2.to plot multiple csc raw trace:
%visualize_csc_file({'CSC1.ncs','CSC2.ncs','CSC3.ncs'},[1 300]) 
%for multiple plots, first wire is in the bottom, last wire is in th top. 
%The neighbouring wires have an offset of linespace to differentiate wires.

function visualize_csc_file(cscNames,record_range)
linespace = 200;

for i = 1:length(cscNames)
    [a, ts(i,:), chunkSize(i), sampfreq] = quick_readCSCfile(cscNames{i}, record_range);
    filtWV(i,:) = (i-1)*linespace + a;
end
 
plot(filtWV')
end
