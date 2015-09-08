function [IdxLag rmax]= calculate_channeldx_shift(cscNames,record_Idx,binSize)
if nargin<3
    binSize = 50;
end
Early_record_range = [record_Idx(1) record_Idx(1)+binSize-1];
Late_record_range = [record_Idx(2) record_Idx(2)+binSize-1];

nl = calculate_csc_noise(cscNames,Early_record_range);
nlend = calculate_csc_noise(cscNames,Late_record_range);

[r, lags]= xcorr(nl-mean(nl),nlend-mean(nlend),'coeff');
IdxLag = lags(r==max(r)); % positive meaning index is left shifte
rmax = max(r);
% figure;plot([nl-mean(nl) nlend-mean(nlend)])
