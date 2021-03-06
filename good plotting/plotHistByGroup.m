function plotHistByGroup( y,bin, GroupVariable,groupName,thres)
% bin is the right edge of each bin
bincenter = mean( [bin; [0 bin(1:end-1)]]);
if nargin <4 && iscell(GroupVariable)
    [G,groupName]=grp2idx(GroupVariable);
elseif isnumeric(GroupVariable)
    G = GroupVariable;
end
if nargin<5
    thresFlag = 0;
else
    thresFlag = 1;
end
% x(1) = min(bin)-0.1;
% x(2) = max(bin)+0.1;
for i = 1:length(groupName)
    subplot(length(groupName),1,i)
    plotdata = histcounts(y((G==i)),bin)/sum(G==i);
    bar(bincenter(2:end),plotdata);
    tempdata = y(G==i);
    y_25 = quantile(tempdata(tempdata<500),0.25);
    y_median = median(tempdata(tempdata<500));
    %histogram(y(G==i),bin,'normalization','probability');
    %h.Values = h.Values/areaCounts(i);
    plotNeuronCounts = sum(y(G==i)<500);
    valueNeuronCount = sum(y(G==i)<10000);
    set(gca,'Box','off','FontSize',11)
    set(gca,'TickDir','out')
    set(gca,'TickLength',[0.02 0.025])
    title(sprintf('%s n=%d/%d total=%d',groupName{i},plotNeuronCounts,valueNeuronCount,sum(G==i)))   
    hold on;
    %vline(y_25,'g');vline(y_median,'r')
    if thresFlag
        perc = sum(tempdata<=thres)/sum(G==i);
        title(sprintf('%s n=%d/%d fast = %0.1f%%/%d',groupName{i},...
            plotNeuronCounts,valueNeuronCount,perc*100,sum(G==i))) 
        vline(thres,'r')
    end
    
    xlim([0 500])
    if i~=length(groupName)
        set(gca,'xticklabel','')
    end
end 
set(gcf,'position',[194   216   395   642])
set(gcf,'Color','w')
