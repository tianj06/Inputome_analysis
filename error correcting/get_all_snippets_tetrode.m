function get_all_snippets_tetrode(TTidx,ref,inhibitChannels,saveFolder)
% get_all_snippets_tetrode(7,2,nan)  tetrode 7, ref2 
if nargin <4
    saveFolder = pwd;
    if nargin <3
        inhibitChannels=nan;
    end
end

if ~strcmp(saveFolder(end),filesep)
    saveFolder = [saveFolder,filesep];
end

for i = 1:4
    TTcscName{i} = ['CSC' num2str((TTidx-1)*4+i) '.dat'];
    cscFid(i) = fopen(TTcscName{i});
end

fn = fopen(TTcscName{1});
sr = fread(fn,1,'double','s'); % skip the sr
t = fread(fn,inf,'single',1000*4,'s');
recordNum = length(t);
fclose(fn);

blockNum = 100;
blockSize = floor(recordNum/blockNum);
fid_a=fopen([saveFolder 'TT',num2str(TTidx),'.dat'],'w');
for i = 1:blockNum
    if i <blockNum
        record_range = [(i-1) i]*blockSize +[1 0];
    else
        record_range = [(i-1)*blockSize+1 recordNum];
    end
    filtWV = zeros(4,1000*(diff(record_range)+1));
    for j = 1:length(TTcscName)
        [filtWV(j,:), ~, ~, sampfreq] = quick_readCSCfile(cscFid(j), record_range);
    end
    if ~isnan(ref)
        filtWV = filtWV - repmat(filtWV(ref,:),4,1);
    end
    if ~isnan(inhibitChannels)
        filtWV(inhibitChannels,:)=zeros(length(inhibitChannels),size(filtWV,2));
    end
    noiseWindow = filtWV(:,1:50000);
    %%
    signalP = sum(noiseWindow,2);
    thres =3*std(noiseWindow');
    crossings = [];
    for j = 1:4
        if thres(j)
            if signalP(j)>0
                ind = crossing(filtWV(j,:)-thres(j)); 
            else
                ind = crossing(filtWV(j,:)+thres(j)); 
            end
            crossings = [crossings ind];  
        end
    end
    crossings = sort(crossings,'ascend');
    crossings(diff(crossings)<32) = [];
    %%
    if crossings(1)-31<1
        crossings(1) = [];
    end
    if crossings(end)+32>size(filtWV,2)  
        crossings(end) = [];
    end
    peakAlignedCrossing = zeros(size(crossings));
    snippets = zeros(length(crossings),4,32);
    peakValue = zeros(size(crossings));
    for j = 1: length(crossings)     
            tempdata = filtWV(:,  [crossings(j)-15: crossings(j)+16]);
            [~,idx] = max(max(abs(tempdata),[],2));
            [peakValue(j),peakidx] = max(abs(filtWV(idx,[crossings(j)-15: crossings(j)+16]))); % can be improved
            peakAlignedCrossing(j) = peakidx+crossings(j)-16;
            if peakAlignedCrossing(j)-15>0 && peakAlignedCrossing(j)+16<=size(filtWV,2) 
                snippets(j,:,:) = filtWV(:, peakAlignedCrossing(j)-15:peakAlignedCrossing(j)+16);
            else
                peakAlignedCrossing(j) = nan;
            end
    end
    nanIdx = isnan(peakAlignedCrossing);
    peakValue(nanIdx) = [];
    peakAlignedCrossing(nanIdx) = [];
    snippets(nanIdx,:,:) = [];
    overlapIdx = find(diff(peakAlignedCrossing)<32);
    [~,idx] = min([peakValue(overlapIdx); peakValue(overlapIdx+1)]);
    overlapIdx = overlapIdx-1+idx;
    peakAlignedCrossing(overlapIdx) = [];
    snippets(overlapIdx,:,:) = [];
    % get timestamps
    dataPointIdx = peakAlignedCrossing+1000*(record_range(1)-1);
    recordIdx = floor(dataPointIdx/1000)+1;
    recordRes = rem(dataPointIdx, 1000);
    snippet_timestamp = t(recordIdx)'+ 10000*recordRes/sr;
    %%
    %write snippets to file in pfroper format
    
    for j=1:length(peakAlignedCrossing)
        this_snippet=zeros(1,129);
        this_snippet(1)=snippet_timestamp(j);
        this_snippet(2:129)=reshape(snippets(j,:,:),1,[]);
        fwrite(fid_a,this_snippet,'single','s');
    end

%     %%
%     for a = 4596:4598
%     figure;
%     plotidx = [peakAlignedCrossing(a)-15: peakAlignedCrossing(a)+16];
%     plot(filtWV(:,plotidx)')
%     end
end
fclose(fid_a);
beep;