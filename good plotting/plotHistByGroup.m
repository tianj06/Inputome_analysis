function plotHistByGroup( y,bin, GroupVariable,groupName)
% bin is the endpoints of each bin
bincenter = mean( [bin; [0 bin(1:end-1)]]);
if nargin <4 && iscell(GroupVariable)
    [G,groupName]=grp2idx(GroupVariable);
elseif isnumeric(GroupVariable)
    G = GroupVariable;
end
x(1) = min(bin)-0.1;
x(2) = max(bin)+0.1;
for i = 1:length(groupName)
    subplot(length(groupName),1,i)
    a = histc(y(find(G==i)),bin);
    bar(bincenter,a)
    set(gca,'Box','off','FontSize',11)
    set(gca,'TickDir','out')
    set(gca,'TickLength',[0.02 0.025])
    title(groupName{i})   
    xlim(x)
    if i~=length(groupName)
        set(gca,'xticklabel','')
    end
end
set(gcf,'position',[200 50 250 700])
set(gcf,'Color','w')
