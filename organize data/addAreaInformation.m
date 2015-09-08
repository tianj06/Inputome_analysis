%addArea
f = what(pwd);
f = f.mat;
for i = 1:length(f)
    load(f{i})
    area = 'VS'; 
    save(f{i},'-append','area');
end


