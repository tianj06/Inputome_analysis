% remove redundant units of the same day
fpath = pwd;
flist = what(fpath);
flist = flist.mat;
sessionList = {};
for i = 1:length(flist)
     fname = flist{i};
     idx = strfind(fname,'_');
     sessionName = fname(1:idx(2)-1);
     sessionList{i} = sessionName;
end
%%
[G,GN]=grp2idx(sessionList);
ACD_result = {};
k=1;
for i = 1:max(G)
    subflist = flist(G==i);
    for m = 1:length(subflist)-1
        for n = m+1:length(subflist)
            spike1 = load(subflist{m},'responses');
            spike1 = spike1.responses.spike;
            spike2 = load(subflist{n},'responses');
            spike2 = spike2.responses.spike;
            
            [ACD,xrange]= MClustStats.CrossCorr(spike1, spike2, 1, 50); % all in ms
%             figure;
%             bar(xrange,ACD)
            ACD_ratio = mean(ACD(25:27))/mean(ACD([1:24 28:51]));
            ACD_result{k,1} = subflist{m};
            ACD_result{k,2} = subflist{n};
            ACD_result{k,3} = ACD_ratio;
            k = k+1;
        end
    end
end

T_acd = cell2table(ACD_result,'VariableNames',{'file1' 'file2' 'ACD'});

T_acd(T_acd.ACD>5,:)