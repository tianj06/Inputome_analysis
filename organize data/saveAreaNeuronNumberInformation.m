%path1 = pwd;
%path2 = 'C:\Users\uchidalab\Dropbox (Uchida Lab)\lab\FunInputome\rabies\analysis2015Fall\newLight\';
fl = what(pwd);
fl = fl.mat;
k = 1;
for i = 1:length(fl)
    load(fl{i},'area')
    if ~ismember(area,{'DA','VTA3','VTA2'})
        load(fl{i},'rabiesDate','lightResult')  
        [animalName, folder,~]=extractAnimalFolderFromFormatted(fl{i});
        if ~exist('rabiesDate','var')
            rabies_dates{k} = folder(1:10);
        else
            rabies_dates{k} = num2str(rabiesDate);
        end
        llatency(k) = lightResult.latency; 
        brainArea{k} = area;
        animalNames{k} = animalName;
        clear rabiesDate lightResult area
        k = k+1;
    end
end


% % change  the name of brain areas
% oldnames = {'Striatum','LH','VS','PPTg','RMTg','VP','St','DA','VTA3','VTA2','Ce'};
% newnames = {'Dorsal striatum','Lateral hypothalamus','Ventral striatum',...
%     'PPTg','RMTg','Ventral pallidum','Dorsal striatum','Dopamine','VTA type3',...
%     'VTA type2','Central amygdala'};
% oldbrain = brainArea;
% for i = 1:length(oldnames)
%     idx = ismember(oldbrain,oldnames{i});
%     brainArea(idx) = newnames(i);
% end
[G,areaName]=grp2idx(brainArea);

%% 
fid = fopen('C:\Users\uchidalab\Dropbox (Uchida Lab)\lab\FunInputome\rabies\analysis2015Fall\neuron_by_area1.txt','wt');
for i = 1:length(areaName)
    % count neuron number belong to this
    fprintf(fid,areaName{i})
    fprintf(fid,'\t')
    N = sum(G==i);
    fprintf(fid,'total Neuron %d \n',N);
    % print each animal, neuron days
    animals = unique(animalNames(G==i));
    for j = 1:length(animals)
        fprintf(fid,'%s neuron dates: \n',animals{j});
        animalIdx = find(strcmp(animalNames,animals{j})); %&llatency<=6
        for k = 1:length(animalIdx)
            fprintf(fid,'%s, \t',rabies_dates{animalIdx(k)});
        end
        fprintf(fid,'\n')
    end
    fprintf(fid,'\n')
end


