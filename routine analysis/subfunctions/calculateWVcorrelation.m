function c = calculateWVcorrelation(wv1,wv2)
wv1(isnan(wv1(:,1,1)),:,:) = [];
wv2(isnan(wv2(:,1,1)),:,:) = [];
N1 = size(wv1,1);
N2 = size(wv2,1);
W = 4;
L = 32;
SigP = 0.01;

for i = 1:N1
    wv1flat(i,:) = reshape( squeeze(wv1(i,:,:))',1,[]);
end

for i = 1:N2
    wv2flat(i,:) = reshape( squeeze(wv2(i,:,:))',1,[]);
end
valiedP = zeros(W*L,1);

for i  = 1:W*L
    [~,p] = ttest(wv1flat(:,i));
    if p<SigP
        valiedP(i) = 1;
    else
        valiedP(i) = 0;
    end
end

c = corr(mean(wv1flat(:,find(valiedP)))', mean(wv2flat(:,find(valiedP)))');
end