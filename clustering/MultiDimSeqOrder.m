function OrderedIdx = MultiDimSeqOrder(InputArray)
sigma = 0.5;
distfun = @(x,y) exp(-sqrt(sum((x-y).^2))/(sqrt(2)*sigma));
% calculate pairwise distance: DistArrayPair
DistArrayPair = zeros(size(InputArray,1));
for i = 1:size(InputArray,1)
    for j = 1:size(InputArray,1)
        DistArrayPair(i,j) = distfun(InputArray(i,:),InputArray(j,:));
    end
end

% find the element with smallest distance to other elements
OrigIndex = 1:size(InputArray,1);
OrderedIdx = [];
for k = 1:size(InputArray,1)
    N_elements = length(OrigIndex);
    DistSet = zeros(N_elements,1);
    for i = 1:N_elements
        otherIndex = setdiff(1:N_elements,i);
        DistSet(i) = sum(DistArrayPair(i,otherIndex));
    end
    [~,min_idx ] = min(DistSet);
    
    OrderedIdx = [OrderedIdx, OrigIndex(min_idx)];
    DistArrayPair(min_idx,:) = [];
    DistArrayPair(:,min_idx) = [];
    OrigIndex(min_idx) = [];
end

