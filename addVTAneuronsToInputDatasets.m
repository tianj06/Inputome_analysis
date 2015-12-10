%% add area tags to putative dopamine neurons, type 2 and type 3 neurons in rabies dataset
% and copy those neurons to the main folder
Nr = length(lightfiles);
rabies_label = 1:size(dataToCluster,1)<= Nr; % first Nr neurons are rabies
b = squeeze(mean(mean(psthAll(:,11:14,1:1000),3),2));

rabies_dopamine = lightfiles(clustLabel==1&b<15&rabies_label');
rabiesTyp2 = lightfiles(clustLabel==2&rabies_label');
rabiesTyp3 = lightfiles(clustLabel==3&rabies_label');

filelists = {rabies_dopamine,rabiesTyp2,rabiesTyp3};
areaNames = {'rdopamine','rVTA Type2','r VTA Type3'};

savePath = 'C:\Users\uchidalab\Dropbox (Uchida Lab)\lab\FunInputome\rabies\analysis2015Fall\newLight\';
for i = 1:3
    fl = filelists{i};
    area = areaNames{i};
    for j = 1:length(fl)
        fn = fl{j};
        save([homepath 'formatted\' fn],'-append','area');
        copyfile( [homepath 'formatted\' fn], [savePath fn])
    end
end
%% change area tags to type 2 and type 3 neurons in AAV datasets in the main folder
flall = [lightfiles'; fl_aav];
VTATyp2 = flall(clustLabel==2&~rabies_label');
VTATyp3 = flall(clustLabel==3&~rabies_label');

% examine the difference between old cluster and new clusters

fllight = what(savePath);
fllight = fllight.mat;
oldVTAType2Files = {};
oldVTAType3Files = {};
k = 1;
m = 1;
for i = 1:length(fllight)
    load([savePath fllight{i}],'area')
    if strcmp(area,'VTA2')
        oldVTAType2Files{k} = fllight{i};
        k = k+1;
    elseif strcmp(area,'VTA3')
        oldVTAType3Files{m} = fllight{i};
        m = m+1;
    end
end
oldVTAType2Files = oldVTAType2Files';
oldVTAType3Files = oldVTAType3Files';

setdiff(oldVTAType2Files,VTATyp2)
setdiff(oldVTAType3Files,VTATyp3)

setdiff(VTATyp2,oldVTAType2Files)
setdiff(VTATyp3,oldVTAType3Files)

% use new cluster data to replace old VTA type2 and 3 data and move them to
% another folder
backupPath = ['C:\Users\uchidalab\Dropbox (Uchida Lab)\lab\FunInputome\'...
            'rabies\analysis2015Fall\AAV_type2and3_oldBackup\'];
for i = 1:length(fllight)
    load([savePath fllight{i}],'area')
    if strcmp(area,'VTA2')|strcmp(area,'VTA3')
        movefile([savePath fllight{i}],[backupPath fllight{i}])
    end
end        

filelists = {VTATyp2, VTATyp3};
areaNames = {'VTA2','VTA3'};
for i = 1:2
    fl = filelists{i};
    area = areaNames{i};
    for j = 1:length(fl)
        fn = fl{j};
        save([homepath 'controlVTA\' fn],'-append','area');
        copyfile( [homepath 'controlVTA\' fn], [savePath fn])
    end
end