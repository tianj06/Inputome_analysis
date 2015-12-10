[G, area]=grp2idx(brainArea);
normalized = 1;
bin = 250;

colorset= [  0 	0 	255;%blue  
             30 	144 	255;%light blue  
             128 	128 128;
             255 0 0
             0 0 0]/255; % grey
         
plotTrialType = [1:bin; bin+1:2*bin; 6*bin+1:7*bin;3*bin+1:4*bin];
figure;
for i = 1:10
    idx = G==i;
    plotdata = rawpsthAll(idx,:);
    if normalized
        for j = 1:sum(idx)
            plotdata(j,:) = normalize01(plotdata(j,:));
        end
    end
    plotdata = mean(plotdata);
    subplot(3,4,i)
    for j = 1:size(plotTrialType,1)
        data = smooth(plotdata(plotTrialType(j,:)),5);
        x  = linspace(-1,4,bin);
        hold on;
        plot(x, data, 'color',colorset(j,:))
        title(area(i))
    end
end
savePath = 'C:\Users\uchidalab\Dropbox (Uchida Lab)\lab\FunInputome\writing\Figures\';
export_fig([savePath 'average response by area normalized.pdf'])