function y = groupedmean(x, groups)

for i = 1:length(groups)
    y(i,:) = mean(x(groups{i},:));
end