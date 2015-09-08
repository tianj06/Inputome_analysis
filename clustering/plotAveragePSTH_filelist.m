fileList = what(pwd);
fileList = fileList.mat;
% fileList(find(clustLabel == 5))
[averagePSTH, norAllPSTH]= getAveragePSTH_filelist(fileList(4) ,1);
%
CueColor= [  0 	0 	255;%blue  
             30 	144 	255;%light blue  
             128 	128 128;
             255 0 0]/255; % grey
         trialType = [1 2 7 4];
 figure;
for i = 1:4
        plot(averagePSTH(trialType(i),:),'color',CueColor(i,:),'LineWidth',1.5)
        i = i+1;
        hold on
end
%legend('90% W','50% W','90% Nothing','90% puff');  
prettyP([100 4800],'','','','l')
 %%        
figure;
for i = 1:4
        plot(averagePSTH(i,:),'color',CueColor(i,:),'LineWidth',1.5)
        i = i+1;
        hold on
end
legend('90% W','50% W','10% W','90% puff');

prettyP([100 4800],'','','','l')
figure;
for i = 1:4
        plot(averagePSTH(i+4,:),'color',CueColor(i,:),'LineWidth',1.5)
        i = i+1;
        hold on
end
prettyP([100 4800],'','','','l')


%%
roctype = [1 7 4];
m = length(roctype);
titleText = {'90% reward','90% nothing','80%airpuff'};
figure;
for i = 1:m
     Pdata = squeeze(norAllPSTH(:,roctype(i),:));
     subplot(1,m,i);
     imagesc(Pdata,[0 1]);
     colormap yellowblue
    set(gca,'XTick',[10.5:10:50],'XTickLabel',{'0','1','2','3'})
    ylabel('Neuron'); xlabel('Time (s)');
    title(titleText{i})
end
