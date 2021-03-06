function plotHistByGroup_cellarray( y,bin, G,groupName)
% bin is the right edge of each bin
%bincenter = mean( [bin; [0 bin(1:end-1)]]);
x(1) = min(bin)-0.1;
x(2) = max(bin)+0.1;
for i = 1:length(groupName)
    subplot(length(groupName),1,i)
    histogram(y(G{i}),bin,'Normalization','probability')
    set(gca,'Box','off','FontSize',11)
    set(gca,'TickDir','out')
    set(gca,'TickLength',[0.02 0.025])
    title(sprintf('%s n=%d',groupName{i},sum(G{i})))   
    xlim(x)
    if i~=length(groupName)
        set(gca,'xticklabel','')
    end
end
set(gcf,'position',[200 50 250 700])
set(gcf,'Color','w')
