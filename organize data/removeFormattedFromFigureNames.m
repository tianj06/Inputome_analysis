allplot = rdir(['F:\Recording\Albatross\formatted*.tif']);
for i = 1:length(allplot)
    oldName = allplot(i).name;
    [p,n,ext] = fileparts(oldName);
    n = n(10:end);
    newName = [p '\' n ext];
    movefile(oldName, newName);
end