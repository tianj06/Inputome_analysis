function [x, y] = convertRegress(r, regressx)
    x = [];
    y = [];
    for i = 1:length(r)
        n = length(r{i});
        y = [y;r{i}];
        x = [x; regressx(i)*ones(n,1)];
    end
end