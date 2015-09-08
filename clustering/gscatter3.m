function gscatter3(x,y,z,g)

h = gscatter(x, y, g);
% for each unique group in 'g', set the ZData property appropriately
gu = unique(g);
for k = 1:numel(gu)
      set(h(k), 'ZData', z( g == gu(k) ));
end
view(3)