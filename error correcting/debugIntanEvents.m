b = b_odorTimes - b_odorTimes(1);
b = b/2;
e = e_odorTimes - e_odorTimes(1);
itib = diff(b);
itie = diff(e);

[xcf,lags,bounds] = crosscorr(itib(1:end-1), itie);
figure;
plot(lags,xcf)



c = itib- itie(1:308);


figure; plot(c)
