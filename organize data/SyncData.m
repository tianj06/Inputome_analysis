%SyncData
% to synchronize clustered data in harddrive to a local folder
% 
function SyncData(sourceRoot, targetRoot)

if nargin < 1
    sourceRoot ='E:\rabiesVP\';
    targetRoot = 'D:\Dropbox (Uchida Lab)\lab\FunInputome\Data\';
elseif nargin <2
    targetRoot = 'D:\Dropbox (Uchida Lab)\lab\FunInputome\Data\';
end
overWrite = 0;

tfilelist = rdir([sourceRoot '**\**\*.t']);
matfilelist = rdir([sourceRoot '**\**\*.mat']);
figfilelist = rdir([sourceRoot '**\**\*.fig']);
allfilelist = [matfilelist; tfilelist; figfilelist];

for i = 1:length(allfilelist)
    fn = allfilelist(i).name;
    [a, f, ext] = fileparts(fn);
    [a, date] = fileparts(a);
    [~, animal] = fileparts(a);
    Newfn = [targetRoot animal '\' date '\' f ext];
    if ~exist([targetRoot animal '\' date '\'],'dir')
        mkdir([targetRoot animal '\' date '\']);
    end
    if ~overWrite
        if ~exist(Newfn)
           [s,message,messageID] = copyfile(fn, Newfn);
           if ~s
               disp([fn ' not copied'])
           end
        end
    else
           [s,message,messageID] = copyfile(fn, Newfn);
           if ~s
               disp([fn ' not copied'])
           end
    end
end



