path1 = 'C:\Users\uchidalab\Dropbox (Uchida Lab)\lab\FunInputome\rabies\analysis2015Fall\newLight';
fl = what(path1);
fl = fl.mat;

path2 = 'C:\Users\uchidalab\Dropbox (Uchida Lab)\lab\FunInputome\rabies\analysis2015Fall\allunits';
flall = what(path2);
flall = flall.mat;

animals1 = [];
areas1 = [];
for i = 1:length(fl)
    load([path1 '\' fl{i}],'area')
    animals1{i} = extractAnimalFolderFromFormatted(fl{i});
    areas1{i} = area;
    clear area
end

animals2 = [];
areas2 = [];
for i = 1:length(flall)
    load([path2 '\' flall{i}],'area')
    animals2{i} = extractAnimalFolderFromFormatted(flall{i});
    areas2{i} = area;
    clear area
end
%%
aapair1 = [];
for i = 1:length(animals1)
    aapair1{i} = [animals1{i} '_' areas1{i}];
end
aapair1 = unique(aapair1);


aapair2 = [];
for i = 1:length(animals2)
    aapair2{i} = [animals2{i} '_' areas2{i}];
end
aapair2 = unique(aapair2);

for i = 1:length(aapair2)
    if ~ismember(aapair2(i),aapair1)
        disp(aapair2(i))
    end
end

%%

for i = 1:length(flall)
    load([path2 '\' flall{i}],'area')
    if  strcmp(area,'St')
        area = 'Striatum';
        save(flall{i},'-append','area')   
    end
    clear area
end


for i = 1:length(flall)
    a = extractAnimalFolderFromFormatted(flall{i});    
    if strcmp(a,'Estragon')    
        area = 'En';
        save(flall{i},'-append','area')  
    elseif strcmp(a,'Noodle')    
        area = 'VS';
        save(flall{i},'-append','area') 
    end
    clear area
end