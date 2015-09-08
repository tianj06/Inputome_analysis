function updateFormattedDataNewCluster(destFile,clusterFile)
FormattedDataPath = 'D:\Dropbox (Uchida Lab)\lab\FunInputome\ProcessedNeurons\'; % path for formatted data;
if strcmp(clusterFile(end-2:end),'mat')
    load(clusterFile);
elseif strcmp(clusterFile(end),'t')
    fid = fopen(clusterFile,'r','b');  
    H = ReadHeader(fid);
    TS = fread(fid, inf,'uint32');
    fclose(fid)
else
    error('unknown cluster file')
end
load([FormattedDataPath destFile]);
responses.spike = TS/10;
save([FormattedDataPath destFile],'-append','responses');
end

