a = rawPSTH(inputA,[1 2 7],1:4000);
%a = rawPSTH(inputA,[1 2 7 5 6],1:4000);

% if omission of 90% reward is missing, fill with 50% reward omission
% for i = 1:size(a,1)
%     if isnan(a(i,4,1))
%         a(i,4,:) = a(i,5,:);
%     end
% end

% smooth psth
for i = 1:size(a,1)
    for j = 1:size(a,2)
        a(i,j,:) = smooth(a(i,j,:),100); % -mean(a(i,j,1:1000))
    end
end
% subsample psth
proc = permute(a(:,:,10:10:end-10),[1,3,2]);
% normalization  ./max 
temp = squeeze(reshape(proc,size(a,1),1,[]));
zeroMeanPSTh = squeeze(reshape(proc,size(a,1),1,[]));

for i = 1:size(temp,1)
    temp(i,:) = temp(i,:)/max(temp(i,:)); 
    zeroMeanPSTh(i,:) = temp(i,:) - mean(temp(i,:));
end

C = zeroMeanPSTh*zeroMeanPSTh';
[V,D] = eig(C);
[~,i] = max(abs(diag(D)));
cEigVector = V(:,i);
output = cEigVector'*zeroMeanPSTh;

colorset= [  0 	0 	255;%blue  
             30 	144 	255;%light blue  
             128 	128 128;
             0 	0 	255;%blue  
             30 	144 	255;%light blue  
             ]/255; % grey
%%
plotdata = reshape(output,[],size(a,2));
figure;
subplot(2,1,1)
for i = 1:size(a,2)
    plot(squeeze(plotdata(:,i)),'color',colorset(i,:))
    hold on;
end
%set(gca,'xtick',[1:10:30],'xticklabel',{'0','1','2'})
xlabel('Time - odor (s)')
title('Oja''s')

subplot(2,1,2)
plotdata = reshape(mean(zeroMeanPSTh),[],size(a,2));
for i = 1:size(a,2)
    plot(squeeze(plotdata(:,i)),'color',colorset(i,:))
    hold on;
end
%set(gca,'xtick',[1:10:30],'xticklabel',{'0','1','2'})
xlabel('Time - odor (s)')
title('Simple average')
%%



[eigvect,proj,eigval] = princomp(zeroMeanPSTh);
plotdata = reshape(eigvect(:,1),[],3);

b = brainArea(inputA);

plotAreas = {'Ventral striatum','Dorsal striatum','Ventral pallidum','Subthalamic',...
    'Lateral hypothalamus','RMTg','PPTg'}; %'VTA type3', 'VTA type2','Dopamine','rdopamine'
%plotAreas = fliplr(plotAreas);
G = orderAreaGroup(b, plotAreas);
bin = -0.2:0.02:0.2;
figure;
plotHistByGroup(cEigVector,bin,G,plotAreas)

filelist = fl(inputA);
plotAveragePSTH_analyzed_filelist(filelist(G==6&cEigVector>0))

figure;
for i = 1:length(plotAreas)
    plotData = cEigVector(G==i)'*zeroMeanPSTh((G==i),:);
    plotData = reshape(plotData,[],size(a,2));
    subplot(2,4,i)
    for j = 1:3
        plot(plotData(:,j),'color',colorset(j,:))
        hold on;
    end
    prettyP('','','','','a')
    title(plotAreas{i})
end
