function get_all_snippets_tetrode(TTidx,ref)

for i = 1:4
    TTcscName{i} = ['CSC' num2str((TTidx-1)*4+i) '.dat'];
end

fn = fopen(TTcscName{1});
sr = fread(fn,1,'double','s'); % skip the sr
t = fread(fn,inf,'single',1000*4,'s');
recordNum = length(t);
fclose(fn);

blockNum = 100;
blockSize = floor(recordNum/blockNum);
fid_a=fopen(['TT',num2str(TTidx),'.dat'],'w');
for i = 1:20
    if i <blockNum
        record_range = [(i-1) i]*blockSize +[1 0];
    else
        record_range = [(i-1)*blockSize+1 recordNum];
    end
    filtWV = zeros(4,1000*(diff(record_range)+1));
    for j = 1:length(TTcscName)
        [filtWV(j,:), ~, ~, sampfreq] = quick_readCSCfile(TTcscName{j}, record_range);
    end
    if ~isnan(ref)
        filtWV = filtWV - repmat(filtWV(ref,:),4,1);
    end
    noiseWindow = filtWV(:,1:50000);
    %%
    thres = 3*std(noiseWindow');
    crossings = [];
    for j = 1:4
        if thres(j)
                ind = crossing(abs(filtWV(j,:))-thres(j)); 
                crossings = [crossings ind];  
        end
    end
    crossings = sort(crossings,'ascend');
    crossings(diff(crossings)<32) = [];
    %%
    while( crossings(1)-31<1)
        crossings(1) = [];
    end
    while crossings(end)+32>size(filtWV,2)  
        crossings(end) = [];
    end
    peakAlignedCrossing = zeros(size(crossings));
    snippets = zeros(length(crossings),4,32);
    for j = 1: length(crossings)     
            tempdata = filtWV(:,  [crossings(j)-15: crossings(j)+16]);
            [~,idx] =  max(max(abs(tempdata),[],2));
            [~,peakidx] = max(abs(filtWV(idx,  [crossings(j)-31: crossings(j)+32]))); % can be improved
            peakAlignedCrossing(j) = peakidx+crossings(j)-31;
            if peakAlignedCrossing(j)>16& peakAlignedCrossing(j)+16<size(filtWV,2)
                snippets(j,:,:) = filtWV(:, peakAlignedCrossing(j)-15 : peakAlignedCrossing(j)+16);
            else
                peakAlignedCrossing(j) = nan;
            end
    end
    % get timestamps
    nanIdx = isnan(peakAlignedCrossing);
    peakAlignedCrossing(nanIdx) = [];
    snippets(nanIdx,:,:) = [];
    dataPointIdx = peakAlignedCrossing+record_range(1)-1;
    recordIdx = floor(dataPointIdx/1000)+1;
    recordRes = rem(dataPointIdx, 1000);
    snippet_timestamp = t(recordIdx)'+10000*recordRes/sr;
    %%
    %write snippets to file in pfroper format
    
    for j=1:length(peakAlignedCrossing)
        this_snippet=zeros(1,129);
        this_snippet(1)=snippet_timestamp(j);
        this_snippet(2:129)=reshape(snippets(j,:,:),1,[]);
        fwrite(fid_a,this_snippet,'single','s');
    end

%     %%
%     for a = 1:51:500
%     figure;
%     plotidx = [peakAlignedCrossing(a)-15: peakAlignedCrossing(a)+16];
%     plot(filtWV(:,plotidx)')
%     end
end
fclose(fid_a);