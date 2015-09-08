%function removeLaterSessionData

for i = 1:32
    allChipsFileName{i} = ['CSC' num2str(i) '.dat' ];
end

fn = fopen(allChipsFileName{1});
fseek(fn, 0, 'eof');
position = ftell(fn);
recordSize = 1001*4;
recordNum = floor(position/recordSize);
fclose(fn);
searchBin = 100;
nls = calculate_csc_noise(allChipsFileName,[1 1+searchBin]);
nle = calculate_csc_noise(allChipsFileName,[recordNum-searchBin recordNum]);
brokenWires = find(nls>3*mean(nls));
UsedWire = setdiff(1:32,brokenWires);
searchRange = [1 recordNum];

while diff(searchRange)>searchBin
    midpoint = round( mean(searchRange));
    %nl1 = calculate_csc_noise(allChipsFileName,[searchRange(1) searchRange(1)+searchBin]);
    nl2 = calculate_csc_noise(allChipsFileName,[midpoint midpoint+searchBin]);

    if sum(nl2(UsedWire))< 2*sum(nls(UsedWire)) 
        searchRange(1) = midpoint;
    else
        searchRange(2) = midpoint;
    end
end

EndIndex = searchRange(1);
      %%  
savePath = 'E:\ArchHeG\2015-03-09_15-10-19new\';

for i = 1:length(allChipsFileName)
    fn(i) = fopen(allChipsFileName{i});
    fnWr(i) = fopen([savePath allChipsFileName{i}],'w+');
end

for i = 1:length(allChipsFileName)
   fwrite(fnWr(i), fread(fn(i),1,'double','s'),'double','s');
   fwrite(fnWr(i), fread(fn(i), (EndIndex-1)*1001,'single','s'),'single','s');
end

beep