fl = what(pwd);
dataFile = fl.mat;
for i = 1:length(dataFile) %145:225%
    filename = dataFile{i};
    info = whos(matfile(filename));
    varName = {info.name};
    
   if isempty(find(strcmp('analyzedData',varName)))
        analyzedData = getPSTHSingleUnit(filename); 
        save(filename,'-append','analyzedData');
   end       

end