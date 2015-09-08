function plotCumsumLatency(latency,G,colorSet,titleText,areaName)

for i = 1:length(areaName)
    hold on;
    scaleFactor = sum(~isnan(latency(G==i)))/length(latency(G==i));
    [f,x] = ecdf(latency(G==i));
    plot([x; 1000],scaleFactor*[f; 1],'color',colorSet(i,:))

end
xlim([0 1000]); ylim([-0.1 1.1])
xlabel('ms')
ylabel('cdf')
title(titleText)