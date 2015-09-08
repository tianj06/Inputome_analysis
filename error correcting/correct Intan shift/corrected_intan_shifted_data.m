function corrected_intan_shifted_data(dataPath,savePath)

% get filename of all CSCfile
for i = 1:16
    chip1FileName{i} = ['CSC' num2str(i) '.dat' ];
    chip2FileName{i} =  ['CSC' num2str(i+16) '.dat' ];
end
savePath = 'F:\rabies\Uno\2015-08-14_14-36-30\';
allChipsFileName =  [chip1FileName, chip2FileName];
Early_record_range = [1 150];
Late_record_range = [129420 129480];

% figure;
%  visualize_csc_file(chip1FileName(5), Late_record_range)

% calculate number of records for each csc file
fn = fopen(allChipsFileName{1});
fseek(fn, 0, 'eof');
position = ftell(fn);
recordSize = 1001*4;
recordNum = floor(position/recordSize);
fclose(fn);
% find out in which mode the channels are shifted
% shiftMode : 1 all shifted; 2 chip1 shifted; 3 chip2 shifted
% at the same time, divide the data into 10 blocks, and see in which block
% the shift happens
offsetRecord = round(recordNum*0.1);
[shiftMode, IdxLag, RMScorr,stepSize] = intan_csc_shift_mode_cal(allChipsFileName,...
    chip1FileName,chip2FileName,recordNum,offsetRecord);
% narrow down when exactly the shift happened
IdxLag
switch shiftMode
    case 1 
        fileSet = {allChipsFileName};
    case 2 
        fileSet = {chip1FileName};
    case 3 
        fileSet = {chip2FileName};
    case 4 
        fileSet = {chip1FileName,chip2FileName };
end
%%
changeIdx = [];
if shiftMode==4
    for i = 1:2
        shiftStartIdx = find(diff(IdxLag(i,:)));
        searchRange = offsetRecord+[shiftStartIdx-1 shiftStartIdx]*stepSize+[1 0];
        changeIdx(i) = binary_search_CSCshift(fileSet{i},searchRange);
        figure;
        visualize_csc_file(fileSet{i}, [changeIdx(i)-100 changeIdx(i)+100]);
    end
else
    shiftStartIdx = find(diff(IdxLag));
    searchRange = offsetRecord+[shiftStartIdx-1 shiftStartIdx]*stepSize+[1 0];
    changeIdx = binary_search_CSCshift(fileSet{1},searchRange);
    figure;
    visualize_csc_file(fileSet{1}, [changeIdx-100 changeIdx+100]);
end

    


%% save the data to new files with shift corrected
for k = 1:length(changeIdx)
    shiftFileSet = fileSet{k};
    for i = 1:length(shiftFileSet)
        fn(i) = fopen(shiftFileSet{i});
        fnWr(i) = fopen([savePath shiftFileSet{i}],'w+');
    end

    for i = 1:length(shiftFileSet)
       fwrite(fnWr(i), fread(fn(i),1,'double','s'),'double','s');
       fwrite(fnWr(i), fread(fn(i), (changeIdx(k)-1)*1001,'single','s'),'single','s');
    end

    fn = circshift(fn,[0 IdxLag(shiftStartIdx+1)]);


    for i =1:length(shiftFileSet)
       fwrite(fnWr(i), fread(fn(i),inf,'single','s'),'single','s');
    end
end
beep
end