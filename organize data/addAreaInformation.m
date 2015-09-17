%addArea
function addAreaInformation(datapath,area)
f = what(datapath);
f = f.mat;
for i = 1:length(f)
    load(f{i})
    save(f{i},'-append','area');
end


