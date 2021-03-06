function [newlabels,plotorder ]= reorder_clustLabel(oldlabels,response)
nclusters = length(unique(oldlabels));
mean_res = [];
for i = 1:nclusters
    mean_res(i) = mean(response(oldlabels==i));
end
% sort the response for old clusters
[~,new_ids] = sort(mean_res);
%
newlabels = oldlabels;
for i = 1:nclusters
    newlabels(oldlabels==new_ids(i)) = i;
end

plotorder = [];
for i = 1:nclusters
    ind = find(newlabels==i);
    [~,ind_sort_idx] = sort(response(ind));
    ind = ind(ind_sort_idx);
    plotorder = [plotorder ind'];
end

end